import 'package:educational_assistant/core/consts/consts.dart';
import 'package:educational_assistant/core/models/schema.dart';
import 'package:educational_assistant/core/services/tasks_service.dart';
import 'package:educational_assistant/widgets/task_widget.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:sleek_circular_slider/sleek_circular_slider.dart';

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
                                children: sortedTasks
                                    .map((e) => TaskWidget(task: e))
                                    .toList(),
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
