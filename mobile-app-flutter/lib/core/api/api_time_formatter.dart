String formatLegacyApiTimestamp(DateTime now) {
  final DateTime local = now.toLocal();
  final String day = local.day.toString().padLeft(2, '0');
  final String month = local.month.toString().padLeft(2, '0');
  final String year = local.year.toString();

  final int hour12 = local.hour % 12 == 0 ? 12 : local.hour % 12;
  final String hour = hour12.toString().padLeft(2, '0');
  final String minute = local.minute.toString().padLeft(2, '0');
  final String second = local.second.toString().padLeft(2, '0');

  final Duration offset = local.timeZoneOffset;
  final String sign = offset.isNegative ? '-' : '+';
  final int totalMinutes = offset.inMinutes.abs();
  final String offsetHours = (totalMinutes ~/ 60).toString().padLeft(2, '0');
  final String offsetMinutes = (totalMinutes % 60).toString().padLeft(2, '0');

  return '$day.$month.$year $hour.$minute.$second $sign$offsetHours$offsetMinutes';
}
