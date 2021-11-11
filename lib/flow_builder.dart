library flow_builder;

import 'dart:collection';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

/// Signature for function which generates a [List<Page>] given an input of [T]
/// and the current [List<Page>].
typedef OnGeneratePages<T> = List<Page> Function(T state, List<Page> pages);

/// Signature for function which given an input flow state [T] will
/// output a new flow state [T].
///
/// It is used to compute the next flow state with [FlowController.update] and
/// [FlowController.complete].
typedef FlowCallback<T> = T Function(T state);

/// {@template flow_builder}
/// [FlowBuilder] abstracts navigation and exposes a declarative routing API
/// based on a [state].
///
/// By default completing a flow results in the flow being popped from
/// the navigation stack with the resulting flow state.
///
/// To override the default behavior, provide an
/// implementation for `onComplete`.
///
/// ```dart
/// FlowBuilder<MyFlowState>(
///   state: MyFlowState.initial(),
///   onGeneratePages: (state, pages) {...},
///   onComplete: (state) {
///     // do something when flow is completed...
///   }
/// )
/// ```
/// {@endtemplate}
class FlowBuilder<T> extends StatefulWidget {
  /// {@macro flow_builder}
  const FlowBuilder({
    Key? key,
    required this.onGeneratePages,
    this.state,
    this.onComplete,
    this.controller,
    this.observers = const <NavigatorObserver>[],
  })  : assert(
          state != null || controller != null,
          'requires either state or controller',
        ),
        assert(
          !(state != null && controller != null),
          'cannot provide controller and state',
        ),
        super(key: key);

  /// Builds a [List<Page>] based on the current state.
  final OnGeneratePages<T> onGeneratePages;

  /// Optional [ValueSetter<T>] which is invoked when the
  /// flow has been completed with the final flow state.
  final ValueSetter<T>? onComplete;

  /// The state of the flow.
  final T? state;

  /// Optional [FlowController] which will be used in the current flow.
  /// If not provided, a [FlowController] instance will be created internally.
  final FlowController<T>? controller;

  /// A list of [NavigatorObserver] for this [FlowBuilder].
  final List<NavigatorObserver> observers;

  @override
  _FlowBuilderState<T> createState() => _FlowBuilderState<T>();
}

class _FlowBuilderState<T> extends State<FlowBuilder<T>> {
  late FlowController<T> _controller;

  final _history = ListQueue<T>();
  var _pages = <Page>[];
  var _didPop = false;
  late final GlobalObjectKey<NavigatorState> _navigatorKey;
  NavigatorState? get _navigator => _navigatorKey.currentState;
  T get _state => _controller.state;
  bool get _canPop => _pages.length > 1 || (_navigator?.canPop() ?? false);

  @override
  void initState() {
    super.initState();
    _navigatorKey = GlobalObjectKey<NavigatorState>(this);
    _SystemNavigationObserver.add(_pop);
    _controller = _initController(widget.state);
    _pages = widget.onGeneratePages(_state, List.of(_pages));
    _history.add(_state);
  }

  @override
  void didUpdateWidget(FlowBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _removeListeners(dispose: oldWidget.controller == null);
      _controller = _initController(widget.state);
      _pages = widget.onGeneratePages(_state, List.of(_pages));
      _history
        ..clear()
        ..add(_state);
    } else if (oldWidget.controller != widget.controller) {
      _removeListeners(dispose: oldWidget.controller == null);
      _controller = widget.controller ?? _initController(_controller.state);
      _pages = widget.onGeneratePages(_state, List.of(_pages));
      _history
        ..clear()
        ..add(_state);
    }
  }

  FlowController<T> _initController(T? state) {
    return _controller = (widget.controller ?? FlowController(state!))
      ..addListener(_listener);
  }

  void _removeListeners({required bool dispose}) {
    _controller.removeListener(_listener);
    if (dispose) _controller.dispose();
  }

  @override
  void dispose() {
    _SystemNavigationObserver.remove(_pop);
    _removeListeners(dispose: widget.controller == null);
    super.dispose();
  }

  Future<bool> _pop() async {
    if (mounted) {
      final popHandled = await _navigator?.maybePop(_state) ?? false;
      if (popHandled) return true;
      if (!_canPop) return await Navigator.of(context).maybePop(_state);
      return false;
    }
    return false;
  }

  void _listener() {
    if (_controller.completed) {
      _controller.removeListener(_listener);
      if (widget.onComplete != null) return widget.onComplete!(_state);
      if (mounted) return Navigator.of(context).pop(_state);
    }

    if (_didPop) {
      _didPop = false;
      return;
    }

    setState(() {
      _pages = widget.onGeneratePages(_state, List.of(_pages));
      _history.add(_state);
    });
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedFlowController(
      controller: _controller,
      child: _ConditionalWillPopScope(
        condition: _canPop,
        onWillPop: () async {
          await _navigator?.maybePop();
          return false;
        },
        child: Navigator(
          key: _navigatorKey,
          pages: _pages,
          observers: widget.observers,
          onPopPage: (route, dynamic result) {
            if (_history.length > 1) {
              _history.removeLast();
              _didPop = true;
              _controller.update((_) => _history.last);
            }
            if (_pages.length > 1) {
              _pages.removeLast();
            }
            setState(() {});
            return route.didPop(result);
          },
        ),
      ),
    );
  }
}

class _InheritedFlowController<T> extends InheritedWidget {
  const _InheritedFlowController({
    Key? key,
    required this.controller,
    required Widget child,
  }) : super(key: key, child: child);

  final FlowController<T> controller;

  static FlowController<T> of<T>(BuildContext context) {
    final inheritedFlowController = context
        .getElementForInheritedWidgetOfExactType<_InheritedFlowController<T>>()
        ?.widget as _InheritedFlowController<T>?;
    if (inheritedFlowController == null) {
      throw FlutterError(
        '''
        context.flow<$T>() called with a context that does not contain a FlowBuilder of type $T.

        This can happen if the context you used comes from a widget above the FlowBuilder.

        The context used was: $context
        ''',
      );
    }
    return inheritedFlowController.controller;
  }

  @override
  bool updateShouldNotify(_InheritedFlowController<T> oldWidget) =>
      oldWidget.controller != controller;
}

/// {@template flow_extension}
/// Extension on [BuildContext] which exposes the ability to access
/// a [FlowController].
/// {@endtemplate}
extension FlowX on BuildContext {
  /// {@macro flow_extension}
  FlowController<T> flow<T>() => _InheritedFlowController.of<T>(this);
}

/// {@template flow_controller}
/// A controller which exposes APIs to [update] and [complete]
/// the current flow.
/// {@endtemplate}
class FlowController<T> extends ChangeNotifier {
  /// {@macro flow_controller}
  FlowController(T state) : this._(state);

  FlowController._(this._state);

  T _state;

  /// The current state of the flow.
  T get state => _state;

  bool _completed = false;

  /// Whether the current flow has been completed.
  bool get completed => _completed;

  /// [update] can be called to update the current flow state.
  /// [update] takes a closure which exposes the current flow state
  /// and is responsible for returning the new flow state.
  ///
  /// When [update] is called, the `builder` method of the corresponding
  /// [FlowBuilder] will be called with the new flow state.
  void update(FlowCallback<T> callback) {
    _state = callback(_state);
    notifyListeners();
  }

  /// [complete] can be called to complete the current flow.
  /// [complete] takes a closure which exposes the current flow state
  /// and is responsible for returning the new flow state.
  ///
  /// When [complete] is called, the flow is popped with the new flow state.
  void complete([FlowCallback<T>? callback]) {
    _completed = true;
    final nextState = callback?.call(_state) ?? _state;
    _state = nextState;
    notifyListeners();
  }

  /// Register a closure to be called when the flow state changes.
  @mustCallSuper
  @override
  void addListener(VoidCallback listener) => super.addListener(listener);

  /// Remove a previously registered closure from the list of closures that the
  /// object notifies.
  @mustCallSuper
  @override
  void removeListener(VoidCallback listener) => super.removeListener(listener);
}

/// {@template fake_flow_controller}
/// A concrete [FlowController] implementation that has no impact
/// on flow navigation.
///
/// This implementation is intended to be used for testing purposes.
/// {@endtemplate}
class FakeFlowController<T> extends FlowController<T> {
  /// {@macro fake_flow_controller}
  FakeFlowController(T state) : super(state);

  @override
  T get state => _state;

  @override
  bool get completed => _completed;

  @override
  void update(FlowCallback<T> callback) {
    _state = callback(_state);
  }

  @override
  void complete([FlowCallback<T>? callback]) {
    _completed = true;
    if (callback != null) _state = callback(_state);
  }
}

class _ConditionalWillPopScope extends StatelessWidget {
  const _ConditionalWillPopScope({
    Key? key,
    required this.condition,
    required this.onWillPop,
    required this.child,
  }) : super(key: key);

  final bool condition;
  final Widget child;
  final Future<bool> Function() onWillPop;

  @override
  Widget build(BuildContext context) {
    return condition ? WillPopScope(onWillPop: onWillPop, child: child) : child;
  }
}

abstract class _SystemNavigationObserver implements WidgetsBinding {
  static final _interceptors = ListQueue<ValueGetter<Future<bool>>>();

  static void add(ValueGetter<Future<bool>> interceptor) {
    _interceptors.addFirst(interceptor);
    SystemChannels.navigation.setMethodCallHandler(_handleSystemNavigation);
  }

  static void remove(ValueGetter<Future<bool>> interceptor) {
    _interceptors.remove(interceptor);
  }

  static Future<dynamic> _handleSystemNavigation(MethodCall methodCall) {
    switch (methodCall.method) {
      case 'popRoute':
        return _popRoute();
      case 'pushRoute':
        return _pushRoute(methodCall.arguments);
      default:
        return Future<dynamic>.value();
    }
  }

  static Future _popRoute() async {
    for (final interceptor in _interceptors) {
      final preventDefault = await interceptor();
      if (preventDefault) return Future<dynamic>.value();
    }
    return WidgetsBinding.instance!.handlePopRoute();
  }

  static Future _pushRoute(dynamic arguments) async {
    if (arguments is String) {
      return WidgetsBinding.instance!.handlePushRoute(arguments);
    } else {
      return Future<dynamic>.value();
    }
  }
}

/// Visible for testing system navigation.
abstract class TestSystemNavigationObserver {
  /// Visible for testing system pop navigation.
  @visibleForTesting
  static Future<dynamic> handleSystemNavigation(MethodCall methodCall) {
    return _SystemNavigationObserver._handleSystemNavigation(methodCall);
  }
}
