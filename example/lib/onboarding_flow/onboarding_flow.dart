import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';

const _onboardingInfoHeroTag = '__onboarding_info_hero_tag__';

enum OnboardingState {
  initial,
  welcomeComplete,
  usageComplete,
  onboardingComplete,
}

List<Page> onGenerateOnboardingPages(OnboardingState state, List<Page> pages) {
  switch (state) {
    case OnboardingState.usageComplete:
      return [
        OnboardingWelcome.page(),
        OnboardingUsage.page(),
        OnboardingComplete.page(),
      ];
    case OnboardingState.welcomeComplete:
      return [
        OnboardingWelcome.page(),
        OnboardingUsage.page(),
      ];
    case OnboardingState.initial:
    default:
      return [OnboardingWelcome.page()];
  }
}

class OnboardingFlow extends StatelessWidget {
  static Route<OnboardingState> route() {
    return MaterialPageRoute(builder: (_) => OnboardingFlow());
  }

  @override
  Widget build(BuildContext context) {
    return FlowBuilder(
      state: OnboardingState.initial,
      observers: [HeroController()],
      onGeneratePages: onGenerateOnboardingPages,
    );
  }
}

class OnboardingWelcome extends StatelessWidget {
  static Page page() => MyPage<void>(child: OnboardingWelcome());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.yellow,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.flow<OnboardingState>().complete(),
        ),
        title: const Text('Welcome'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Welcome Text',
                    style: theme.textTheme.headline3,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: FloatingActionButton(
                heroTag: _onboardingInfoHeroTag,
                backgroundColor: Colors.orange,
                child: const Icon(Icons.info),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 0,
            onPressed: () => context.flow<OnboardingState>().complete(),
            child: const Icon(Icons.clear),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            heroTag: 1,
            onPressed: () {
              context
                  .flow<OnboardingState>()
                  .update((_) => OnboardingState.welcomeComplete);
            },
            child: const Icon(Icons.arrow_forward_ios_rounded),
          ),
        ],
      ),
    );
  }
}

class OnboardingUsage extends StatelessWidget {
  static Page page() => MyPage<void>(child: OnboardingUsage());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(title: const Text('Usage')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Usage Text',
                    style: theme.textTheme.headline3,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              child: FloatingActionButton(
                heroTag: _onboardingInfoHeroTag,
                backgroundColor: Colors.orange,
                child: const Icon(Icons.info),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 2,
            onPressed: () {
              context
                  .flow<OnboardingState>()
                  .update((_) => OnboardingState.initial);
            },
            child: const Icon(Icons.arrow_back_ios_rounded),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            heroTag: 3,
            onPressed: () {
              context
                  .flow<OnboardingState>()
                  .update((_) => OnboardingState.usageComplete);
            },
            child: const Icon(Icons.arrow_forward_ios_rounded),
          ),
        ],
      ),
    );
  }
}

class OnboardingComplete extends StatelessWidget {
  static Page page() => MyPage<void>(child: OnboardingComplete());

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.pink,
      appBar: AppBar(title: const Text('Complete')),
      body: Padding(
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'All Done!',
                    style: theme.textTheme.headline3,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 30,
              left: 10,
              child: FloatingActionButton(
                heroTag: _onboardingInfoHeroTag,
                backgroundColor: Colors.orange,
                child: const Icon(Icons.info),
                onPressed: () {},
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 4,
            onPressed: () {
              context
                  .flow<OnboardingState>()
                  .update((_) => OnboardingState.welcomeComplete);
            },
            child: const Icon(Icons.arrow_back_ios_rounded),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            heroTag: 5,
            onPressed: () => context
                .flow<OnboardingState>()
                .complete((_) => OnboardingState.onboardingComplete),
            child: const Icon(Icons.check),
          ),
        ],
      ),
    );
  }
}

class MyPage<T> extends Page<T> {
  const MyPage({required this.child, super.key});

  final Widget child;

  @override
  Route<T> createRoute(BuildContext context) {
    return PageRouteBuilder(
      settings: this,
      pageBuilder: (
        BuildContext context,
        Animation<double> animation,
        Animation<double> secondaryAnimation,
      ) {
        return FadeTransition(opacity: animation, child: child);
      },
    );
  }
}
