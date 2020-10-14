library flow_builder;

import 'dart:collection';
import 'package:flutter/widgets.dart';

typedef PageBuilder<T> = List<Page> Function(
    BuildContext, T, FlowController<T>);

typedef Update<T> = void Function(T Function(T));

typedef Complete<T> = void Function(T Function(T));

class FlowBuilder<T> extends StatefulWidget {
  const FlowBuilder({Key key, @required this.builder, @required this.state})
      : assert(builder != null),
        assert(state != null),
        super(key: key);

  final PageBuilder<T> builder;
  final T state;

  @override
  _FlowBuilderState<T> createState() => _FlowBuilderState<T>();
}

class _FlowBuilderState<T> extends State<FlowBuilder<T>> {
  T _state;
  ListQueue<T> _history = ListQueue<T>();
  FlowController<T> _controller;

  @override
  void initState() {
    super.initState();
    _controller = FlowController<T>._(_update, _complete);
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
      child: Navigator(
        pages: widget.builder(context, _state, _controller),
        onPopPage: (route, result) {
          if (_history.isNotEmpty) {
            _history.removeLast();
            _state = _history.last;
          }
          return route.didPop(result);
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
        .widget;
  }

  @override
  bool updateShouldNotify(_FlowState<T> oldWidget) =>
      oldWidget.update != update || oldWidget.complete != complete;
}

extension FlowX on BuildContext {
  FlowController<T> flow<T>() {
    final state = _FlowState.of<T>(this);
    return FlowController<T>._(state.update, state.complete);
  }
}

class FlowController<T> {
  const FlowController._(this.update, this.complete);
  final void Function(T Function(T) cb) update;
  final void Function(T Function(T) cb) complete;
}
