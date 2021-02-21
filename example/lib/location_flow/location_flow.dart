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
  static Route<Location> route() {
    return MaterialPageRoute(builder: (_) => LocationFlow());
  }

  @override
  Widget build(BuildContext context) {
    return const FlowBuilder<Location>(
      state: Location(),
      onGeneratePages: onGenerateLocationPages,
    );
  }
}
