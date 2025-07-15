abstract class Failure {
  String get message;
}

class ServerError extends Failure {
  final String error;

  ServerError({required this.error});

  @override
  String get message => error;
}
