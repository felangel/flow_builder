library flow_builder;

import 'dart:collection';

import 'package:flutter/widgets.dart';

/// Signature for [FlowController] `update` function.
typedef Update<T> = void Function(T Function(T));

/// Signature for [FlowController] `complete` function.
typedef Complete<T> = void Function(T Function(T));

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
    @required this.state,
    @required this.onGeneratePages,
    this.onComplete,
    this.controller,
    this.onPop,
  })  : assert(onGeneratePages != null),
        super(key: key);

  /// Optional callback called when a pop event occurs
  final void Function() onPop;

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
  final _navigatorKey = GlobalKey<NavigatorState>();
  NavigatorState get _navigator => _navigatorKey.currentState;
  FlowController<T> _controller;
  T _state;

  @override
  void initState() {
    super.initState();
    _controller = widget.controller ?? FlowController._(_update, _complete);
    _state = widget.state;
    _pages = widget.onGeneratePages(_state, List.of(_pages));
    _history.add(_state);
  }

  @override
  void didUpdateWidget(covariant FlowBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _controller = widget.controller ?? FlowController._(_update, _complete);
    }
    if (oldWidget.state != widget.state) {
      _state = widget.state;
      _pages = widget.onGeneratePages(_state, List.of(_pages));
      _history
        ..clear()
        ..add(_state);
    }
  }

  void _complete(T Function(T) pop) {
    final state = pop(_state);
    if (widget.onComplete != null) {
      widget.onComplete(state);
      return;
    }
    Navigator.of(context).pop(state);
  }

  void _update(T Function(T) update) {
    final state = update(_state);
    setState(() {
      _state = state;
      _pages = widget.onGeneratePages(_state, List.of(_pages));
      _history.add(state);
    });
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
              _state = _history.last;
            }
            if (_pages.length > 1) {
              _pages.removeLast();
            }
            setState(() {});
            final didPop = route.didPop(result);
            if (didPop) {
              widget.onPop?.call();
            }
            return didPop;
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
  const FlowController._(this.update, this.complete);

  /// [update] can be called to update the current flow state.
  /// [update] takes a closure which exposes the current flow state
  /// and is responsible for returning the new flow state.
  ///
  /// When [update] is called, the `builder` method of the corresponding
  /// [FlowBuilder] will be called with the new flow state.
  final Update<T> update;

  /// [complete] can be called to complete the current flow.
  /// [complete] takes a closure which exposes the current flow state
  /// and is responsible for returning the new flow state.
  ///
  /// When [complete] is called, the flow is popped with the new flow state.
  final Complete<T> complete;
}

/// {@template fake_flow_controller}
/// A concrete [FlowController] implementation that has no impact
/// on flow navigation.
///
/// This implementation is intended to be used for testing purposes.
/// {@endtemplate}
class FakeFlowController<T> implements FlowController<T> {
  /// {@macro fake_flow_controller}
  FakeFlowController({@required T state}) : _state = state;

  T _state;
  bool _completed = false;

  /// The current state of the flow.
  T get state => _state;

  /// Whether the flow has been completed.
  bool get completed => _completed;

  @override
  Update<T> get update {
    return (T Function(T) callback) {
      _state = callback(_state);
    };
  }

  @override
  Complete<T> get complete {
    return (T Function(T) callback) {
      _completed = true;
      _state = callback(_state);
    };
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
