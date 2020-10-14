library flow_builder;

import 'dart:collection';
import 'package:flutter/widgets.dart';

typedef PageBuilder<T> = List<Page> Function(BuildContext, T);

typedef Update<T> = void Function(T Function(T));

typedef Complete<T> = void Function(T Function(T));

/// {@template flow_builder}
/// [FlowBuilder] abstracts navigation and exposes a declarative routing API
/// based on a state.
/// {@endtemplate}
class FlowBuilder<T> extends StatefulWidget {
  /// {@macro flow_builder}
  const FlowBuilder({Key key, @required this.builder, @required this.state})
      : assert(builder != null),
        assert(state != null),
        super(key: key);

  /// Builds a [List<Page>] based on the current state.
  final PageBuilder<T> builder;

  /// The state of the flow.
  final T state;

  @override
  _FlowBuilderState<T> createState() => _FlowBuilderState<T>();
}

class _FlowBuilderState<T> extends State<FlowBuilder<T>> {
  final _history = ListQueue<T>();
  T _state;

  @override
  void initState() {
    super.initState();
    _state = widget.state;
    _history.add(_state);
  }

  @override
  void didUpdateWidget(covariant FlowBuilder<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.state != widget.state) {
      _state = widget.state;
      _history
        ..clear()
        ..add(_state);
    }
  }

  void _update(T Function(T) update) {
    setState(() {
      final state = update(_state);
      _history.add(state);
      _state = state;
    });
  }

  void _complete(T Function(T) pop) => Navigator.of(context).pop(pop(_state));

  @override
  Widget build(BuildContext context) {
    return _FlowState(
      update: _update,
      complete: _complete,
      child: Builder(
        builder: (context) {
          return Navigator(
            pages: widget.builder(context, _state),
            onPopPage: (route, dynamic result) {
              if (_history.isNotEmpty) {
                _history.removeLast();
                _state = _history.last;
              }
              return route.didPop(result);
            },
          );
        },
      ),
    );
  }
}

class _FlowState<T> extends InheritedWidget {
  const _FlowState({
    Key key,
    @required this.update,
    @required this.complete,
    @required Widget child,
  }) : super(key: key, child: child);

  final Update<T> update;
  final Complete<T> complete;

  static _FlowState<T> of<T>(BuildContext context) {
    return context
        .getElementForInheritedWidgetOfExactType<_FlowState<T>>()
        .widget as _FlowState<T>;
  }

  @override
  bool updateShouldNotify(_FlowState<T> oldWidget) =>
      oldWidget.update != update || oldWidget.complete != complete;
}

/// {@template flow_extension}
/// Extension on [BuildContext] which exposes the ability to access
/// a [FlowController].
/// {@endtemplate}
extension FlowX on BuildContext {
  /// {@macro flow_extension}
  FlowController<T> flow<T>() {
    final state = _FlowState.of<T>(this);
    return FlowController<T>._(state.update, state.complete);
  }
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
  final void Function(T Function(T)) update;

  /// [complete] can be called to complete the current flow.
  /// [complete] takes a closure which exposes the current flow state
  /// and is responsible for returning the new flow state.
  ///
  /// When [complete] is called, the flow is popped with the new flow state.
  final void Function(T Function(T)) complete;
}
