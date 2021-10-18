import 'package:equatable/equatable.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';

class ProfileFlow extends StatelessWidget {
  const ProfileFlow._();

  static Page<Profile> page() => const MaterialPage(child: ProfileFlow._());

  static Route<Profile> route() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: '/profile'),
      builder: (_) => const ProfileFlow._(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<Profile>(
      state: const Profile(),
      onGeneratePages: (Profile profile, List<Page<dynamic>> pages) {
        return [
          const MaterialPage<void>(child: ProfileNameForm(), name: '/profile'),
          if (profile.name != null)
            MaterialPage<void>(
              child: const ProfileAgeForm(),
              name: '/profile?name=${profile.name}',
            ),
          if (profile.age != null)
            MaterialPage<void>(
              child: const ProfileWeightForm(),
              name: '/profile?name=${profile.name}&age=${profile.age}',
            ),
        ];
      },
      onLocationChanged: (location, state) {
        return Profile(
          name: location.queryParameters['name'],
          weight: int.tryParse(location.queryParameters['weight'] ?? ''),
          age: int.tryParse(location.queryParameters['age'] ?? ''),
        );
      },
    );
  }
}

class ProfileNameForm extends StatefulWidget {
  const ProfileNameForm({super.key});

  @override
  State<ProfileNameForm> createState() => _ProfileNameFormState();
}

class _ProfileNameFormState extends State<ProfileNameForm> {
  var _name = '';

  void _continuePressed() {
    context.flow<Profile>().update((profile) => profile.copyWith(name: _name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.flow<Profile>().complete(),
        ),
        title: const Text('Name'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              TextField(
                onChanged: (value) => setState(() => _name = value),
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'John Doe',
                ),
              ),
              ElevatedButton(
                onPressed: _name.isNotEmpty ? _continuePressed : null,
                child: const Text('Continue'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileAgeForm extends StatefulWidget {
  const ProfileAgeForm({super.key});

  @override
  State<ProfileAgeForm> createState() => _ProfileAgeFormState();
}

class _ProfileAgeFormState extends State<ProfileAgeForm> {
  int? _age;

  void _continuePressed() {
    context.flow<Profile>().update((profile) => profile.copyWith(age: _age));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Age')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              TextField(
                onChanged: (value) => setState(() => _age = int.parse(value)),
                decoration: const InputDecoration(
                  labelText: 'Age',
                  hintText: '42',
                ),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: _age != null ? _continuePressed : null,
                child: const Text('Continue'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileWeightForm extends StatefulWidget {
  const ProfileWeightForm({super.key});

  @override
  State<ProfileWeightForm> createState() => _ProfileWeightFormState();
}

class _ProfileWeightFormState extends State<ProfileWeightForm> {
  int? _weight;

  void _continuePressed() {
    context
        .flow<Profile>()
        .complete((profile) => profile.copyWith(weight: _weight));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weight')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: <Widget>[
              TextField(
                onChanged: (value) {
                  setState(() => _weight = int.tryParse(value));
                },
                decoration: const InputDecoration(
                  labelText: 'Weight (lbs)',
                  hintText: '170',
                ),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: _weight != null ? _continuePressed : null,
                child: const Text('Continue'),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class Profile extends Equatable {
  const Profile({this.name, this.age, this.weight});

  final String? name;
  final int? age;
  final int? weight;

  Profile copyWith({String? name, int? age, int? weight}) {
    return Profile(
      name: name ?? this.name,
      age: age ?? this.age,
      weight: weight ?? this.weight,
    );
  }

  @override
  List<Object?> get props => [name, age, weight];
}
