import 'package:example/authentication_flow/authentication_flow.dart';
import 'package:example/location_flow/location_flow.dart';
import 'package:example/onboarding_flow/onboarding_flow.dart';
import 'package:example/profile_flow/profile_flow.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() => runApp(MyApp(locationRepository: LocationRepository()));

class MyApp extends StatelessWidget {
  MyApp({Key? key, required LocationRepository locationRepository})
      : _locationRepository = locationRepository,
        super(key: key);

  final LocationRepository _locationRepository;

  @override
  Widget build(BuildContext context) {
    return RepositoryProvider.value(
      value: _locationRepository,
      child: const MaterialApp(home: UrlFlowBuilder()),
    );
  }
}

class UrlFlowBuilder extends StatelessWidget {
  const UrlFlowBuilder({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<Uri>(
      state: Uri(path: '/'),
      onGeneratePages: (uri, pages) {
        if (uri.pathSegments.isEmpty) return [Home.page()];
        return [
          Home.page(),
          if (uri.pathSegments.first == 'profile') ProfileFlow.page(),
          if (uri.pathSegments.first == 'onboarding') OnboardingFlow.page(),
          if (uri.pathSegments.first == 'location') LocationFlow.page(),
          if (uri.pathSegments.first == 'auth') AuthenticationFlow.page(),
        ];
      },
      onLocationChanged: (location, state) => location,
      onDidPop: (dynamic result) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(SnackBar(content: Text('$result')));
      },
    );
  }
}

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  static Page page() => const MaterialPage<void>(name: '/', child: Home());

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
                  ScaffoldMessenger.of(context)
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
                  ScaffoldMessenger.of(context)
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
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      SnackBar(
                        content: Text('Location Flow Complete!\n$location'),
                      ),
                    );
                },
              ),
              ListTile(
                leading: const Icon(Icons.security_rounded),
                title: const Text('Authentication Flow'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () async {
                  await Navigator.of(context).push<AuthenticationState>(
                    AuthenticationFlow.route(),
                  );
                  ScaffoldMessenger.of(context)
                    ..hideCurrentSnackBar()
                    ..showSnackBar(
                      const SnackBar(
                        content: Text('Authentication Flow Complete!'),
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
