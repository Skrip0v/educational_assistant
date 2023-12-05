// ignore_for_file: depend_on_referenced_packages

import 'package:educational_assistant/schema.dart';
import 'package:educational_assistant/notifications_service.dart';
import 'package:educational_assistant/tasks_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';
import 'consts.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Это нужно для того, чтобы календарь был на русском языке
  await initializeDateFormatting("ru_RU", null);

  //Это нужно для корректной работы календаря
  var timeZoneName = await FlutterTimezone.getLocalTimezone();
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(timeZoneName));

  //Это инициализация сервиса(контролера), который обновляет информацию на экране
  await Get.put(TasksService()).init();

  //это инициализация уведомлений
  await NotificationsService.init();
  await NotificationsService.requestNotificationPermission();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomeScreen(),
    );
  }
}

/* ----- ДОМАШНИЙ ЭКРАН ----- */

//Это домашний экран, который содержит нижнее меню, и два остальных экрана (список всех задач и календарь)
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: tabIndex,
        children: const [
          Taskscreen(),
          CalendarScreen(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (int index) {
          setState(() {
            tabIndex = index;
          });
        },
        selectedIndex: tabIndex,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.task),
            selectedIcon: Icon(Icons.task_rounded),
            label: 'Задачи',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month),
            selectedIcon: Icon(Icons.calendar_month_sharp),
            label: 'Календарь',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.to(() => const CreateTaskScreen());
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/* ----- ВСЕ ЗАДАЧИ ЭКРАН ----- */

//Это экран со списком всех задач, прогрессом выполненных задач и так далее
class Taskscreen extends StatefulWidget {
  const Taskscreen({super.key});

  @override
  State<Taskscreen> createState() => _TaskscreenState();
}

class _TaskscreenState extends State<Taskscreen> {
  int tabBarIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF3EDF6),
        title: const Text('Все задачи'),
      ),
      body: GetBuilder<TasksService>(
        builder: (service) {
          var tasks = service.tasks;

          return ListView(
            padding: const EdgeInsets.all(15),
            children: [
              Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3EDF6),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Выполненные задачи',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            '${service.getCountDone()}/${tasks.length} выполнено',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 5),
                          Text(
                            getCurrentDate(),
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SleekCircularSlider(
                      appearance: CircularSliderAppearance(
                        animationEnabled: false,
                        angleRange: 360,
                        startAngle: 270,
                        size: 70,
                        infoProperties: InfoProperties(
                          mainLabelStyle: const TextStyle(
                            fontSize: 16,
                            color: Colors.black,
                          ),
                        ),
                        customColors: CustomSliderColors(
                          progressBarColors: <Color>[
                            Colors.blueAccent,
                            Colors.greenAccent,
                          ],
                          trackColor: Colors.grey.shade300,
                        ),
                        customWidths: CustomSliderWidths(
                          progressBarWidth: 7,
                          trackWidth: 3,
                          handlerSize: 0,
                          shadowWidth: 0,
                        ),
                      ),
                      min: 0,
                      max: 100,
                      initialValue: tasks.isEmpty
                          ? 100
                          : service.getCountDone() / tasks.length * 100,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              Builder(
                builder: (context) {
                  if (tasks.isEmpty) {
                    return Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.only(top: 25),
                      child: const Text(
                        'У тебя пока нет задач',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                    );
                  }

                  var sortedTasks = service.getSortedTasks(tabBarIndex == 1);

                  return DefaultTabController(
                    length: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        TabBar(
                          dividerColor: Colors.transparent,
                          onTap: (index) {
                            setState(() {
                              tabBarIndex = index;
                            });
                          },
                          tabs: const [
                            Tab(
                              text: 'Не выполнены',
                            ),
                            Tab(
                              text: 'Выполнены',
                            ),
                          ],
                        ),
                        sortedTasks.isEmpty
                            ? Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(top: 50),
                                child: Text(
                                  tabBarIndex == 0
                                      ? 'У тебя нет не выполненных задач'
                                      : 'У тебя нет выполненных задач',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : Column(
                                children: sortedTasks.map((task) {
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
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              value: task.done,
                                              onChanged: (v) async {
                                                if (v == null) return;
                                                task.done = v;
                                                await Get.find<TasksService>()
                                                    .updateTask(task: task);
                                                try {
                                                  if (v == true) {
                                                    await NotificationsService
                                                        .cancelNotification(
                                                            task.id);
                                                  } else {
                                                    await NotificationsService
                                                        .showNotification(
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                }).toList(),
                              ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  String getCurrentDate() {
    var now = DateTime.now();

    return '${DAYS_RU[now.weekday - 1]}, ${now.day} ${MONTHS_RU[now.month - 1]}';
  }
}

/* ----- КАЛЕНДАРЬ ЭКРАН ----- */

//Это экран с календарем, для реализации календаря используется пакет - `table_calendar`
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime selectedDay = DateTime.now();
  CalendarFormat calendarFormat = CalendarFormat.week;
  int tabBarIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color(0xFFF3EDF6),
        title: const Text('Календарь'),
      ),
      body: GetBuilder<TasksService>(builder: (service) {
        return ListView(
          padding: EdgeInsets.zero,
          children: [
            TableCalendar(
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, day, events) {
                  var count = service.getCountOfTasksAtThisDayNotDone(day);
                  return count != 0
                      ? Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: Colors.blue[300]!,
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              count.toString(),
                              style: context.textTheme.bodyLarge?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(height: 0, width: 0);
                },
              ),
              startingDayOfWeek: StartingDayOfWeek.monday,
              firstDay: DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day - 7,
              ),
              lastDay: DateTime(
                DateTime.now().year + 1,
                DateTime.now().month,
                DateTime.now().day,
              ),
              locale: const Locale('ru', 'RU').languageCode,
              focusedDay: selectedDay,
              availableCalendarFormats: const {
                CalendarFormat.month: 'месяц',
                CalendarFormat.twoWeeks: 'две недели',
                CalendarFormat.week: 'неделя',
              },
              selectedDayPredicate: (day) {
                return isSameDay(selectedDay, day);
              },
              onDaySelected: (selected, focused) {
                setState(() {
                  selectedDay = selected;
                  tabBarIndex = 0;
                });
              },
              onPageChanged: (focused) {
                setState(() {
                  selectedDay = focused;
                });
              },
              calendarFormat: calendarFormat,
              onFormatChanged: (format) {
                setState(
                  () {
                    calendarFormat = format;
                  },
                );
              },
            ),
            Builder(
              builder: (context) {
                var tasks = service.getTasksAtThisDay(selectedDay);

                if (tasks.isEmpty) {
                  return Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.only(top: 50),
                    child: const Text(
                      'У тебя нет задач на этот день',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                  );
                }

                var sortedTasks = service.getSortedTasks(tabBarIndex == 1);

                return DefaultTabController(
                  length: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 10),
                      TabBar(
                        dividerColor: Colors.transparent,
                        onTap: (index) {
                          setState(() {
                            tabBarIndex = index;
                          });
                        },
                        tabs: const [
                          Tab(
                            text: 'Не выполнены',
                          ),
                          Tab(
                            text: 'Выполнены',
                          ),
                        ],
                      ),
                      Container(
                        margin: const EdgeInsets.all(15),
                        child: sortedTasks.isEmpty
                            ? Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.only(top: 50),
                                child: Text(
                                  tabBarIndex == 0
                                      ? 'У тебя нет не выполненных задач'
                                      : 'У тебя нет выполненных задач',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 16,
                                  ),
                                ),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: sortedTasks.map((task) {
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
                                              materialTapTargetSize:
                                                  MaterialTapTargetSize
                                                      .shrinkWrap,
                                              value: task.done,
                                              onChanged: (v) async {
                                                if (v == null) return;
                                                task.done = v;
                                                await Get.find<TasksService>()
                                                    .updateTask(task: task);
                                                try {
                                                  if (v == true) {
                                                    await NotificationsService
                                                        .cancelNotification(
                                                            task.id);
                                                  } else {
                                                    await NotificationsService
                                                        .showNotification(
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
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
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
                                }).toList(),
                              ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        );
      }),
    );
  }
}

/* ----- СОЗДАНИЕ ЗАДАЧИ ЭКРАН ----- */

//Это экран с созданием задачи
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

/* ----- РЕДАКТИРОВАНИЕ (И УДАЛЕНИЕ) ЗАДАЧИ ЭКРАН ----- */

//Это экран с редактированием задачи
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
