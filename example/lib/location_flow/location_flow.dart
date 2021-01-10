import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';

import 'location_flow.dart';
import 'models/models.dart';
import 'pages/pages.dart';

export 'models/models.dart';
export 'repository/location_repository.dart';
export 'widgets/widgets.dart';

List<Page> onGenerateLocationPages(Location state, List<Page> pages) {
  return [
    CountrySelection.page(),
    if (state.country != null) StateSelection.page(country: state.country!),
    if (state.state != null) CitySelection.page(state: state.state!),
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
