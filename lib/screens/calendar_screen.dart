import 'package:educational_assistant/core/services/tasks_service.dart';
import 'package:educational_assistant/widgets/task_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';

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
                                children: sortedTasks
                                    .map((e) => TaskWidget(task: e))
                                    .toList(),
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
