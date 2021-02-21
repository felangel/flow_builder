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

The flow state will be the state which drives the flow. Each time this state changes, a new navigation stack will be generated based on the new flow state.

```dart
class Profile {
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
}
```

### Create a FlowBuilder

`FlowBuilder` is a widget which builds a navigation stack in response to changes in the flow state. `onGeneratePages` will be invoked for each state change and must return the new navigation stack as a list of pages.

```dart
FlowBuilder<Profile>(
  state: const Profile(),
  onGeneratePages: (profile, pages) {
    return [
      MaterialPage(child: NameForm()),
      if (profile.name != null) MaterialPage(child: AgeForm()),
    ];
  },
);
```

### Update the Flow State

The state of the flow can be updated via `context.flow<T>().update`.

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

The flow can be completed via `context.flow<T>().complete`.

```dart
class AgeForm extends StatefulWidget {
  @override
  _AgeFormState createState() => _AgeFormState();
}

class _AgeFormState extends State<AgeForm> {
  int _age;

  void _continuePressed() {
    context
        .flow<Profile>()
        .complete((profile) => profile.copyWith(age: _age));
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
```

### FlowController

A `FlowBuilder` can also be created with a custom `FlowController` in cases where the flow can be manipulated outside of the sub-tree.

```dart
class MyFlow extends StatefulWidget {
  @override
  State<MyFlow> createState() => _MyFlowState();
}

class _MyFlowState extends State<MyFlow> {
  FlowController<Profile> _controller;

  @override
  void initState() {
    super.initState();
    _controller = FlowController(const Profile());
  }

  @override
  Widget build(BuildContext context) {
    return FlowBuilder(
      controller: _controller,
      onGeneratePages: ...,
    );
  }

  @override dispose() {
    _controller.dispose();
    super.dispose();
  }
}
```
