import 'package:intl/intl.dart';

extension TimeExtensions on DateTime {
  String get toFormattedDate {
    DateFormat formatter = DateFormat("dd/MM/yyyy");
    return formatter.format(this);
  }

  String get dayName {
    List<String> days = ["mon", "tue", "wed", "thurs", "fri", "sat", "sun"];
    return days[weekday - 1];
  }
}
