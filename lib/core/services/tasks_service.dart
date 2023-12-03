import 'dart:math';

import 'package:educational_assistant/core/models/schema.dart';
import 'package:educational_assistant/core/services/notifications_service.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

class TasksService extends GetxController {
  List<TaskModel> tasks = [];
  late Isar isar;

  Future<void> init() async {
    await _isarInit();
    tasks = await isar.taskModels.where().findAll();
  }

  Future<void> _isarInit() async {
    isar = await Isar.open(
      [
        TaskModelSchema,
      ],
      directory: (await getApplicationSupportDirectory()).path,
    );
  }

  int getCountDone() {
    var count = 0;

    for (var e in tasks) {
      if (e.done) count++;
    }

    return count;
  }

  Future<void> createTask({
    required String name,
    required String desc,
    required DateTime date,
  }) async {
    int id = 0;
    await isar.writeTxn(() async {
      id = await isar.taskModels.put(
        TaskModel(
          name: name,
          done: false,
          description: desc,
          todoCompletedTime: date,
        ),
      );
    });

    tasks = await isar.taskModels.where().findAll();
    update();

    await NotificationsService.showNotification(
      id,
      name,
      desc,
      DateTime(
        date.year,
        date.month,
        date.day,
        date.hour,
        date.minute,
        0,
      ),
    );
  }

  Future<void> updateTask({
    required TaskModel task,
  }) async {
    await isar.writeTxn(() async {
      await isar.taskModels.put(task);
    });

    tasks = await isar.taskModels.where().findAll();
    update();
  }

  List<TaskModel> getSortedTasks(bool isDone) {
    if (isDone) {
      return tasks.where((element) => element.done).toList();
    }

    return tasks.where((element) => !element.done).toList();
  }

  int getCountOfTasksAtThisDayNotDone(DateTime date) {
    return tasks
        .where((e) {
          var d = e.todoCompletedTime;
          return d.year == date.year &&
              d.month == date.month &&
              d.day == date.day &&
              e.done == false;
        })
        .toList()
        .length;
  }

  List<TaskModel> getTasksAtThisDay(DateTime date) {
    return tasks.where((e) {
      var d = e.todoCompletedTime;
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).toList();
  }

  Future<void> deleteTask({
    required TaskModel task,
  }) async {
    await isar.writeTxn(() async {
      await isar.taskModels.delete(task.id);
    });

    tasks = await isar.taskModels.where().findAll();
    update();

    await NotificationsService.cancelNotification(task.id);
  }
}
