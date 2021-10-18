import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';

import 'location_flow.dart';
import 'models/models.dart';
import 'pages/pages.dart';

export 'models/models.dart';
export 'repository/location_repository.dart';
export 'widgets/widgets.dart';

List<Page> onGenerateLocationPages(Location location, List<Page> pages) {
  final country = location.country;
  final state = location.state;

  return [
    CountrySelection.page(),
    if (country != null) StateSelection.page(country: country),
    if (state != null) CitySelection.page(state: state),
  ];
}

class LocationFlow extends StatelessWidget {
  const LocationFlow({Key? key}) : super(key: key);

  static Page<Location> page() => const MaterialPage(child: LocationFlow());

  static Route<Location> route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: '/location'),
      builder: (_) => const LocationFlow(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<Location>(
      state: const Location(),
      onGeneratePages: onGenerateLocationPages,
      onLocationChanged: (location, state) {
        return Location(
          country: location.queryParameters['country'],
          city: location.queryParameters['city'],
          state: location.queryParameters['state'],
        );
      },
    );
  }
}
