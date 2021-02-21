import 'package:bloc/bloc.dart';
import 'package:example/location_flow/location_flow.dart';

class CitySelectionCubit extends Cubit<LocationState> {
  CitySelectionCubit(this._locationRepository)
      : super(const LocationState.initial());

  final LocationRepository _locationRepository;

  void citiesRequested(String city) async {
    emit(const LocationState.loading());

    try {
      final cityList = await _locationRepository.getCities(city);
      final cities = cityList.map((c) => c.name).toList();
      emit(LocationState.success(cities));
    } on Exception {
      emit(const LocationState.failure());
    }
  }

  void citySelected(String? value) {
    if (state.status == LocationStatus.success) {
      emit(state.copyWith(selectedLocation: value));
    }
  }
}
