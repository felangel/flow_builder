# flow_builder

Flows made easy in Flutter

## Usage

### Define Flow using FlowBuilder

```dart
FlowBuilder<Profile>(
  initialValue: const Profile(),
  steps: [
    (context, state) => MaterialPage(child: ProfileNameForm()),
    (context, state) => MaterialPage(child: ProfileAgeForm()),
    (context, state) => MaterialPage(child: ProfileWeightForm()),
  ],
);
```

### Use `FlowController` to manipulate the Flow

```dart
class NameForm extends StatefulWidget {
  @override
  _NameFormState createState() => _NameFormState();
}

class _NameFormState extends State<NameForm> {
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
```
