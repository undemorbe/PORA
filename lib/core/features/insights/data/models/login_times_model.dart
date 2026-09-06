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
          .map(_toUnixSeconds)
          .whereType<int>()
          .toList(),
    );
  }

  List<DateTime> toDateTimes() => unixSeconds
      .map((s) => DateTime.fromMillisecondsSinceEpoch(s * 1000))
      .toList();

  static int? _toUnixSeconds(Object? value) {
    if (value is num) {
      final timestamp = value.toInt();
      return timestamp.abs() >= 100000000000 ? timestamp ~/ 1000 : timestamp;
    }
    if (value is String) {
      final numeric = num.tryParse(value);
      if (numeric != null) return _toUnixSeconds(numeric);
      final date = DateTime.tryParse(value);
      if (date != null) return date.millisecondsSinceEpoch ~/ 1000;
    }
    return null;
  }
}
