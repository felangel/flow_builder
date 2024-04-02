import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum AuthenticationState { authenticated, unauthenticated }

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit() : super(AuthenticationState.unauthenticated);

  void login() {
    emit(AuthenticationState.authenticated);
  }

  void logout() {
    emit(AuthenticationState.unauthenticated);
  }
}

class AuthenticationFlow extends StatelessWidget {
  const AuthenticationFlow._();

  static Route<AuthenticationState> route() {
    return MaterialPageRoute(
      builder: (_) => BlocProvider(
        create: (_) => AuthenticationCubit(),
        child: const AuthenticationFlow._(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<AuthenticationState>(
      state: context.select((AuthenticationCubit cubit) => cubit.state),
      onGeneratePages: (AuthenticationState state, List<Page<dynamic>> pages) {
        switch (state) {
          case AuthenticationState.authenticated:
            return [HomePage.page()];
          case AuthenticationState.unauthenticated:
            return [SplashPage.page()];
        }
      },
    );
  }
}

class SplashPage extends StatelessWidget {
  const SplashPage._();

  static Page<void> page() => const MaterialPage<void>(child: SplashPage._());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            context.flow<AuthenticationState>().complete();
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              child: const Text('Onboarding'),
              onPressed: () {
                Navigator.of(context).push(OnboardingPage.route());
              },
            ),
            ElevatedButton(
              child: const Text('Sign In'),
              onPressed: () {
                context.read<AuthenticationCubit>().login();
              },
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatefulWidget {
  const OnboardingPage._();
  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => const OnboardingPage._());
  }

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late FlowController<int> _controller;

  @override
  void initState() {
    super.initState();
    _controller = FlowController(0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => _controller.complete(),
        ),
      ),
      body: FlowBuilder<int>(
        controller: _controller,
        onGeneratePages: (int state, List<Page<dynamic>> pages) {
          return [
            for (var i = 0; i <= state; i++) OnboardingStep.page(i),
          ];
        },
      ),
    );
  }
}

class OnboardingStep extends StatelessWidget {
  const OnboardingStep({required this.step, super.key});

  static Page<void> page(int step) {
    return MaterialPage<void>(child: OnboardingStep(step: step));
  }

  final int step;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Step $step', style: theme.textTheme.displayLarge),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: context.flow<int>().state <= 0
                    ? null
                    : () => context.flow<int>().update((s) => s - 1),
                child: const Text('Previous'),
              ),
              TextButton(
                child: const Text('Next'),
                onPressed: () {
                  context.flow<int>().update((s) => s + 1);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage._();

  static Page<void> page() => const MaterialPage<void>(child: HomePage._());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              context.read<AuthenticationCubit>().logout();
            },
          ),
        ],
      ),
      body: const Center(child: Text('Home')),
    );
  }
}
