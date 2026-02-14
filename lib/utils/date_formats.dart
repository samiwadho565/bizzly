class DateFormats {
  DateFormats._();

  static String yyyyMmDd(DateTime date) {
    final String y = date.year.toString().padLeft(4, '0');
    final String m = date.month.toString().padLeft(2, '0');
    final String d = date.day.toString().padLeft(2, '0');
    return '$y-$m-$d';
  }

  static String dMonY(DateTime date) {
    final String day = date.day.toString();
    final String mon = _monthName(date.month);
    final String y = date.year.toString();
    return '$day $mon $y';
  }

  static String hMmAmPm(DateTime date) {
    final int h24 = date.hour;
    int h = h24 % 12;
    if (h == 0) h = 12;
    final String m = date.minute.toString().padLeft(2, '0');
    final String ampm = h24 >= 12 ? 'PM' : 'AM';
    return '$h:$m $ampm';
  }

  static String hMmAmPmDMonY(DateTime date) {
    return '${hMmAmPm(date)} ${dMonY(date)}';
  }

  static String _monthName(int m) {
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'
    ];
    if (m < 1 || m > 12) return '';
    return months[m - 1];
  }
}
