import 'package:parse_server_sdk/parse_server_sdk.dart';

class Task {
  String objectId;
  String title;
  DateTime dueDate;
  bool isCompleted;

  Task({required this.objectId, required this.title, required this.dueDate, required this.isCompleted});

  static Task fromParse(ParseObject object) {
    return Task(
      objectId: object.objectId!,
      title: object.get<String>('title')!,
      dueDate: object.get<DateTime>('dueDate')!,
      isCompleted: object.get<bool>('isCompleted')!,
    );
  }
  Task copyWith({String? title, DateTime? dueDate, bool? isCompleted, String? objectId}) {
    return Task(
      title: title ?? this.title,
      dueDate: dueDate ?? this.dueDate,
      isCompleted: isCompleted ?? this.isCompleted, objectId: objectId ?? this.objectId,
    );
  }
}
