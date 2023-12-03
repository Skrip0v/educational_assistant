import 'package:isar/isar.dart';
part 'schema.g.dart';

@collection
class TaskModel {
  Id id;
  String name;
  String description;
  DateTime todoCompletedTime;
  bool done;

  TaskModel({
    this.id = Isar.autoIncrement,
    required this.name,
    this.description = '',
    required this.todoCompletedTime,
    this.done = false,
  });

  TaskModel.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        name = json['name'],
        description = json['description'] ?? '',
        todoCompletedTime = DateTime.fromMicrosecondsSinceEpoch(
          json['todoCompletedTime'],
          isUtc: true,
        ).toLocal(),
        done = json['done'] ?? false;

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'todoCompletedTime': todoCompletedTime.toUtc().millisecondsSinceEpoch,
        'done': done,
      };
}
