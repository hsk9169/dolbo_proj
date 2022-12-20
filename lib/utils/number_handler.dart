class NumberHandler {
  double makeDoubleFixedPoint(double value, int point) {
    final String temp = value.toStringAsFixed(point);
    return double.parse(temp);
  }

  String makeCurTimeString(String date, String time) {
    final String dateTemp = date.substring(0, 4) +
        '.' +
        date.substring(4, 6) +
        '.' +
        date.substring(6);
    final String timeTemp = time.substring(0, 2) + ':' + time.substring(2, 4);
    final String ret = dateTemp + ' ' + timeTemp + ' ' + '기준 데이터';
    return ret;
  }

  String addComma(String value) {
    String ret = '';
    final splitStr = value.split('.');
    String intStr = splitStr[0];
    String floatStr = '';
    List<String> temp = [];
    if (splitStr.length > 1) {
      floatStr = '.' + splitStr[1];
    }
    final count = intStr.length ~/ 3;
    if (count == 0) {
      ret = intStr;
    }
    final remainder = intStr.length % 3;
    for (int i = 0; i < count; i++) {
      temp.add(
          intStr.substring(intStr.length - 3 * (i + 1), intStr.length - 3 * i));
      if (i + 1 == count && remainder > 0) {
        temp.add(intStr.substring(0, remainder));
      }
    }
    temp.asMap().forEach((key, value) {
      ret = ret + temp[temp.length - key - 1];
      if (key < temp.length - 1) {
        ret = ret + ',';
      }
    });
    return ret + floatStr;
  }

  String mrymdToDate(String value) {
    final year = value.substring(0, 4);
    final month = value.substring(4, 6);
    final day = value.substring(6, 8);
    return '$year년 $month월 $day일';
  }

  String hhmiToTime(String value, int radix) {
    String ret = '';
    final hour = value.substring(0, 2);
    final min = value.substring(2, 4);
    if (radix == 12) {
      int intHour = int.parse(hour);
      String day = '';
      if (intHour > 11 && intHour < 24) {
        day = '오후';
        intHour = intHour - 12;
      } else {
        if (intHour == 24) {
          intHour = 0;
        }
        day = '오전';
      }
      ret = '$day $intHour시 $min분';
    } else if (radix == 24) {
      ret = '$hour시 $min분';
    }
    return ret;
  }

  String datetimeToString(DateTime datetime) {
    final year = datetime.year;
    int month = datetime.month;
    String monthStr = month.toString();
    int day = datetime.day;
    String dayStr = day.toString();
    if (month < 10) {
      monthStr = '0$month';
    }
    if (day < 10) {
      dayStr = '0$day';
    }
    return '$year$monthStr$dayStr';
  }

  String serverTimeToString(String value) {
    String ret;
    final date = value.substring(0, 10);
    final hour = value.substring(11, 13);
    final min = value.substring(14, 16);
    int intHour = int.parse(hour);
    String day = '';
    if (intHour > 11 && intHour < 24) {
      day = 'PM';
      intHour = intHour - 12;
    } else {
      if (intHour == 24) {
        intHour = 0;
      }
      day = 'AM';
    }
    if (intHour < 10) {
      ret = '$date 0$intHour:$min$day';
    } else {
      ret = '$date $intHour:$min$day';
    }
    return ret;
  }

  String serverTimeToChartString(String value) {
    final date = value.substring(0, 10);
    final hour = value.substring(11, 13);
    final min = value.substring(14, 16);
    int intHour = int.parse(hour);
    return '$date $intHour:$min';
  }
}
