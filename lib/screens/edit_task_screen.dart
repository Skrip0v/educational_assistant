import 'package:educational_assistant/core/consts/consts.dart';
import 'package:educational_assistant/core/models/schema.dart';
import 'package:educational_assistant/core/services/notifications_service.dart';
import 'package:educational_assistant/core/services/tasks_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get/get.dart';

class EditTaskScreen extends StatefulWidget {
  const EditTaskScreen({
    super.key,
    required this.task,
  });
  final TaskModel task;

  @override
  State<EditTaskScreen> createState() => _EditTaskScreenState();
}

class _EditTaskScreenState extends State<EditTaskScreen> {
  late TextEditingController nameController;
  late TextEditingController descController;
  late DateTime date;
  late TextEditingController dateController;

  @override
  void initState() {
    nameController = TextEditingController(text: widget.task.name);
    descController = TextEditingController(text: widget.task.description);
    date = widget.task.todoCompletedTime;

    dateController = TextEditingController(
      text:
          '${date.day} ${MONTHS_RU[date.month - 1]}, ${date.hour}:${date.minute}',
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF3EDF6),
        title: const Text('Редактирование задачи'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(15),
        children: [
          TextField(
            controller: nameController,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFFF3EDF6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
                borderSide: BorderSide.none,
              ),
              hintText: 'Название',
            ),
          ),
          const SizedBox(height: 25),
          TextField(
            controller: descController,
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFFF3EDF6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
                borderSide: BorderSide.none,
              ),
              hintText: 'Описание',
            ),
          ),
          const SizedBox(height: 25),
          TextField(
            controller: dateController,
            readOnly: true,
            onTap: () async {
              var now = DateTime.now();

              await DatePicker.showDateTimePicker(
                context,
                showTitleActions: true,
                minTime: DateTime(
                  now.year,
                  now.month,
                  now.day,
                  now.hour,
                  now.minute + 10,
                ),
                maxTime: DateTime(
                  now.year + 1,
                  now.month,
                  now.day,
                ),
                onConfirm: (date) {
                  var str =
                      '${date.day} ${MONTHS_RU[date.month - 1]}, ${date.hour}:${date.minute}';

                  setState(() {
                    this.date = date;
                    dateController.text = str;
                  });
                },
                currentTime: DateTime(
                  now.year,
                  now.month,
                  now.day,
                  now.hour,
                  now.minute + 5,
                ),
                locale: LocaleType.ru,
              );
            },
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color(0xFFF3EDF6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(15),
                ),
                borderSide: BorderSide.none,
              ),
              hintText: 'Дата',
            ),
          ),
          const SizedBox(height: 25),
          TextButton(
            onPressed: () async {
              if (nameController.text.isEmpty) {
                Get.snackbar(
                  'Ошибка',
                  'Введите название',
                  duration: 1500.milliseconds,
                );
                return;
              }

              if (descController.text.isEmpty) {
                Get.snackbar(
                  'Ошибка',
                  'Введите Описание',
                  duration: 1500.milliseconds,
                );
                return;
              }

              if (date.isBefore(DateTime.now())) {
                Get.snackbar(
                  'Ошибка',
                  'Выберите дату в будущем времени',
                  duration: 1500.milliseconds,
                );
                return;
              }

              var tasksService = Get.find<TasksService>();
              var task = widget.task;

              task.name = nameController.text;
              task.description = descController.text;
              task.todoCompletedTime = date;

              await tasksService.updateTask(task: task);

              Get.back();

              await NotificationsService.cancelNotification(task.id);

              await NotificationsService.showNotification(
                task.id,
                task.name,
                task.description,
                task.todoCompletedTime,
              );
            },
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                const Color(0xFFF3EDF6),
              ),
              shape: MaterialStateProperty.all(
                const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(8),
                  ),
                ),
              ),
            ),
            child: const Text('Редактировать'),
          ),
          const SizedBox(height: 10),
          TextButton(
            onPressed: () async {
              Get.defaultDialog(
                title: 'Удалить задачу?',
                content: const Text('Подтверди удаление задачи'),
                actions: [
                  TextButton(
                    onPressed: () async {
                      var tasksService = Get.find<TasksService>();
                      await tasksService.deleteTask(task: widget.task);
                      Get.back();
                      Get.back();
                    },
                    child: const Text(
                      'Удалить',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('Отмена'),
                  ),
                ],
              );
              return;
            },
            child: const Text(
              'Удалить',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }
}
