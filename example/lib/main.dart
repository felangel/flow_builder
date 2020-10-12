import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flow_builder/flow_builder.dart';

void main() {
  EquatableConfig.stringify = kDebugMode;
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Home());
  }
}

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Builder(
          builder: (context) {
            return RaisedButton(
              onPressed: () async {
                final profile = await Navigator.of(context).push(
                  ProfileFlow.route(),
                );
                Scaffold.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(SnackBar(content: Text('$profile')));
              },
              child: const Text('Start'),
            );
          },
        ),
      ),
    );
  }
}

class ProfileFlow extends StatelessWidget {
  static Route<Profile> route() {
    return MaterialPageRoute(builder: (_) => ProfileFlow());
  }

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<Profile>(
      initialState: const Profile(),
      steps: [
        (context, state) => MaterialPage(child: ProfileNameForm()),
        (context, state) => MaterialPage(child: ProfileAgeForm()),
        (context, state) => MaterialPage(child: ProfileWeightForm()),
      ],
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
    context.flow<Profile>().forward((profile) => profile.copyWith(name: _name));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Name')),
      body: Center(
        child: Column(
          children: <Widget>[
            TextField(
              onChanged: (value) => setState(() => _name = value),
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'John Doe',
              ),
            ),
            RaisedButton(
              child: const Text('Continue'),
              onPressed: _name.isNotEmpty ? _continuePressed : null,
            )
          ],
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
  int _age;

  void _continuePressed() {
    context.flow<Profile>().forward((profile) => profile.copyWith(age: _age));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Age')),
      body: Center(
        child: Column(
          children: <Widget>[
            TextField(
              onChanged: (value) => setState(() => _age = int.parse(value)),
              decoration: InputDecoration(
                labelText: 'Age',
                hintText: '42',
              ),
              keyboardType: TextInputType.number,
            ),
            RaisedButton(
              child: const Text('Continue'),
              onPressed: _age != null ? _continuePressed : null,
            )
          ],
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
  int _weight;

  void _continuePressed() {
    context
        .flow<Profile>()
        .forward((profile) => profile.copyWith(weight: _weight));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Weight')),
      body: Center(
        child: Column(
          children: <Widget>[
            TextField(
              onChanged: (value) => setState(() => _weight = int.parse(value)),
              decoration: InputDecoration(
                labelText: 'Weight (lbs)',
                hintText: '170',
              ),
              keyboardType: TextInputType.number,
            ),
            RaisedButton(
              child: const Text('Continue'),
              onPressed: _weight != null ? _continuePressed : null,
            )
          ],
        ),
      ),
    );
  }
}

class Profile extends Equatable {
  const Profile({this.name, this.age, this.weight});

  final String name;
  final int age;
  final int weight;

  Profile copyWith({String name, int age, int weight}) {
    return Profile(
      name: name ?? this.name,
      age: age ?? this.age,
      weight: weight ?? this.weight,
    );
  }

  @override
  List<Object> get props => [name, age, weight];
}
