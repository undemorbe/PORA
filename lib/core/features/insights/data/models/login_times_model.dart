/// DTO ответа `GET /user/statistics/login_times`.
/// Body: `{ "login-times": [unixSeconds, ...] }` — порядок убывающий,
/// только последняя неделя. Формат времени — unix seconds (int).
class LoginTimesModel {
  const LoginTimesModel({required this.unixSeconds});

  final List<int> unixSeconds;

  factory LoginTimesModel.fromJson(Map<String, dynamic> json) {
    final list = json['login-times'] as List?;
    return LoginTimesModel(
      unixSeconds: (list ?? const [])
          .whereType<num>()
          .map((n) => n.toInt())
          .toList(),
    );
  }

  List<DateTime> toDateTimes() =>
      unixSeconds.map((s) => DateTime.fromMillisecondsSinceEpoch(s * 1000)).toList();
}
