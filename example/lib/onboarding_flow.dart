import 'package:flutter/material.dart';
import 'package:flow_builder/flow_builder.dart';

enum OnboardingState { step1, step2, step3 }

class OnboardingFlow extends StatelessWidget {
  static Route<void> route() {
    return MaterialPageRoute(builder: (_) => OnboardingFlow());
  }

  @override
  Widget build(BuildContext context) {
    return FlowBuilder<OnboardingState>(
      state: OnboardingState.step1,
      builder: (context, state) {
        return [
          MaterialPage<void>(
            child: Scaffold(
              appBar: AppBar(),
              body: const Center(child: Text('Onboarding Step 1')),
              floatingActionButton: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  FloatingActionButton(
                    heroTag: 0,
                    onPressed: () {
                      context.flow<OnboardingState>().complete((_) => null);
                    },
                    child: const Icon(Icons.clear),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    heroTag: 1,
                    onPressed: () {
                      context
                          .flow<OnboardingState>()
                          .update((_) => OnboardingState.step2);
                    },
                    child: const Icon(Icons.arrow_forward_ios_rounded),
                  ),
                ],
              ),
            ),
          ),
          if (state.index >= 1)
            MaterialPage<void>(
              child: Scaffold(
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
                            .flow<OnboardingState>()
                            .update((_) => OnboardingState.step1);
                      },
                      child: const Icon(Icons.arrow_back_ios_rounded),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      heroTag: 3,
                      onPressed: () {
                        context
                            .flow<OnboardingState>()
                            .update((_) => OnboardingState.step3);
                      },
                      child: const Icon(Icons.arrow_forward_ios_rounded),
                    ),
                  ],
                ),
              ),
            ),
          if (state.index >= 2)
            MaterialPage<void>(
              child: Scaffold(
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
                            .flow<OnboardingState>()
                            .update((_) => OnboardingState.step2);
                      },
                      child: const Icon(Icons.arrow_back_ios_rounded),
                    ),
                    const SizedBox(width: 8),
                    FloatingActionButton(
                      heroTag: 5,
                      onPressed: () {
                        context.flow<OnboardingState>().complete((_) => null);
                      },
                      child: const Icon(Icons.check),
                    ),
                  ],
                ),
              ),
            ),
        ];
      },
    );
  }
}
