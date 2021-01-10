import 'package:flutter/material.dart';
import 'package:flow_builder/flow_builder.dart';

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
    return const FlowBuilder<OnboardingSteps>(
      state: OnboardingSteps.step1,
      onGeneratePages: onGenerateOnboardingPages,
    );
  }
}

class Step1 extends StatelessWidget {
  static MaterialPage<void> page() => MaterialPage<void>(child: Step1());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () => context.flow<OnboardingSteps>().complete(),
        ),
      ),
      body: const Center(child: Text('Onboarding Step 1')),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 0,
            onPressed: context.flow<OnboardingSteps>().complete,
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
  static MaterialPage<void> page() => MaterialPage<void>(child: Step2());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('Onboarding Step 2')),
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
  static MaterialPage<void> page() => MaterialPage<void>(child: Step3());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: const Center(child: Text('Onboarding Step 3')),
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
            onPressed: context.flow<OnboardingSteps>().complete,
            child: const Icon(Icons.check),
          ),
        ],
      ),
    );
  }
}
