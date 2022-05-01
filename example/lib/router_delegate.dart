import 'package:equatable/equatable.dart';
import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'main.dart';
import 'navigation_cubit.dart';

List<Page> onGeneratePages(NavigationState state, List<Page> pages) {
  if (state.deepLink == null) {
    return [Home.page()];
  } else {
    return [Home.page(), resolveAppRoute(state.deepLink!)];
  }
}

class AppRouterDelegate extends RouterDelegate<AppRoute>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<AppRoute> {
  AppRouterDelegate() : navigatorKey = GlobalKey<NavigatorState>();

  @override
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  AppRoute get currentConfiguration {
    return AppRoute();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<NavigationCubit>().state;
    return FlowBuilder<NavigationState>(
      state: state,
      onGeneratePages: (state, pages) => onGeneratePages(
        state,
        [],
      ),
      observers: [
        AppNavigatorObserver(
          onPop: () {
            navigatorKey.currentContext?.read<NavigationCubit>().clearRoute();
          },
        )
      ],
      key: navigatorKey,
    );
  }

  @override
  Future<bool> popRoute() {
    return super.popRoute();
  }

  @override
  Future<void> setNewRoutePath(AppRoute configuration) async {
    if (configuration.targetPage == TargetPage.home) {
      navigatorKey.currentContext?.read<NavigationCubit>().clearRoute();
    } else {
      navigatorKey.currentContext
          ?.read<NavigationCubit>()
          .setRoute(configuration);
    }

    notifyListeners();
  }
}

class AppNavigatorObserver extends NavigatorObserver {
  AppNavigatorObserver({required this.onPop});

  final VoidCallback onPop;

  @override
  void didPop(Route route, Route? previousRoute) {
    if (route.settings.name?.contains('room') == true) {
      onPop(); // clears the deep link route
    }
  }
}

enum TargetPage {
  home,
  room,
}

typedef PageBuilder = Page Function();

/// Class describing the current page-based route in the application
class AppRoute extends Equatable {
  const AppRoute({
    this.targetPage = TargetPage.home,
    this.id,
    this.uri,
  }) : assert(
          (targetPage == TargetPage.home && id == null) ||
              (targetPage != TargetPage.home && id != null),
          'id needs to be provided for targets different than home',
        );

  const AppRoute.room({
    required this.id,
    required this.uri,
  }) : targetPage = TargetPage.room;

  final TargetPage targetPage;
  final String? id;
  final Uri? uri;

  bool isEquivalentToRoute(Route route) {
    return route.settings.name == uri.toString();
  }

  @override
  List<Object?> get props => [targetPage, id, uri];
}

Page resolveAppRoute(AppRoute appRoute) {
  switch (appRoute.targetPage) {
    case TargetPage.home:
      return Home.page();

    case TargetPage.room:
      return RoomPage.page(appRoute.id!);
  }
}

class AppRouteInformationParser extends RouteInformationParser<AppRoute> {
  @override
  Future<AppRoute> parseRouteInformation(
      RouteInformation routeInformation) async {
    if (routeInformation.location != null) {
      final uri = Uri.parse(routeInformation.location!);
      if (uri.pathSegments.length > 1) {
        switch (uri.pathSegments[0]) {
          case 'room':
            return AppRoute(
              targetPage: TargetPage.room,
              id: uri.pathSegments[1],
              uri: uri,
            );
        }
      }
    }
    return AppRoute();
  }
}

class RoomPage extends StatelessWidget {
  const RoomPage({Key? key, required this.id}) : super(key: key);

  static Route route(String id) {
    return MaterialPageRoute<void>(
      builder: (_) => RoomPage(id: id),
      settings: RouteSettings(name: '/room/$id'),
    );
  }

  static Page page(String id) {
    return MaterialPage<void>(
      child: RoomPage(id: id),
      name: '/room/$id',
    );
  }

  final String id;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Room $id'),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push<void>(RoomPage.route('$id$id'));
              },
              child: Text('Navigate to room $id$id'),
            )
          ],
        ),
      ),
    );
  }
}
