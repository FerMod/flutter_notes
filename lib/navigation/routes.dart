// Routes
abstract class RoutePath {
  String get location;
}

class SettingsPath extends RoutePath {
  @override
  String get location => '/settings';
}

class HomePath extends RoutePath {
  @override
  String get location => '/';
}

class QuizPath extends RoutePath {
  final int id;

  QuizPath(this.id);

  @override
  String get location => '/quiz/$id';
}
