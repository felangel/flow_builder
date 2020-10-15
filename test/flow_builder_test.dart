import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlowBuilder', () {
    test('throws AssertionError when builder is null', () async {
      expect(
        () => FlowBuilder(builder: null, state: null),
        throwsAssertionError,
      );
    });

    test('does not throw when state is null', () async {
      expect(
        () => FlowBuilder(builder: (_, dynamic __) => [], state: null),
        isNot(throwsAssertionError),
      );
    });

    testWidgets('renders correct navigation stack w/one page', (tester) async {
      const targetKey = Key('__target__');
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            state: 0,
            builder: (context, state) {
              return const <Page>[
                MaterialPage<void>(child: SizedBox(key: targetKey)),
              ];
            },
          ),
        ),
      );
      expect(find.byKey(targetKey), findsOneWidget);
    });

    testWidgets('renders correct navigation stack w/multi-page',
        (tester) async {
      const box1Key = Key('__target1__');
      const box2Key = Key('__target2__');
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            state: 0,
            builder: (context, state) {
              return const <Page>[
                MaterialPage<void>(child: SizedBox(key: box1Key)),
                MaterialPage<void>(child: SizedBox(key: box2Key)),
              ];
            },
          ),
        ),
      );
      expect(find.byKey(box1Key), findsNothing);
      expect(find.byKey(box2Key), findsOneWidget);
    });

    testWidgets('renders correct navigation stack w/multi-page and condition',
        (tester) async {
      const box1Key = Key('__box1__');
      const box2Key = Key('__box2__');
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            state: 0,
            builder: (context, state) {
              return <Page>[
                const MaterialPage<void>(child: SizedBox(key: box1Key)),
                if (state >= 1)
                  const MaterialPage<void>(child: SizedBox(key: box2Key)),
              ];
            },
          ),
        ),
      );
      expect(find.byKey(box1Key), findsOneWidget);
      expect(find.byKey(box2Key), findsNothing);
    });

    testWidgets('update triggers a rebuild with correct state', (tester) async {
      const buttonKey = Key('__button__');
      const boxKey = Key('__box__');
      var numBuilds = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            state: 0,
            builder: (context, state) {
              numBuilds++;
              return <Page>[
                MaterialPage<void>(
                  child: TextButton(
                    key: buttonKey,
                    child: const Text('Button'),
                    onPressed: () => context.flow<int>().update((s) => s + 1),
                  ),
                ),
                if (state == 1)
                  const MaterialPage<void>(child: SizedBox(key: boxKey)),
              ];
            },
          ),
        ),
      );
      expect(numBuilds, 1);
      expect(find.byKey(buttonKey), findsOneWidget);
      expect(find.byKey(boxKey), findsNothing);

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      expect(numBuilds, 2);
      expect(find.byKey(buttonKey), findsNothing);
      expect(find.byKey(boxKey), findsOneWidget);
    });

    testWidgets('complete terminates the flow', (tester) async {
      const startButtonKey = Key('__start_button__');
      const completeButtonKey = Key('__complete_button__');
      var numBuilds = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  key: startButtonKey,
                  child: const Text('Button'),
                  onPressed: () async {
                    final result = await Navigator.of(context).push<int>(
                      MaterialPageRoute<int>(
                        builder: (_) => FlowBuilder<int>(
                          state: 0,
                          builder: (context, state) {
                            numBuilds++;
                            return <Page>[
                              MaterialPage<void>(
                                child: TextButton(
                                  key: completeButtonKey,
                                  child: const Text('Button'),
                                  onPressed: () => context
                                      .flow<int>()
                                      .complete((s) => s + 1),
                                ),
                              ),
                            ];
                          },
                        ),
                      ),
                    );
                    Scaffold.of(context).showSnackBar(
                      SnackBar(content: Text('Result: $result')),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byKey(startButtonKey));
      await tester.pumpAndSettle();

      expect(numBuilds, 1);

      await tester.tap(find.byKey(completeButtonKey));
      await tester.pumpAndSettle();
      await tester.pump();

      expect(numBuilds, 1);
      expect(find.text('Result: 1'), findsOneWidget);
    });

    testWidgets('back button pops parent route', (tester) async {
      const buttonKey = Key('__button__');
      const scaffoldKey = Key('__scaffold__');
      var numBuilds = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            state: 0,
            builder: (context, state) {
              numBuilds++;
              return <Page>[
                MaterialPage<void>(
                  child: Scaffold(
                    appBar: AppBar(),
                    body: TextButton(
                      key: buttonKey,
                      child: const Text('Button'),
                      onPressed: () => context.flow<int>().update((s) => s + 1),
                    ),
                  ),
                ),
                if (state == 1)
                  MaterialPage<void>(
                    child: Scaffold(
                      key: scaffoldKey,
                      appBar: AppBar(),
                    ),
                  ),
              ];
            },
          ),
        ),
      );
      expect(numBuilds, 1);
      expect(find.byKey(buttonKey), findsOneWidget);
      expect(find.byKey(scaffoldKey), findsNothing);

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      expect(numBuilds, 2);
      expect(find.byKey(buttonKey), findsNothing);
      expect(find.byKey(scaffoldKey), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      expect(numBuilds, 2);
      expect(find.byKey(buttonKey), findsOneWidget);
      expect(find.byKey(scaffoldKey), findsNothing);
    });

    testWidgets('Navigator.pop pops parent route', (tester) async {
      const button1Key = Key('__button1__');
      const button2Key = Key('__button2__');
      var numBuilds = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            state: 0,
            builder: (context, state) {
              numBuilds++;
              return <Page>[
                MaterialPage<void>(
                  child: Scaffold(
                    appBar: AppBar(),
                    body: TextButton(
                      key: button1Key,
                      child: const Text('Button'),
                      onPressed: () => context.flow<int>().update((s) => s + 1),
                    ),
                  ),
                ),
                if (state == 1)
                  MaterialPage<void>(
                    child: Scaffold(
                      appBar: AppBar(),
                      body: Builder(
                        builder: (context) => TextButton(
                          key: button2Key,
                          child: const Text('Button'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                    ),
                  ),
              ];
            },
          ),
        ),
      );
      expect(numBuilds, 1);
      expect(find.byKey(button1Key), findsOneWidget);
      expect(find.byKey(button2Key), findsNothing);

      await tester.tap(find.byKey(button1Key));
      await tester.pumpAndSettle();

      expect(numBuilds, 2);
      expect(find.byKey(button1Key), findsNothing);
      expect(find.byKey(button2Key), findsOneWidget);

      await tester.tap(find.byKey(button2Key));
      await tester.pumpAndSettle();

      expect(numBuilds, 2);
      expect(find.byKey(button1Key), findsOneWidget);
      expect(find.byKey(button2Key), findsNothing);
    });

    testWidgets('state change triggers a rebuild with correct state',
        (tester) async {
      const buttonKey = Key('__button__');
      const boxKey = Key('__box__');
      var numBuilds = 0;
      var flowState = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return FlowBuilder<int>(
                state: flowState,
                builder: (context, state) {
                  numBuilds++;
                  return <Page>[
                    MaterialPage<void>(
                      child: TextButton(
                        key: buttonKey,
                        child: const Text('Button'),
                        onPressed: () => setState(() => flowState = 1),
                      ),
                    ),
                    if (state == 1)
                      const MaterialPage<void>(child: SizedBox(key: boxKey)),
                  ];
                },
              );
            },
          ),
        ),
      );
      expect(numBuilds, 1);
      expect(find.byKey(buttonKey), findsOneWidget);
      expect(find.byKey(boxKey), findsNothing);

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      expect(numBuilds, 2);
      expect(find.byKey(buttonKey), findsNothing);
      expect(find.byKey(boxKey), findsOneWidget);
    });
  });
}
