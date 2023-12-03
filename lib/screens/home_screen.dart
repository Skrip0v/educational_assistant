import 'package:educational_assistant/screens/calendar_screen.dart';
import 'package:educational_assistant/screens/create_task_screen.dart';
import 'package:educational_assistant/screens/tasks_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
