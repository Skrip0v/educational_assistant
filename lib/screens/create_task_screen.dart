import 'package:educational_assistant/core/consts/consts.dart';
import 'package:educational_assistant/core/services/tasks_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:get/get.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final nameController = TextEditingController();
  final descController = TextEditingController();

  DateTime? date;
  final dateController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF3EDF6),
        title: const Text('Добавление задачи'),
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

              if (date == null) {
                Get.snackbar(
                  'Ошибка',
                  'Выберите дату',
                  duration: 1500.milliseconds,
                );
                return;
              }

              if (date!.isBefore(DateTime.now())) {
                Get.snackbar(
                  'Ошибка',
                  'Выберите дату в будущем времени',
                  duration: 1500.milliseconds,
                );
                return;
              }

              var tasksService = Get.find<TasksService>();
              await tasksService.createTask(
                name: nameController.text,
                desc: descController.text,
                date: date!,
              );
              Get.back();
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
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }
}
