import 'package:example/location_flow/location_flow.dart';
import 'package:example/location_flow/pages/city_selection/city_selection_cubit.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CitySelection extends StatelessWidget {
  const CitySelection({super.key, required this.state});

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
      child: const CitySelectionForm(),
    );
  }
}

class CitySelectionForm extends StatelessWidget {
  const CitySelectionForm({super.key});

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
                    return const LoadingIndicator();
                  case LocationStatus.success:
                    return Dropdown(
                      hint: const Text('Select a City'),
                      items: state.locations,
                      value: state.selectedLocation,
                      onChanged: (value) => context
                          .read<CitySelectionCubit>()
                          .citySelected(value),
                    );
                  case LocationStatus.failure:
                    return const LocationError();
                }
              },
            ),
            BlocBuilder<CitySelectionCubit, LocationState>(
              builder: (context, state) {
                return TextButton(
                  onPressed: state.selectedLocation != null
                      ? () => context.flow<Location>().complete(
                            (s) => s.copyWith(city: state.selectedLocation),
                          )
                      : null,
                  child: const Text('Submit'),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
