import 'package:bloc/bloc.dart';
import 'package:example/location_flow/location_flow.dart';

class CountrySelectionCubit extends Cubit<LocationState> {
  CountrySelectionCubit(this._locationRepository)
      : super(const LocationState.initial());

  final LocationRepository _locationRepository;

  Future<void> countriesRequested() async {
    emit(const LocationState.loading());

    try {
      final countryList = await _locationRepository.getCountries();
      final countries = countryList.map((c) => c.name).toList();
      emit(LocationState.success(countries));
    } catch (_) {
      emit(const LocationState.failure());
    }
  }

  void countrySelected(String? value) {
    if (state.status == LocationStatus.success) {
      emit(state.copyWith(selectedLocation: value));
    }
  }
}
