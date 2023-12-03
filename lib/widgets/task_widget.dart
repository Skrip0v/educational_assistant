import 'package:educational_assistant/core/consts/consts.dart';
import 'package:educational_assistant/core/models/schema.dart';
import 'package:educational_assistant/core/services/notifications_service.dart';
import 'package:educational_assistant/core/services/tasks_service.dart';
import 'package:educational_assistant/screens/edit_task_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class TaskWidget extends StatelessWidget {
  const TaskWidget({
    super.key,
    required this.task,
  });

  final TaskModel task;

  @override
  Widget build(BuildContext context) {
    var date = task.todoCompletedTime;

    return GestureDetector(
      onTap: () {
        Get.to(() => EditTaskScreen(task: task));
      },
      child: Container(
        margin: const EdgeInsets.only(top: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFF3EDF6),
          borderRadius: BorderRadius.circular(18),
        ),
        padding: const EdgeInsets.all(15),
        child: Row(
          children: [
            SizedBox(
              width: 30,
              height: 30,
              child: Checkbox(
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                value: task.done,
                onChanged: (v) async {
                  if (v == null) return;
                  task.done = v;
                  await Get.find<TasksService>().updateTask(task: task);
                  try {
                    if (v == true) {
                      await NotificationsService.cancelNotification(task.id);
                    } else {
                      await NotificationsService.showNotification(
                        task.id,
                        task.name,
                        task.description,
                        task.todoCompletedTime,
                      );
                    }
                  } catch (e) {}
                },
              ),
            ),
            const SizedBox(width: 7.5),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    task.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2.5),
                  Text(
                    '${date.day} ${MONTHS_RU[date.month - 1]}, ${DAYS_RU[date.weekday - 1]} в ${date.hour}:${date.minute}',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 2.5),
                  Text(
                    task.description,
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
