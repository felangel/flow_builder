import 'package:equatable/equatable.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';

List<Page> onGenerateProfilePages(Profile profile, List<Page> pages) {
  return [
    MaterialPage<void>(child: ProfileNameForm(), name: '/profile'),
    if (profile.name != null) MaterialPage<void>(child: ProfileAgeForm()),
    if (profile.age != null) MaterialPage<void>(child: ProfileWeightForm()),
  ];
}

class ProfileFlow extends StatelessWidget {
  static Route<Profile> route() {
    return MaterialPageRoute(builder: (_) => ProfileFlow());
  }

  @override
  Widget build(BuildContext context) {
    return const FlowBuilder<Profile>(
      state: Profile(),
      onGeneratePages: onGenerateProfilePages,
    );
  }
}

class ProfileNameForm extends StatefulWidget {
  @override
  _ProfileNameFormState createState() => _ProfileNameFormState();
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
          padding: const EdgeInsets.all(8.0),
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
                child: const Text('Continue'),
                onPressed: _name.isNotEmpty ? _continuePressed : null,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileAgeForm extends StatefulWidget {
  @override
  _ProfileAgeFormState createState() => _ProfileAgeFormState();
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
          padding: const EdgeInsets.all(8.0),
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
                child: const Text('Continue'),
                onPressed: _age != null ? _continuePressed : null,
              )
            ],
          ),
        ),
      ),
    );
  }
}

class ProfileWeightForm extends StatefulWidget {
  @override
  _ProfileWeightFormState createState() => _ProfileWeightFormState();
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
          padding: const EdgeInsets.all(8.0),
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
                child: const Text('Continue'),
                onPressed: _weight != null ? _continuePressed : null,
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
