import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlowBuilder', () {
    test('throws when state is null and controller is null', () async {
      expect(
        () => FlowBuilder(
          onGeneratePages: (dynamic _, List<Page> __) => [],
          state: null,
          controller: null,
        ),
        throwsAssertionError,
      );
    });

    test('throws when state and controller are both provided', () async {
      expect(
        () => FlowBuilder(
          onGeneratePages: (dynamic _, List<Page> __) => [],
          state: '',
          controller: FlowController(''),
        ),
        throwsAssertionError,
      );
    });

    test('does not throw when state is null if controller is present',
        () async {
      expect(
        () => FlowBuilder(
          onGeneratePages: (dynamic _, List<Page> __) => [],
          state: null,
          controller: FlowController(''),
        ),
        isNot(throwsAssertionError),
      );
    });

    testWidgets(
        'throws FlutterError when context.flow is called '
        'outside of FlowBuilder', (tester) async {
      await tester.pumpWidget(
        Builder(builder: (context) {
          context.flow<int>();
          return const SizedBox();
        }),
      );
      final exception = await tester.takeException() as FlutterError;
      final expectedMessage = '''
        context.flow<int>() called with a context that does not contain a FlowBuilder of type int.

        This can happen if the context you used comes from a widget above the FlowBuilder.

        The context used was: Builder(dirty)
''';
      expect(exception.message, expectedMessage);
    });

    testWidgets('renders correct navigation stack w/one page', (tester) async {
      const targetKey = Key('__target__');
      var lastPages = <Page>[];
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            state: 0,
            onGeneratePages: (state, pages) {
              lastPages = pages;
              return const <Page>[
                MaterialPage<void>(child: SizedBox(key: targetKey)),
              ];
            },
          ),
        ),
      );
      expect(find.byKey(targetKey), findsOneWidget);
      expect(lastPages, isEmpty);
    });

    testWidgets('renders correct navigation stack w/multi-page',
        (tester) async {
      const box1Key = Key('__target1__');
      const box2Key = Key('__target2__');
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            state: 0,
            onGeneratePages: (state, pages) {
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
            onGeneratePages: (state, pages) {
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
      var lastPages = <Page>[];
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            state: 0,
            onGeneratePages: (state, pages) {
              numBuilds++;
              lastPages = pages;
              return <Page>[
                MaterialPage<void>(
                  child: Builder(
                    builder: (context) => TextButton(
                      key: buttonKey,
                      child: const Text('Button'),
                      onPressed: () => context.flow<int>().update((s) => s + 1),
                    ),
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
      expect(lastPages, isEmpty);

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      expect(numBuilds, 2);
      expect(find.byKey(buttonKey), findsNothing);
      expect(find.byKey(boxKey), findsOneWidget);
      expect(lastPages.length, equals(1));
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
                          onGeneratePages: (state, pages) {
                            numBuilds++;
                            return <Page>[
                              MaterialPage<void>(
                                child: Builder(
                                  builder: (context) => TextButton(
                                    key: completeButtonKey,
                                    child: const Text('Button'),
                                    onPressed: () => context
                                        .flow<int>()
                                        .complete((s) => s + 1),
                                  ),
                                ),
                              ),
                            ];
                          },
                        ),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
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

    testWidgets('complete terminates the flow with explicit same state',
        (tester) async {
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
                          onGeneratePages: (state, pages) {
                            numBuilds++;
                            return <Page>[
                              MaterialPage<void>(
                                child: Builder(
                                  builder: (context) => TextButton(
                                    key: completeButtonKey,
                                    child: const Text('Button'),
                                    onPressed: () =>
                                        context.flow<int>().complete((s) => s),
                                  ),
                                ),
                              ),
                            ];
                          },
                        ),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
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
      expect(find.text('Result: 0'), findsOneWidget);
    });

    testWidgets('complete terminates the flow with implicit same state',
        (tester) async {
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
                          onGeneratePages: (state, pages) {
                            numBuilds++;
                            return <Page>[
                              MaterialPage<void>(
                                child: Builder(
                                  builder: (context) => TextButton(
                                    key: completeButtonKey,
                                    child: const Text('Button'),
                                    onPressed: () =>
                                        context.flow<int>().complete(),
                                  ),
                                ),
                              ),
                            ];
                          },
                        ),
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
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
      expect(find.text('Result: 0'), findsOneWidget);
    });

    testWidgets('complete invokes onComplete', (tester) async {
      const startButtonKey = Key('__start_button__');
      const completeButtonKey = Key('__complete_button__');
      var numBuilds = 0;
      var onCompleteCalls = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return TextButton(
                  key: startButtonKey,
                  child: const Text('Button'),
                  onPressed: () {
                    Navigator.of(context).push<int>(
                      MaterialPageRoute<int>(
                        builder: (_) => FlowBuilder<int>(
                          state: 0,
                          onGeneratePages: (state, pages) {
                            numBuilds++;
                            return <Page>[
                              MaterialPage<void>(
                                child: Builder(
                                  builder: (context) => TextButton(
                                    key: completeButtonKey,
                                    child: const Text('Button'),
                                    onPressed: () => context
                                        .flow<int>()
                                        .complete((s) => s + 1),
                                  ),
                                ),
                              ),
                            ];
                          },
                          onComplete: onCompleteCalls.add,
                        ),
                      ),
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

      expect(onCompleteCalls, [1]);
      expect(numBuilds, 1);
      expect(find.byKey(startButtonKey), findsNothing);
      expect(find.byKey(completeButtonKey), findsOneWidget);
    });

    testWidgets('back button pops parent route', (tester) async {
      const buttonKey = Key('__button__');
      const scaffoldKey = Key('__scaffold__');
      var numBuilds = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            state: 0,
            onGeneratePages: (state, pages) {
              numBuilds++;
              return <Page>[
                MaterialPage<void>(
                  child: Builder(
                    builder: (context) => Scaffold(
                      appBar: AppBar(),
                      body: TextButton(
                        key: buttonKey,
                        child: const Text('Button'),
                        onPressed: () {
                          context.flow<int>().update((s) => s + 1);
                        },
                      ),
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

    testWidgets('system back button pops parent route', (tester) async {
      const buttonKey = Key('__button__');
      const scaffoldKey = Key('__scaffold__');
      var numBuilds = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            state: 0,
            onGeneratePages: (state, pages) {
              numBuilds++;
              return <Page>[
                MaterialPage<void>(
                  child: Builder(
                    builder: (context) => Scaffold(
                      body: TextButton(
                        key: buttonKey,
                        child: const Text('Button'),
                        onPressed: () {
                          context.flow<int>().update((s) => s + 1);
                        },
                      ),
                    ),
                  ),
                ),
                if (state == 1)
                  const MaterialPage<void>(
                    child: Scaffold(key: scaffoldKey),
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
      await TestSystemNavigationObserver.handleSystemNavigation(
        const MethodCall('pushRoute'),
      );
      await TestSystemNavigationObserver.handleSystemNavigation(
        const MethodCall('popRoute'),
      );
      await tester.pumpAndSettle();

      expect(numBuilds, 2);
      expect(find.byKey(buttonKey), findsOneWidget);
      expect(find.byKey(scaffoldKey), findsNothing);
    });

    testWidgets('system back button pops entire flow', (tester) async {
      var systemPopCallCount = 0;
      SystemChannels.platform.setMockMethodCallHandler((call) {
        if (call.method == 'SystemNavigator.pop') {
          systemPopCallCount++;
        }
        return null;
      });
      const buttonKey = Key('__button__');
      const scaffoldKey = Key('__scaffold__');
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            state: 0,
            onGeneratePages: (state, pages) {
              return <Page>[
                MaterialPage<void>(
                  child: Builder(
                    builder: (context) {
                      return Scaffold(
                        body: TextButton(
                          key: buttonKey,
                          child: const Text('Button'),
                          onPressed: () {
                            context.flow<int>().update((s) => s + 1);
                          },
                        ),
                      );
                    },
                  ),
                ),
              ];
            },
          ),
        ),
      );
      expect(find.byKey(buttonKey), findsOneWidget);
      expect(find.byKey(scaffoldKey), findsNothing);

      await TestSystemNavigationObserver.handleSystemNavigation(
        const MethodCall('popRoute'),
      );
      await tester.pumpAndSettle();

      expect(systemPopCallCount, equals(1));
    });

    testWidgets('system back button pops routes that have been pushed',
        (tester) async {
      var systemPopCallCount = 0;
      SystemChannels.platform.setMockMethodCallHandler((call) {
        if (call.method == 'SystemNavigator.pop') {
          systemPopCallCount++;
        }
        return null;
      });
      const buttonKey = Key('__button__');
      const scaffoldKey = Key('__scaffold__');
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            state: 0,
            onGeneratePages: (state, pages) {
              return <Page>[
                MaterialPage<void>(
                  child: Builder(
                    builder: (context) {
                      return Scaffold(
                        body: TextButton(
                          key: buttonKey,
                          child: const Text('Button'),
                          onPressed: () {
                            Navigator.of(context).push<void>(MaterialPageRoute(
                              builder: (context) => const Scaffold(
                                key: scaffoldKey,
                              ),
                            ));
                          },
                        ),
                      );
                    },
                  ),
                ),
              ];
            },
          ),
        ),
      );
      expect(find.byKey(buttonKey), findsOneWidget);
      expect(find.byKey(scaffoldKey), findsNothing);

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(buttonKey), findsNothing);
      expect(find.byKey(scaffoldKey), findsOneWidget);

      await TestSystemNavigationObserver.handleSystemNavigation(
        const MethodCall('popRoute'),
      );
      await tester.pumpAndSettle();

      expect(systemPopCallCount, equals(0));
      expect(find.byKey(buttonKey), findsOneWidget);
      expect(find.byKey(scaffoldKey), findsNothing);
    });

    testWidgets('system back button pops typed routes that have been pushed',
        (tester) async {
      var systemPopCallCount = 0;
      SystemChannels.platform.setMockMethodCallHandler((call) {
        if (call.method == 'SystemNavigator.pop') {
          systemPopCallCount++;
        }
        return null;
      });
      const buttonKey = Key('__button__');
      const scaffoldKey = Key('__scaffold__');
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            state: 0,
            onGeneratePages: (state, pages) {
              return <Page>[
                MaterialPage<void>(
                  child: Builder(
                    builder: (context) {
                      return Scaffold(
                        body: TextButton(
                          key: buttonKey,
                          child: const Text('Button'),
                          onPressed: () {
                            Navigator.of(context).push<String>(
                              MaterialPageRoute(
                                builder: (context) => const Scaffold(
                                  key: scaffoldKey,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ];
            },
          ),
        ),
      );
      expect(find.byKey(buttonKey), findsOneWidget);
      expect(find.byKey(scaffoldKey), findsNothing);

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      expect(find.byKey(buttonKey), findsNothing);
      expect(find.byKey(scaffoldKey), findsOneWidget);

      await TestSystemNavigationObserver.handleSystemNavigation(
        const MethodCall('popRoute'),
      );
      await tester.pumpAndSettle();

      expect(systemPopCallCount, equals(0));
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
            onGeneratePages: (state, pages) {
              numBuilds++;
              return <Page>[
                MaterialPage<void>(
                  child: Builder(
                    builder: (context) => Scaffold(
                      appBar: AppBar(),
                      body: TextButton(
                        key: button1Key,
                        child: const Text('Button'),
                        onPressed: () =>
                            context.flow<int>().update((s) => s + 1),
                      ),
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

    testWidgets(
        'navigation stack changes upon back pressed '
        'still allows future state changes to work', (tester) async {
      const buttonKey = Key('__button__');
      const scaffoldKey = Key('__scaffold__');
      var numBuilds = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            state: 0,
            onGeneratePages: (state, pages) {
              numBuilds++;
              if (state == 0) {
                return [
                  MaterialPage<void>(
                    child: Builder(
                      builder: (context) => Scaffold(
                        appBar: AppBar(),
                        body: TextButton(
                          key: buttonKey,
                          child: const Text('Button'),
                          onPressed: () {
                            context.flow<int>().update((s) => s + 1);
                          },
                        ),
                      ),
                    ),
                  ),
                ];
              }
              if (state == 1) {
                return [
                  MaterialPage<void>(
                    child: Builder(
                      builder: (context) => Scaffold(
                        appBar: AppBar(),
                        body: TextButton(
                          key: buttonKey,
                          child: const Text('Button'),
                          onPressed: () {
                            context.flow<int>().update((s) => 1);
                          },
                        ),
                      ),
                    ),
                  ),
                  MaterialPage<void>(
                    child: Scaffold(
                      key: scaffoldKey,
                      appBar: AppBar(),
                    ),
                  ),
                ];
              }
              return <Page>[];
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

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      expect(numBuilds, 3);
      expect(find.byKey(buttonKey), findsNothing);
      expect(find.byKey(scaffoldKey), findsOneWidget);
    });

    testWidgets('onComplete callback is only called once', (tester) async {
      const pageKey = Key('__page__');
      final controller = FlowController(0);
      var onCompleteCalls = <int>[];
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            controller: controller,
            onComplete: onCompleteCalls.add,
            onGeneratePages: (state, pages) {
              return <Page>[
                MaterialPage<void>(
                  child: Scaffold(
                    appBar: AppBar(),
                    body: const SizedBox(key: pageKey),
                  ),
                ),
              ];
            },
          ),
        ),
      );

      expect(find.byKey(pageKey), findsOneWidget);

      controller.complete();

      await tester.pumpAndSettle();

      expect(onCompleteCalls, equals([0]));
      expect(find.byKey(pageKey), findsOneWidget);

      controller.update((state) => state + 1);

      await tester.pumpAndSettle();

      expect(onCompleteCalls, equals([0]));
      expect(find.byKey(pageKey), findsOneWidget);
    });

    group('pushRoute', () {
      testWidgets(
          'system pushRoute is passed to WidgetsBinding if contains arguments',
          (tester) async {
        final widgetsBinding = TestWidgetsFlutterBinding.ensureInitialized();
        final observer = _TestPushWidgetsBindingObserver();
        const path = '/path';
        widgetsBinding.addObserver(observer);

        var numBuilds = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: FlowBuilder<int>(
              state: 0,
              onGeneratePages: (state, pages) {
                numBuilds++;
                return <Page>[
                  const MaterialPage<void>(
                    child: Scaffold(),
                  ),
                ];
              },
            ),
          ),
        );
        expect(numBuilds, 1);

        await TestSystemNavigationObserver.handleSystemNavigation(
          const MethodCall(
            'pushRoute',
            path,
          ),
        );
        await tester.pumpAndSettle();
        expect(observer.lastRoute, path);
        expect(observer.pushCount, 1);
        widgetsBinding.removeObserver(observer);
      });

      testWidgets(
          'system pushRoute is not passed to WidgetsBinding if empty arguments',
          (tester) async {
        final widgetsBinding = TestWidgetsFlutterBinding.ensureInitialized();
        final observer = _TestPushWidgetsBindingObserver();
        widgetsBinding.addObserver(observer);

        var numBuilds = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: FlowBuilder<int>(
              state: 0,
              onGeneratePages: (state, pages) {
                numBuilds++;
                return <Page>[
                  const MaterialPage<void>(
                    child: Scaffold(),
                  ),
                ];
              },
            ),
          ),
        );
        expect(numBuilds, 1);

        await TestSystemNavigationObserver.handleSystemNavigation(
          const MethodCall(
            'pushRoute',
            null,
          ),
        );
        await tester.pumpAndSettle();
        expect(observer.lastRoute, isNull);
        expect(observer.pushCount, 0);
        widgetsBinding.removeObserver(observer);
      });

      testWidgets('other system navigation calls are not handled',
          (tester) async {
        final widgetsBinding = TestWidgetsFlutterBinding.ensureInitialized();
        final observer = _TestPushWidgetsBindingObserver();
        widgetsBinding.addObserver(observer);

        var numBuilds = 0;
        await tester.pumpWidget(
          MaterialApp(
            home: FlowBuilder<int>(
              state: 0,
              onGeneratePages: (state, pages) {
                numBuilds++;
                return <Page>[
                  const MaterialPage<void>(
                    child: Scaffold(),
                  ),
                ];
              },
            ),
          ),
        );
        expect(numBuilds, 1);

        await TestSystemNavigationObserver.handleSystemNavigation(
          const MethodCall(
            'randomMethod',
            null,
          ),
        );
        await tester.pumpAndSettle();
        expect(observer.lastRoute, isNull);
        expect(observer.pushCount, 0);
        widgetsBinding.removeObserver(observer);
      });
    });

    testWidgets('system pop does not terminate flow', (tester) async {
      const button1Key = Key('__button1__');
      const button2Key = Key('__button2__');
      var numBuilds = 0;
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            state: 0,
            onGeneratePages: (state, pages) {
              numBuilds++;
              return <Page>[
                MaterialPage<void>(
                  child: Builder(
                    builder: (context) => Scaffold(
                      appBar: AppBar(),
                      body: TextButton(
                        key: button1Key,
                        child: const Text('Button'),
                        onPressed: () =>
                            context.flow<int>().update((s) => s + 1),
                      ),
                    ),
                  ),
                ),
                if (state == 1)
                  MaterialPage<void>(
                    child: Scaffold(
                      appBar: AppBar(),
                      body: Builder(
                        builder: (context) => const TextButton(
                          key: button2Key,
                          child: Text('Button'),
                          onPressed: SystemNavigator.pop,
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
      expect(find.byKey(button1Key), findsNothing);
      expect(find.byKey(button2Key), findsOneWidget);
    });

    testWidgets('onWillPop pops top page when there are multiple',
        (tester) async {
      const button1Key = Key('__button1__');
      const button2Key = Key('__button2__');
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            state: 0,
            onGeneratePages: (state, pages) {
              return <Page>[
                MaterialPage<void>(
                  child: Scaffold(
                    body: TextButton(
                      key: button1Key,
                      child: const Text('Button'),
                      onPressed: () {},
                    ),
                  ),
                ),
                MaterialPage<void>(
                  child: Scaffold(
                    body: TextButton(
                      key: button2Key,
                      child: const Text('Button'),
                      onPressed: () {},
                    ),
                  ),
                ),
              ];
            },
          ),
        ),
      );

      expect(find.byKey(button1Key), findsNothing);
      expect(find.byKey(button2Key), findsOneWidget);

      final willPopScope = tester.widget<WillPopScope>(
        find.byType(WillPopScope),
      );
      final result = await willPopScope.onWillPop!();
      expect(result, isFalse);

      await tester.pumpAndSettle();

      expect(find.byKey(button1Key), findsOneWidget);
      expect(find.byKey(button2Key), findsNothing);
    });

    testWidgets('onWillPop does not exist for only one page', (tester) async {
      const button1Key = Key('__button1__');
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            state: 0,
            onGeneratePages: (state, pages) {
              return <Page>[
                MaterialPage<void>(
                  child: Scaffold(
                    body: TextButton(
                      key: button1Key,
                      child: const Text('Button'),
                      onPressed: () {},
                    ),
                  ),
                ),
              ];
            },
          ),
        ),
      );

      expect(find.byKey(button1Key), findsOneWidget);
      expect(find.byType(WillPopScope), findsNothing);
    });

    testWidgets('controller change triggers a rebuild with correct state',
        (tester) async {
      const buttonKey = Key('__button__');
      const boxKey = Key('__box__');
      var numBuilds = 0;
      var controller = FlowController(0);
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return FlowBuilder<int>(
                controller: controller,
                onGeneratePages: (state, pages) {
                  numBuilds++;
                  return <Page>[
                    MaterialPage<void>(
                      child: TextButton(
                        key: buttonKey,
                        child: const Text('Button'),
                        onPressed: () => setState(
                          () => controller = FlowController(1),
                        ),
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
                onGeneratePages: (state, pages) {
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

    testWidgets('can provide a FakeFlowController', (tester) async {
      const button1Key = Key('__button1__');
      const button2Key = Key('__button2__');
      const state = 0;
      final controller = FakeFlowController<int>(state);
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            controller: controller,
            onGeneratePages: (state, pages) {
              return <Page>[
                MaterialPage<void>(
                  child: Builder(
                    builder: (context) => Column(
                      children: [
                        TextButton(
                          key: button1Key,
                          child: const Text('Button'),
                          onPressed: () {
                            context.flow<int>().update((s) => s + 1);
                          },
                        ),
                        TextButton(
                          key: button2Key,
                          child: const Text('Button'),
                          onPressed: () {
                            context.flow<int>().complete((s) => s + 1);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
          ),
        ),
      );
      await tester.tap(find.byKey(button1Key));
      expect(controller.completed, isFalse);
      expect(controller.state, equals(1));

      await tester.tap(find.byKey(button2Key));
      expect(controller.completed, isTrue);
      expect(controller.state, equals(2));
    });

    testWidgets('FakeFlowController supports complete with null callback',
        (tester) async {
      const buttonKey = Key('__button__');
      const state = 0;
      final controller = FakeFlowController<int>(state);
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            controller: controller,
            onGeneratePages: (state, pages) {
              return <Page>[
                MaterialPage<void>(
                  child: Builder(
                    builder: (context) => Column(
                      children: [
                        TextButton(
                          key: buttonKey,
                          child: const Text('Button'),
                          onPressed: () => context.flow<int>().complete(),
                        ),
                      ],
                    ),
                  ),
                ),
              ];
            },
          ),
        ),
      );
      await tester.tap(find.byKey(buttonKey));
      expect(controller.completed, isTrue);
      expect(controller.state, equals(0));
    });

    testWidgets('updates when FlowController changes', (tester) async {
      const button1Key = Key('__button1__');
      const button2Key = Key('__button2__');
      const button3Key = Key('__button3__');
      var controller = FakeFlowController(0);
      await tester.pumpWidget(
        MaterialApp(
          home: StatefulBuilder(
            builder: (context, setState) {
              return FlowBuilder<int>(
                controller: controller,
                onGeneratePages: (state, pages) {
                  return <Page>[
                    MaterialPage<void>(
                      child: Builder(
                        builder: (context) => Column(
                          children: [
                            TextButton(
                              key: button1Key,
                              child: const Text('Button'),
                              onPressed: () {
                                context.flow<int>().update((s) => s + 1);
                              },
                            ),
                            TextButton(
                              key: button2Key,
                              child: const Text('Button'),
                              onPressed: () {
                                context.flow<int>().complete((s) => s + 1);
                              },
                            ),
                            TextButton(
                              key: button3Key,
                              child: const Text('Button'),
                              onPressed: () {
                                setState(() {
                                  controller = FakeFlowController<int>(0);
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ];
                },
              );
            },
          ),
        ),
      );

      await tester.tap(find.byKey(button3Key));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(button1Key));
      await tester.tap(find.byKey(button2Key));

      expect(controller.completed, isTrue);
      expect(controller.state, equals(2));
    });

    testWidgets('accepts custom navigator observers', (tester) async {
      final observers = [NavigatorObserver(), HeroController()];
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            state: 0,
            observers: observers,
            onGeneratePages: (state, pages) {
              return const <Page>[MaterialPage<void>(child: SizedBox())];
            },
          ),
        ),
      );

      final navigators = tester.widgetList<Navigator>(find.byType(Navigator));
      expect(navigators.last.observers, equals(observers));
    });

    testWidgets('SystemNavigator.pop respects when WillPopScope returns false',
        (tester) async {
      const targetKey = Key('__target__');
      var onWillPopCallCount = 0;
      final flow = FlowBuilder<int>(
        state: 0,
        onGeneratePages: (state, pages) {
          return <Page>[
            MaterialPage<void>(
              child: Builder(
                builder: (context) => WillPopScope(
                  onWillPop: () async {
                    onWillPopCallCount++;
                    return false;
                  },
                  child: TextButton(
                    key: targetKey,
                    onPressed: () {
                      TestSystemNavigationObserver.handleSystemNavigation(
                        const MethodCall('popRoute'),
                      );
                    },
                    child: const SizedBox(),
                  ),
                ),
              ),
            )
          ];
        },
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => flow),
                );
              },
              child: const Text('X'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('X'));
      await tester.pumpAndSettle();

      expect(find.byKey(targetKey), findsOneWidget);
      await tester.tap(find.byKey(targetKey));
      await tester.pumpAndSettle();

      expect(onWillPopCallCount, equals(1));
      expect(find.byKey(targetKey), findsOneWidget);
    });

    testWidgets('SystemNavigator.pop respects when WillPopScope returns true',
        (tester) async {
      const targetKey = Key('__target__');
      var onWillPopCallCount = 0;
      final flow = FlowBuilder<int>(
        state: 0,
        onGeneratePages: (state, pages) {
          return <Page>[
            MaterialPage<void>(
              child: Builder(
                builder: (context) => WillPopScope(
                  onWillPop: () async {
                    onWillPopCallCount++;
                    return true;
                  },
                  child: TextButton(
                    key: targetKey,
                    onPressed: () {
                      TestSystemNavigationObserver.handleSystemNavigation(
                        const MethodCall('popRoute'),
                      );
                    },
                    child: const SizedBox(),
                  ),
                ),
              ),
            )
          ];
        },
      );
      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(builder: (_) => flow),
                );
              },
              child: const Text('X'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('X'));
      await tester.pumpAndSettle();

      expect(find.byKey(targetKey), findsOneWidget);
      await tester.tap(find.byKey(targetKey));
      await tester.pumpAndSettle();

      expect(onWillPopCallCount, equals(1));
      expect(find.byKey(targetKey), findsNothing);
    });

    testWidgets('updates do not trigger rebuilds of existing pages by value',
        (tester) async {
      const buttonKey = Key('__button__');
      const boxKey = Key('__box__');
      var numBuildsA = 0;
      var numBuildsB = 0;
      final pageA = MaterialPage<void>(
        child: Builder(
          builder: (context) {
            numBuildsA++;
            return TextButton(
              key: buttonKey,
              child: const Text('Button'),
              onPressed: () => context.flow<int>().update((s) => s + 1),
            );
          },
        ),
      );
      final pageB = MaterialPage<void>(
        child: Builder(
          builder: (context) {
            numBuildsB++;
            return const SizedBox(key: boxKey);
          },
        ),
      );
      await tester.pumpWidget(
        MaterialApp(
          home: FlowBuilder<int>(
            key: const ValueKey('flow'),
            state: 0,
            onGeneratePages: (state, pages) {
              return <Page>[
                pageA,
                if (state == 1) pageB,
              ];
            },
          ),
        ),
      );
      expect(numBuildsA, 1);
      expect(numBuildsB, 0);
      expect(find.byKey(buttonKey), findsOneWidget);
      expect(find.byKey(boxKey), findsNothing);

      await tester.tap(find.byKey(buttonKey));
      await tester.pumpAndSettle();

      expect(numBuildsA, 1);
      expect(numBuildsB, 1);
      expect(find.byKey(buttonKey), findsNothing);
      expect(find.byKey(boxKey), findsOneWidget);
    });
  });
}

class _TestPushWidgetsBindingObserver with WidgetsBindingObserver {
  int pushCount = 0;
  String? lastRoute;
  @override
  Future<bool> didPushRoute(String route) async {
    lastRoute = route;
    pushCount++;
    return true;
  }
}
