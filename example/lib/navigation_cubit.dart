import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'router_delegate.dart';

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState());

  void clearRoute() {
    emit(const NavigationState());
  }

  void setRoute(AppRoute configuration) {
    emit(NavigationState(deepLink: configuration));
  }
}

class NavigationState extends Equatable {
  const NavigationState({this.deepLink});

  final AppRoute? deepLink;

  @override
  List<Object?> get props => [deepLink];
}
