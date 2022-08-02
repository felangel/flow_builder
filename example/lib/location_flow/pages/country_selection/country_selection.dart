import 'package:example/location_flow/location_flow.dart';
import 'package:example/location_flow/pages/country_selection/country_selection_cubit.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CountrySelection extends StatelessWidget {
  const CountrySelection({super.key});

  static MaterialPage<void> page() {
    return const MaterialPage<void>(child: CountrySelection());
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        return CountrySelectionCubit(
          context.read<LocationRepository>(),
        )..countriesRequested();
      },
      child: const CountrySelectionForm(),
    );
  }
}

class CountrySelectionForm extends StatelessWidget {
  const CountrySelectionForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.flow<Location>().complete(),
        ),
        title: const Text('Country'),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<CountrySelectionCubit, LocationState>(
              builder: (context, state) {
                switch (state.status) {
                  case LocationStatus.initial:
                  case LocationStatus.loading:
                    return const LoadingIndicator();
                  case LocationStatus.success:
                    return DropdownMenu(
                      hint: const Text('Select a Country'),
                      items: state.locations,
                      value: state.selectedLocation,
                      onChanged: (value) => context
                          .read<CountrySelectionCubit>()
                          .countrySelected(value),
                    );
                  case LocationStatus.failure:
                    return const LocationError();
                }
              },
            ),
            BlocBuilder<CountrySelectionCubit, LocationState>(
              builder: (context, state) {
                return TextButton(
                  onPressed: state.selectedLocation != null
                      ? () => context.flow<Location>().update(
                            (s) => s.copyWith(country: state.selectedLocation),
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
