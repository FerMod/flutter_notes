import 'package:flutter/material.dart';

import 'screens/notes_list.dart';
import 'screens/settings.dart';
import 'screens/sign_in.dart';
import 'screens/sign_up.dart';
import 'src/utils/device_type.dart';

class AppRoute {
  static const String notes = '/notes';
  static const String settings = '/settings';
  static const String signIn = '/signIn';
  static const String signUp = '/signUp';

  static Map<String, WidgetBuilder> routes = <String, WidgetBuilder>{
    notes: (context) => NotesListScreen(),
    settings: (context) => const SettingsScreen(),
    signIn: (context) => const SignInScreen(),
    signUp: (context) => const SignUpScreen(),
  };
}

typedef PathWidgetBuilder = Widget Function(BuildContext, String?);

class Path {
  const Path(this.pattern, this.builder);

  /// A RegEx string for route matching.
  final String pattern;

  /// The builder for the associated pattern route. The first argument is the
  /// [BuildContext] and the second argument a RegEx match if that is included
  /// in the pattern.
  ///
  /// ```dart
  /// Path(
  ///   'r'^/demo/([\w-]+)$',
  ///   (context, matches) => Page(argument: match),
  /// )
  /// ```
  final PathWidgetBuilder builder;
}

class RouteConfiguration {
  /// List of [Path] to for route matching. When a named route is pushed with
  /// [Navigator.pushNamed], the route name is matched with the [Path.pattern]
  /// in the list below. As soon as there is a match, the associated builder
  /// will be returned. This means that the paths higher up in the list will
  /// take priority.
  static List<Path> paths = [
    Path(
      r'^' + AppRoute.notes,
      (context, match) => NotesListScreen(),
    ),
    Path(
      r'^' + AppRoute.settings,
      (context, match) => const SettingsScreen(),
    ),
    Path(
      r'^' + AppRoute.signIn,
      (context, match) => const SignInScreen(),
    ),
    Path(
      r'^' + AppRoute.signUp,
      (context, match) => const SignUpScreen(),
    ),
  ];

  /// The route generator callback used when the app is navigated to a named
  /// route. Set it on the [MaterialApp.onGenerateRoute] or
  /// [WidgetsApp.onGenerateRoute] to make use of the [paths] for route
  /// matching.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    for (final path in paths) {
      final regExpPattern = RegExp(path.pattern, caseSensitive: false);
      if (settings.name != null && regExpPattern.hasMatch(settings.name!)) {
        final firstMatch = regExpPattern.firstMatch(settings.name!);
        final match = firstMatch?.groupCount == 1 ? firstMatch?.group(1) : null;

        if (regExpPattern.hasMatch(AppRoute.settings)) {
          return SettingsRouteBuilder(
            builder: (context) => path.builder(context, match),
            settings: settings,
          );
        }

        if (DeviceType.isDesktopOrWeb) {
          return NoAnimationMaterialPageRoute<void>(
            builder: (context) => path.builder(context, match),
            settings: settings,
          );
        }
        return MaterialPageRoute<void>(
          builder: (context) => path.builder(context, match),
          settings: settings,
        );
      }
    }

    // If no match was found, we let [WidgetsApp.onUnknownRoute] handle it.
    return null;
  }
}

class SettingsRouteBuilder<T> extends PageRouteBuilder<T> {
  SettingsRouteBuilder({
    super.settings,
    required this.builder,
    super.transitionsBuilder,
    super.transitionDuration,
    super.reverseTransitionDuration,
    super.opaque,
    super.barrierDismissible,
    super.barrierColor,
    super.barrierLabel,
    super.maintainState,
    super.fullscreenDialog,
    super.allowSnapshotting,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
        ) {
    assert(opaque);
  }

  final WidgetBuilder builder;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    const begin = Offset(1.0, 0.0);
    const end = Offset.zero;
    const curve = Curves.easeIn;

    final tween = Tween(begin: begin, end: end);
    tween.chain(CurveTween(curve: curve));

    return SlideTransition(
      position: animation.drive(tween),
      child: child,
    );
  }
}

class NoteRouteBuilder<T> extends PageRouteBuilder<T> {
  NoteRouteBuilder({
    super.settings,
    required this.builder,
    super.transitionsBuilder,
    super.transitionDuration = const Duration(milliseconds: 400),
    super.reverseTransitionDuration = const Duration(milliseconds: 400),
    super.opaque,
    super.barrierDismissible,
    super.barrierColor,
    super.barrierLabel,
    super.maintainState,
    super.fullscreenDialog,
    super.allowSnapshotting,
  }) : super(
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
        ) {
    assert(opaque);
  }

  final WidgetBuilder builder;

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
    const curve = Curves.easeIn;
    final tween = CurveTween(curve: curve);
    return FadeTransition(
      opacity: animation.drive(tween),
      child: child,
    );
  }
}

class NoAnimationMaterialPageRoute<T> extends MaterialPageRoute<T> {
  NoAnimationMaterialPageRoute({
    required super.builder,
    super.settings,
    super.maintainState,
    super.fullscreenDialog,
    super.allowSnapshotting,
    super.barrierDismissible,
  });

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    return child;
  }
}
