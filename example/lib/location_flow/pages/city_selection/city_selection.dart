import 'package:example/location_flow/location_flow.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'city_selection_cubit.dart';

class CitySelection extends StatelessWidget {
  const CitySelection({Key? key, required this.state}) : super(key: key);

  static MaterialPage<void> page({required String state}) {
    return MaterialPage<void>(child: CitySelection(state: state));
  }

  final String state;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        return CitySelectionCubit(context.read<LocationRepository>())
          ..citiesRequested(state);
      },
      child: CitySelectionForm(),
    );
  }
}

class CitySelectionForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('City')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<CitySelectionCubit, LocationState>(
              builder: (context, state) {
                switch (state.status) {
                  case LocationStatus.initial:
                  case LocationStatus.loading:
                    return LoadingIndicator();
                  case LocationStatus.success:
                    return DropdownMenu(
                      hint: const Text('Select a City'),
                      items: state.locations,
                      value: state.selectedLocation,
                      onChanged: (value) => context
                          .read<CitySelectionCubit>()
                          .citySelected(value),
                    );
                  default:
                    return LocationError();
                }
              },
            ),
            BlocBuilder<CitySelectionCubit, LocationState>(
              builder: (context, state) {
                return TextButton(
                  child: const Text('Submit'),
                  onPressed: state.selectedLocation != null
                      ? () => context.flow<Location>().complete(
                          (s) => s.copyWith(city: state.selectedLocation))
                      : null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
