// return today's date formatted as yyyymmdd
String todaysDateFormatted() {
  // today
  var dateTimeObject = DateTime.now();

  // year in the format yyyy
  String year = dateTimeObject.year.toString();

  // month in the format mm
  String month = dateTimeObject.month.toString();
  if (month.length == 1) {
    month = '0$month';
  }

  // day in the format dd
  String day = dateTimeObject.day.toString();
  if (day.length == 1) {
    day = '0$day';
  }

  // final format
  String yyyymmdd = year + month + day;

  return yyyymmdd;
}

// return a DateTime object representing the given date in yyyymmdd format

  DateTime createDateTimeObject(String yyyymmdd){
    // year
    int yyyy = int.parse(yyyymmdd.substring(0, 4));

    // month
    int mm = int.parse(yyyymmdd.substring(4, 6));

    // day
    int dd = int.parse(yyyymmdd.substring(6, 8));

    // create DateTime object
    DateTime dateTimeObject = DateTime(yyyy, mm, dd);

    return dateTimeObject;
  }

// convert DateTime object to string yyyymmdd
String convertDateTimeToString(DateTime dateTime) {
    // year in the format yyyy
    String year = dateTime.year.toString();

    // month in the format mm
    String month = dateTime.month.toString();
    if (month.length == 1) {
        month = '0$month';
    }

    // day in the format dd
    String day = dateTime.day.toString();
    if (day.length == 1) {
        day = '0$day';
    }

    // final format
    String yyyymmdd = year + month + day;

    return yyyymmdd;
}
