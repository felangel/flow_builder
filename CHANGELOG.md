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
