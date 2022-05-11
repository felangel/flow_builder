import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';

enum NavigationResult {
  save,
  cancel,
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: FlowBuilder<int>(
        state: 1,
        onGeneratePages: (state, pages) => [
          const MaterialPage<dynamic>(
            child: MyHomePage(),
          ),
        ],
      ),
    );
  }
}

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(DetailsPage.route('1'));
              },
              child: const Text('Navigate with <void>'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context)
                    .push<NavigationResult?>(DetailsPage.resultRoute('1'));
              },
              child: const Text('Navigate with <NavigationResult?>'),
            ),
          ],
        ),
      ),
    );
  }
}

class DetailsPage extends StatelessWidget {
  const DetailsPage({Key? key}) : super(key: key);

  static Route<NavigationResult?> resultRoute(String id) =>
      MaterialPageRoute<NavigationResult?>(
        builder: (_) => const DetailsPage(),
        settings: const RouteSettings(name: '/test'),
      );

  static Route<void> route(String id) => MaterialPageRoute(
        builder: (_) => const DetailsPage(),
        settings: const RouteSettings(name: '/test'),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Details'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text('Details Page'),
      ),
    );
  }
}
