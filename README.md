# flow_builder

Flows made easy in Flutter

## Usage

### Define a Flow State

```dart
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
```

### Define a Flow

```dart
FlowBuilder<Profile>(
  state: const Profile(),
  builder: (context, profile, controller) {
    return [
      MaterialPage(child: ProfileNameForm()),
      if (profile.name != null) MaterialPage(child: ProfileAgeForm()),
      if (profile.age != null) MaterialPage(child: ProfileWeightForm()),
    ];
  },
);
```

### Update the Flow State

```dart
class NameForm extends StatefulWidget {
  @override
  _NameFormState createState() => _NameFormState();
}

class _NameFormState extends State<NameForm> {
  var _name = '';

  void _continuePressed() {
    context.flow<Profile>().update((profile) => profile.copyWith(name: _name));
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
```

### Complete the Flow

```dart
class ProfileWeightForm extends StatefulWidget {
  @override
  _ProfileWeightFormState createState() => _ProfileWeightFormState();
}

class _ProfileWeightFormState extends State<ProfileWeightForm> {
  int _weight;

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
```
