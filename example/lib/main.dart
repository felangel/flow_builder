import 'package:equatable/equatable.dart';
import 'package:example/onboarding_flow.dart';
import 'package:example/profile_flow.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() {
  EquatableConfig.stringify = kDebugMode;
  runApp(MyApp());
}

class MyApp extends MaterialApp {
  MyApp({Key key}) : super(key: key, home: Home());
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
                        content: Text('Profile Flow Complete! $profile'),
                      ),
                    );
                },
              )
            ],
          );
        },
      ),
    );
  }
}
