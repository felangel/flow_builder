import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:example/location_flow/location_flow.dart';
import 'package:example/onboarding_flow.dart';
import 'package:example/profile_flow.dart';

void main() {
  EquatableConfig.stringify = kDebugMode;
  runApp(MyApp(locationRepository: LocationRepository()));
}

class MyApp extends StatelessWidget {
  MyApp({Key key, @required LocationRepository locationRepository})
      : assert(locationRepository != null),
        _locationRepository = locationRepository,
        super(key: key);

  final LocationRepository _locationRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _locationRepository,
      child: MaterialApp(home: Home()),
    );
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Builder(
        builder: (context) {
          return ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.help_outline),
                title: const Text('Onboarding Flow'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await Navigator.of(context).push(OnboardingFlow.route());
                  Scaffold.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Onboarding Flow Complete!'),
                      ),
                    );
                },
              ),
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: const Text('Profile Flow'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final profile = await Navigator.of(context).push(
                    ProfileFlow.route(),
                  );
                  Scaffold.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text('Profile Flow Complete!\n$profile'),
                      ),
                    );
                },
              ),
              ListTile(
                leading: const Icon(Icons.location_city),
                title: const Text('Location Flow'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  final location = await Navigator.of(context).push(
                    LocationFlow.route(),
                  );
                  Scaffold.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text('Location Flow Complete!\n$location'),
                      ),
                    );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}
