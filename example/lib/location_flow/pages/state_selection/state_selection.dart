import 'package:example/location_flow/location_flow.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'state_selection_cubit.dart';

class StateSelection extends StatelessWidget {
  const StateSelection({Key? key, required this.country}) : super(key: key);

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
      child: StateSelectionForm(),
    );
  }
}

class StateSelectionForm extends StatelessWidget {
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
                    return LoadingIndicator();
                  case LocationStatus.success:
                    return DropdownMenu(
                      hint: const Text('Select a State'),
                      items: state.locations,
                      value: state.selectedLocation,
                      onChanged: (value) => context
                          .read<StateSelectionCubit>()
                          .stateSelected(value),
                    );
                  default:
                    return LocationError();
                }
              },
            ),
            BlocBuilder<StateSelectionCubit, LocationState>(
              builder: (context, state) {
                return TextButton(
                  child: const Text('Submit'),
                  onPressed: state.selectedLocation != null
                      ? () => context.flow<Location>().update(
                          (s) => s.copyWith(state: state.selectedLocation))
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
