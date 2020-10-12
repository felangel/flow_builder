library flow_builder;

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class _FlowState<T> extends Equatable {
  const _FlowState({this.step = 0, this.value, this.history = const <int>[0]});

  final int step;
  final T value;
  final List<int> history;

  _FlowState<T> copyWith({int step, T value, List<int> history}) {
    return _FlowState(
      step: step ?? this.step,
      value: value ?? this.value,
      history: history ?? this.history,
    );
  }

  @override
  List<Object> get props => [step, value, history];
}

class FlowController<S> extends Cubit<_FlowState<S>> {
  FlowController(_FlowState<S> state, this._numSteps) : super(state);

  final int _numSteps;

  void forward([S Function(S value) value]) {
    emit(state.copyWith(
      value: value?.call(state.value),
      step: state.step + 1,
      history: state.step + 1 < _numSteps
          ? (List.of(state.history)..add(state.step + 1))
          : null,
    ));
  }

  void goTo(int step, [S Function(S state) value]) {
    emit(state.copyWith(
      value: value?.call(state.value),
      step: step,
      history: List.of(state.history)..add(step),
    ));
  }

  void back([S Function(S value) value]) {
    emit(state.copyWith(
      value: value?.call(state.value),
      step: state.step - 1,
      history:
          state.step - 1 >= 0 ? (List.of(state.history)..removeLast()) : null,
    ));
  }

  void complete([S Function(S value) value]) {
    emit(state.copyWith(
      value: value?.call(state.value),
      step: _numSteps,
    ));
  }

  void exit([S Function(S value) value]) {
    emit(state.copyWith(
      value: value?.call(state.value),
      step: -1,
    ));
  }
}

typedef FlowWidgetBuilder<S> = Widget Function(
    BuildContext, S, FlowController<S>);

class FlowBuilder<S> extends StatefulWidget {
  const FlowBuilder({
    Key key,
    @required this.steps,
    this.initialValue,
    this.initialStep,
    this.onComplete,
    this.onExit,
    this.controller,
  })  : assert(steps != null),
        assert(steps.length > 0),
        super(key: key);

  final S initialValue;
  final int initialStep;
  final List<FlowWidgetBuilder<S>> steps;
  final ValueSetter<S> onComplete;
  final ValueSetter<S> onExit;
  final FlowController<S> controller;

  @override
  _FlowBuilderState<S> createState() => _FlowBuilderState<S>();
}

class _FlowBuilderState<S> extends State<FlowBuilder<S>> {
  FlowController<S> _controller;

  void _initController() {
    _controller?.close();
    _controller = widget.controller ??
        FlowController<S>(
          _FlowState(
            value: widget.initialValue,
            step: widget.initialStep ?? 0,
            history: [widget.initialStep ?? 0],
          ),
          widget.steps.length,
        );
  }

  @override
  void initState() {
    super.initState();
    _initController();
  }

  @override
  void didUpdateWidget(covariant FlowBuilder<S> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      _initController();
    }
  }

  @override
  void dispose() {
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: _controller,
      child: BlocConsumer<Cubit<_FlowState<S>>, _FlowState<S>>(
        cubit: _controller,
        listener: (context, state) {
          if (state.step >= widget.steps.length) {
            (widget.onComplete ?? Navigator.of(context).pop).call(state.value);
          } else if (state.step < 0) {
            (widget.onExit ?? Navigator.of(context).pop).call(state.value);
          }
        },
        builder: (context, state) {
          return Navigator(
            pages: [
              for (final step in state.history)
                MaterialPage<void>(
                  child: widget.steps[step](
                    context,
                    state.value,
                    context.flow<S>(),
                  ),
                )
            ],
            onPopPage: (route, dynamic result) {
              _controller.back();
              return false;
            },
          );
        },
      ),
    );
  }
}

extension FlowControllerX on BuildContext {
  FlowController<S> flow<S>() => bloc<FlowController<S>>();
}
