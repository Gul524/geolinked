class DateFormat {
  static String getDateOrTime(DateTime? time) {
    if (time == null) {
      return "--:--";
    }
    if (DateTime.now() == time) {
      return "${time.hour} : ${time.minute}";
    }
    return "${time.day}/${time.month}/${time.year}";
  }
}
