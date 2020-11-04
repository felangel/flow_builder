import 'package:example/location_flow/repository/data/data.dart';

class LocationRepository {
  Future<List<Country>> getCountries() async {
    await _wait();
    return countries();
  }

  Future<List<State>> getStates(String country) async {
    await _wait();
    final countryList = await countries();
    final selectedCountry = countryList.firstWhere(
      (element) => element.name == country,
      orElse: () => null,
    );
    if (selectedCountry == null) return [];
    final stateList = await states();
    return stateList.where((s) => s.countryId == selectedCountry.id).toList();
  }

  Future<List<City>> getCities(String state) async {
    await _wait();
    final stateList = await states();
    final selectedState = stateList.firstWhere(
      (element) => element.name == state,
      orElse: () => null,
    );
    if (selectedState == null) return [];
    final cityList = await cities();
    return cityList.where((s) => s.stateId == selectedState.id).toList();
  }
}

Future<void> _wait() => Future.delayed(const Duration(milliseconds: 300));
