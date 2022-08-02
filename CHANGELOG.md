# 0.0.5

- **BREAKING**: refactor: `FlowController.state` setter removed in favor of `update` ([#61](https://github.com/felangel/flow_builder/issues/61))
- fix: `FlowController` notification updates to improve back/forth navigation via `BackButton` ([#61](https://github.com/felangel/flow_builder/issues/61))
- fix: intellisense on `update` to include state argument ([#64](https://github.com/felangel/flow_builder/issues/64))
  - introduce FlowCallback typedef to improve readability and reusability
  - Thanks [@narcodico](https://github.com/narcodico) for the contribution
- fix: intellisense on `OnGeneratePages` ([#72](https://github.com/felangel/flow_builder/issues/72))
  - Thanks [@Lootwig](https://github.com/Lootwig) for the contribution

# 0.0.4

- refactor: decouple `FlowController` from `FlowBuilder`
- refactor: organize imports and minor updates
- fix: super call enforcement on listeners

# 0.0.3

- fix: respect top-level `WillPopScope`
  - A top-level `WillPopScope` can be added to prevent popping the first page in a flow

# 0.0.2

- fix: don't lose system push events and pass them to WidgetsBindings
- fix: android back button pops the whole flow instead of popping pushed routes
- feat: add web/desktop support to example app

# 0.0.1

- **BREAKING**: feat!: added support for null-safety
- feat: `FlowBuilder` supports `List<NavigatorObserver>`
- docs: update example to include custom page transitions
- docs: update example to include hero animations

# 0.0.1-nullsafety.0

- **BREAKING**: feat!: added support for null-safety

# 0.0.1-dev.13

- fix: invoke `SystemNavigator.pop()` when `FlowBuilder` is at root
  - fixes cases where system back button presses result in a black screen on Android

# 0.0.1-dev.12

- fix: `FakeFlowController` supports `complete` with no callback

# 0.0.1-dev.11

- feat: flow controller listenable

# 0.0.1-dev.10

- **BREAKING** feat!: remove `Update` and `Complete` typedefs
- feat: update `FlowController` to have a public constructor
- feat: `FlowBuilder` requires either `state` or `controller`
- feat: `FlowController` exposes `state`, `addListener`, `removeListener`, and `dispose`
- fix: support hardware back functionality on Android within nested flows
- docs: update `README` to include additional information around `FlowController` usage

# 0.0.1-dev.9

- feat: add `FakeFlowController<T>` for verifying flow interactions

# 0.0.1-dev.8

- feat: `FlowBuilder` accepts an optional `FlowController<T>`
- feat: throw `FlutterError` when `context.flow` is called outside of a `FlowBuilder`

# 0.0.1-dev.7

- **BREAKING**: update `onGeneratePages` to include previous `pages`

# 0.0.1-dev.6

- feat: add `onComplete`

# 0.0.1-dev.5

- docs: fix README badges (CORS)

# 0.0.1-dev.4

- **BREAKING**: replace `builder` with `onGeneratePages`
- fix: navigation animation
- fix: system back navigation

# 0.0.1-dev.3

- fix: pop after external state change exception
- test: 100% coverage

# 0.0.1-dev.2

- feat!: remove explicit `FlowController` from `builder`

# 0.0.1-dev.1

- feat: initial release of `FlowBuilder`
