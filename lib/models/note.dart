import 'package:flutter/cupertino.dart';

class Notes with ChangeNotifier {
  final String id;
  final String title;
  final String content;
  final String dateTime;

  Notes(
      {@required this.title,
      @required this.id,
      @required this.content,
      @required this.dateTime});
}
