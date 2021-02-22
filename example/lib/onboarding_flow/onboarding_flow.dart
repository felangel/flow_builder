import 'package:flutter/material.dart';
import 'package:flow_builder/flow_builder.dart';

const _onboardingInfoTag = 'onboarding_info';

List<Page> onGenerateOnboardingPages(OnboardingSteps state, List<Page> pages) {
  switch (state) {
    case OnboardingSteps.step1:
      return [Step1.page()];
    case OnboardingSteps.step2:
      return [Step1.page(), Step2.page()];
    case OnboardingSteps.step3:
      return [Step1.page(), Step2.page(), Step3.page()];
    default:
      return [Step1.page()];
  }
}

enum OnboardingSteps { step1, step2, step3 }

class OnboardingFlow extends StatelessWidget {
  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => OnboardingFlow());
  }

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<OnboardingSteps>(
      observers: [HeroController()],
      state: OnboardingSteps.step1,
      onGeneratePages: onGenerateOnboardingPages,
    );
  }
}

class Step1 extends StatelessWidget {
  static Page<void> page() => MyPage<void>(child: Step1());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.flow<OnboardingSteps>().complete(),
        ),
      ),
      body: Stack(
        children: [
          const Center(child: Text('Onboarding Step 1')),
          Positioned(
            top: 10,
            right: 10,
            child: FloatingActionButton(
              heroTag: _onboardingInfoTag,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.info),
              onPressed: () {},
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 0,
            onPressed: () => context.flow<OnboardingSteps>().complete(),
            child: const Icon(Icons.clear),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            heroTag: 1,
            onPressed: () {
              context
                  .flow<OnboardingSteps>()
                  .update((previous) => OnboardingSteps.step2);
            },
            child: const Icon(Icons.arrow_forward_ios_rounded),
          ),
        ],
      ),
    );
  }
}

class Step2 extends StatelessWidget {
  static Page<void> page() => MyPage<void>(child: Step2());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green,
      appBar: AppBar(),
      body: Stack(
        children: [
          const Center(child: Text('Onboarding Step 2')),
          Positioned(
            top: 10,
            left: 10,
            child: FloatingActionButton(
              heroTag: _onboardingInfoTag,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.info),
              onPressed: () {},
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 2,
            onPressed: () {
              context
                  .flow<OnboardingSteps>()
                  .update((_) => OnboardingSteps.step1);
            },
            child: const Icon(Icons.arrow_back_ios_rounded),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            heroTag: 3,
            onPressed: () {
              context
                  .flow<OnboardingSteps>()
                  .update((_) => OnboardingSteps.step3);
            },
            child: const Icon(Icons.arrow_forward_ios_rounded),
          ),
        ],
      ),
    );
  }
}

class Step3 extends StatelessWidget {
  static Page<void> page() => MyPage<void>(child: Step3());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orange,
      appBar: AppBar(),
      body: Stack(
        children: [
          const Center(child: Text('Onboarding Step 3')),
          Positioned(
            bottom: 40,
            left: 10,
            child: FloatingActionButton(
              heroTag: _onboardingInfoTag,
              backgroundColor: Colors.orange,
              child: const Icon(Icons.info),
              onPressed: () {},
            ),
          ),
        ],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 4,
            onPressed: () {
              context
                  .flow<OnboardingSteps>()
                  .update((_) => OnboardingSteps.step2);
            },
            child: const Icon(Icons.arrow_back_ios_rounded),
          ),
          const SizedBox(width: 8),
          FloatingActionButton(
            heroTag: 5,
            onPressed: () => context.flow<OnboardingSteps>().complete(),
            child: const Icon(Icons.check),
          ),
        ],
      ),
    );
  }
}

class MyPage<T> extends Page<T> {
  const MyPage({required this.child, LocalKey? key}) : super(key: key);

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
