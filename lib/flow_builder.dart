library flow_builder;

import 'dart:collection';

import 'package:flutter/widgets.dart';

/// Signature for function which generates a [List<Page>] given an input of [T]
/// and the current [List<Page>].
typedef OnGeneratePages<T> = List<Page> Function(T, List<Page>);

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
    Key key,
    this.state,
    @required this.onGeneratePages,
    this.onComplete,
    this.controller,
  })  : assert(
          state != null || controller != null,
          'requires either state or controller',
        ),
        assert(
          !(state != null && controller != null),
          'cannot provide controller and state',
        ),
        assert(onGeneratePages != null),
        super(key: key);

  /// Builds a [List<Page>] based on the current state.
  final OnGeneratePages<T> onGeneratePages;

  /// Optional [ValueSetter<T>] which is invoked when the
  /// flow has been completed with the final flow state.
  final ValueSetter<T> onComplete;

  /// The state of the flow.
  final T state;

  /// Optional [FlowController] which will be used in the current flow.
  /// If not provided, a [FlowController] instance will be created internally.
  final FlowController<T> controller;

  @override
  _FlowBuilderState<T> createState() => _FlowBuilderState<T>();
}

class _FlowBuilderState<T> extends State<FlowBuilder<T>> {
  final _history = ListQueue<T>();
  var _pages = <Page>[];
  var _didPop = false;
  final _navigatorKey = GlobalKey<NavigatorState>();
  NavigatorState get _navigator => _navigatorKey.currentState;
  T get _state => _controller._notifier.value;
  FlowController<T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = (widget.controller ?? FlowController(widget.state))
      ..addListener(_listener);
    _pages = widget.onGeneratePages(_state, List.of(_pages));
    _history.add(_state);
  }

  @override
  void didUpdateWidget(covariant FlowBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller = widget.controller ?? FlowController(_state);
    }
    if (oldWidget.state != widget.state) {
      _controller = widget.controller ?? FlowController(widget.state);
      _pages = widget.onGeneratePages(_state, List.of(_pages));
      _history
        ..clear()
        ..add(_state);
    }
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_listener)
      ..dispose();
    super.dispose();
  }

  void _listener() {
    if (_controller._completed) {
      if (widget.onComplete != null) {
        return widget.onComplete(_state);
      }
      return Navigator.of(context).pop(_state);
    }
    if (!_didPop) {
      setState(() {
        _pages = widget.onGeneratePages(_state, List.of(_pages));
        _history.add(_state);
      });
    } else {
      _didPop = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _InheritedFlowController(
      controller: _controller,
      child: _ConditionalWillPopScope(
        condition: _pages.length > 1,
        onWillPop: () async {
          await _navigator.maybePop();
          return false;
        },
        child: Navigator(
          key: _navigatorKey,
          pages: _pages,
          onPopPage: (route, dynamic result) {
            if (_history.length > 1) {
              _history.removeLast();
              _didPop = true;
              _controller._notifier.value = _history.last;
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
    Key key,
    @required this.controller,
    @required Widget child,
  }) : super(key: key, child: child);

  final FlowController<T> controller;

  static FlowController<T> of<T>(BuildContext context) {
    final inheritedFlowController = context
        .getElementForInheritedWidgetOfExactType<_InheritedFlowController<T>>()
        ?.widget as _InheritedFlowController<T>;
    if (inheritedFlowController?.controller == null) {
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
class FlowController<T> {
  /// {@macro flow_controller}
  FlowController(T state) : this._(ValueNotifier<T>(state));

  FlowController._(this._notifier);

  final ValueNotifier<T> _notifier;

  bool _completed = false;

  /// [update] can be called to update the current flow state.
  /// [update] takes a closure which exposes the current flow state
  /// and is responsible for returning the new flow state.
  ///
  /// When [update] is called, the `builder` method of the corresponding
  /// [FlowBuilder] will be called with the new flow state.
  void update(T Function(T) callback) {
    _notifier.value = callback(_notifier.value);
  }

  /// [complete] can be called to complete the current flow.
  /// [complete] takes a closure which exposes the current flow state
  /// and is responsible for returning the new flow state.
  ///
  /// When [complete] is called, the flow is popped with the new flow state.
  void complete([T Function(T) callback]) {
    _completed = true;
    final state = callback?.call(_notifier.value) ?? _notifier.value;
    if (state == _notifier.value) {
      // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
      _notifier.notifyListeners();
    }
    _notifier.value = state;
  }

  /// Register a closure to be called when the flow state changes.
  void addListener(VoidCallback listener) => _notifier.addListener(listener);

  /// Remove a previously registered closure from the list of closures that the
  /// object notifies.
  void removeListener(VoidCallback listener) {
    _notifier.removeListener(listener);
  }

  /// Discards any resources used by the object. After this is called, the
  /// object is not in a usable state and should be discarded (calls to
  /// [addListener] and [removeListener] will throw after the object is
  /// disposed).
  ///
  /// This method should only be called by the object's owner.
  void dispose() => _notifier.dispose();
}

/// {@template fake_flow_controller}
/// A concrete [FlowController] implementation that has no impact
/// on flow navigation.
///
/// This implementation is intended to be used for testing purposes.
/// {@endtemplate}
class FakeFlowController<T> extends FlowController<T> {
  /// {@macro fake_flow_controller}
  FakeFlowController(T state)
      : _state = state,
        super(state);

  T _state;

  /// The current state of the flow.
  T get state => _state;

  /// Whether the flow has been completed.
  bool get completed => _completed;

  @override
  void update(T Function(T) callback) {
    _state = callback(_state);
  }

  @override
  void complete([T Function(T) callback]) {
    _completed = true;
    _state = callback(_state);
  }
}

class _ConditionalWillPopScope extends StatelessWidget {
  const _ConditionalWillPopScope({
    Key key,
    @required this.condition,
    @required this.onWillPop,
    @required this.child,
  }) : super(key: key);

  final bool condition;
  final Widget child;
  final Future<bool> Function() onWillPop;

  @override
  Widget build(BuildContext context) {
    return condition ? WillPopScope(onWillPop: onWillPop, child: child) : child;
  }
}
