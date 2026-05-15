class DateFormat {
  static String getDateOrTime(DateTime? time) {
    if (time == null) {
      return "--:--";
    }
    final now = DateTime.now();
    if (now.day == time.day &&
        now.month == time.month &&
        now.year == time.year) {
      return "${time.hour} : ${time.minute}";
    }
    return "${time.day}/${time.month}/${time.year}";
  }
}
