<p align="center">
<img src="https://raw.githubusercontent.com/felangel/flow_builder/master/art/flow_builder_logo.png" height="150" alt="Flow Builder" />
</p>

<p align="center">
  <b>Flutter Flows made easy!</b>
</p>

<p align="center">
<a href="https://github.com/felangel/flow_builder/actions"><img src="https://github.com/felangel/flow_builder/workflows/build/badge.svg?branch=master" alt="build"></a>
<a href="https://github.com/felangel/flow_builder/actions"><img src="https://raw.githubusercontent.com/felangel/flow_builder/master/coverage_badge.svg" alt="coverage"></a>
<a href="https://pub.dev/packages/flow_builder"><img src="https://img.shields.io/pub/v/flow_builder.svg" alt="pub package"></a>
</p>

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
  onGeneratePages: (profile) {
    return [
      MaterialPage(child: NameForm()),
      if (profile.name != null) MaterialPage(child: AgeForm()),
      if (profile.age != null) MaterialPage(child: WeightForm()),
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
class WeightForm extends StatefulWidget {
  @override
  _WeightFormState createState() => _WeightFormState();
}

class _WeightFormState extends State<WeightForm> {
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
