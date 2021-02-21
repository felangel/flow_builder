import 'package:bloc/bloc.dart';
import 'package:example/location_flow/location_flow.dart';

class StateSelectionCubit extends Cubit<LocationState> {
  StateSelectionCubit(this._locationRepository)
      : super(const LocationState.initial());

  final LocationRepository _locationRepository;

  void statesRequested(String country) async {
    emit(const LocationState.loading());

    try {
      final stateList = await _locationRepository.getStates(country);
      final states = stateList.map((s) => s.name).toList();
      emit(LocationState.success(states));
    } on Exception {
      emit(const LocationState.failure());
    }
  }

  void stateSelected(String? value) {
    if (state.status == LocationStatus.success) {
      emit(state.copyWith(selectedLocation: value));
    }
  }
}
