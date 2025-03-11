import 'package:intl/intl.dart';

class Convert {
  String convertDate(String date) {
    DateTime parsedDate = DateTime.parse(date);

    String formattedDate = DateFormat(
      'dd MMMM yyyy',
    ).format(parsedDate);

    return formattedDate;
  }
}
