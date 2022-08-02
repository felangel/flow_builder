import 'package:example/location_flow/location_flow.dart';
import 'package:example/location_flow/models/models.dart';
import 'package:example/location_flow/pages/pages.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';

export 'models/models.dart';
export 'repository/location_repository.dart';
export 'widgets/widgets.dart';

List<Page<dynamic>> onGenerateLocationPages(
  Location location,
  List<Page<dynamic>> pages,
) {
  final country = location.country;
  final state = location.state;

  return [
    CountrySelection.page(),
    if (country != null) StateSelection.page(country: country),
    if (state != null) CitySelection.page(state: state),
  ];
}

class LocationFlow extends StatelessWidget {
  const LocationFlow._();

  static Route<Location> route() {
    return MaterialPageRoute(builder: (_) => const LocationFlow._());
  }

  @override
  Widget build(BuildContext context) {
    return const FlowBuilder<Location>(
      state: Location(),
      onGeneratePages: onGenerateLocationPages,
    );
  }
}
