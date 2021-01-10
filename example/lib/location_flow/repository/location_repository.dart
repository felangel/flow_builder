import 'package:example/location_flow/repository/data/data.dart';

class LocationRepository {
  Future<List<Country>> getCountries() async {
    await _wait();
    return countries();
  }

  Future<List<State>> getStates(String country) async {
    await _wait();
    final countryList = await countries();
    try {
      final selectedCountry =
          countryList.firstWhere((element) => element.name == country);
      final stateList = await states();
      return stateList.where((s) => s.countryId == selectedCountry.id).toList();
    } on StateError catch (_) {
      return [];
    }
  }

  Future<List<City>> getCities(String state) async {
    await _wait();
    final stateList = await states();
    try {
      final selectedState =
          stateList.firstWhere((element) => element.name == state);
      final cityList = await cities();
      return cityList.where((s) => s.stateId == selectedState.id).toList();
    } on StateError catch (_) {
      return [];
    }
  }
}

Future<void> _wait() => Future.delayed(const Duration(milliseconds: 300));
