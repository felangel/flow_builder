import 'package:example/location_flow/location_flow.dart';
import 'package:example/location_flow/pages/state_selection/state_selection_cubit.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart' hide DropdownMenu;
import 'package:flutter_bloc/flutter_bloc.dart';

class StateSelection extends StatelessWidget {
  const StateSelection({super.key, required this.country});

  static MaterialPage<void> page({required String country}) {
    return MaterialPage<void>(child: StateSelection(country: country));
  }

  final String country;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) {
        return StateSelectionCubit(context.read<LocationRepository>())
          ..statesRequested(country);
      },
      child: const StateSelectionForm(),
    );
  }
}

class StateSelectionForm extends StatelessWidget {
  const StateSelectionForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('State')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            BlocBuilder<StateSelectionCubit, LocationState>(
              builder: (context, state) {
                switch (state.status) {
                  case LocationStatus.initial:
                  case LocationStatus.loading:
                    return const LoadingIndicator();
                  case LocationStatus.success:
                    return DropdownMenu(
                      hint: const Text('Select a State'),
                      items: state.locations,
                      value: state.selectedLocation,
                      onChanged: (value) => context
                          .read<StateSelectionCubit>()
                          .stateSelected(value),
                    );
                  case LocationStatus.failure:
                    return const LocationError();
                }
              },
            ),
            BlocBuilder<StateSelectionCubit, LocationState>(
              builder: (context, state) {
                return TextButton(
                  onPressed: state.selectedLocation != null
                      ? () => context.flow<Location>().update(
                            (s) => s.copyWith(state: state.selectedLocation),
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
