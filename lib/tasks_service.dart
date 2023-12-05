import 'package:educational_assistant/schema.dart';
import 'package:educational_assistant/notifications_service.dart';
import 'package:get/get.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

//Это сервис (или контроллер) который отвечает за обновление информации на экране (без него никак)
class TasksService extends GetxController {
  //Это лист задач
  List<TaskModel> tasks = [];
  //Это isar (база данных - https://pub.dev/packages/isar)
  late Isar isar;

  //Инициализация этого сервиса (вызывает в main())
  Future<void> init() async {
    //Инициалазция базы данных
    await _isarInit();
    //Получение списказ задач из базы данных
    tasks = await isar.taskModels.where().findAll();
  }

  //Инициалазция базы данных
  Future<void> _isarInit() async {
    isar = await Isar.open(
      [
        TaskModelSchema,
      ],
      directory: (await getApplicationSupportDirectory()).path,
    );
  }

  //Эта функция возвращает количество завершенных задач
  int getCountDone() {
    var count = 0;

    for (var e in tasks) {
      if (e.done) count++;
    }

    return count;
  }

  //Эта функция вызывается при создании задачи
  Future<void> createTask({
    required String name,
    required String desc,
    required DateTime date,
  }) async {
    int id = 0;

    //Сохранение задачи в базу данных
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

    //После успешного добавление задачи, обновляем список задач
    tasks = await isar.taskModels.where().findAll();
    //Обновляем информацию на экране, без update() обновление не произойдет
    update();

    //Тут планируем уведомление, на время, которое указали при создании задачи
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

  //Редактирование задачи
  Future<void> updateTask({
    required TaskModel task,
  }) async {
    //Сохранение новой информации о задачи
    await isar.writeTxn(() async {
      await isar.taskModels.put(task);
    });

    //Обновление списка задач, после успешного редактирования
    tasks = await isar.taskModels.where().findAll();
    update();
  }

  //Эта функция возвращает лист задач. Если передано isDone = true, то возвращает список всех
  //выполненных задач, а если isDone = false, то список не выполненных задач
  List<TaskModel> getSortedTasks(bool isDone) {
    if (isDone) {
      return tasks.where((element) => element.done).toList();
    }

    return tasks.where((element) => !element.done).toList();
  }

  //Эта функция возвращает количество задач в определенный день. Функция нужна для
  //календаря, чтобы вывести список задач за выбранный день
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

  //А эта функция возвращает уже сам лист задач за определенный день, а не количество задач
  //как в прошлой функции
  List<TaskModel> getTasksAtThisDay(DateTime date) {
    return tasks.where((e) {
      var d = e.todoCompletedTime;
      return d.year == date.year && d.month == date.month && d.day == date.day;
    }).toList();
  }

  //Это удаление задачи
  Future<void> deleteTask({
    required TaskModel task,
  }) async {
    //Удаление задачи из базы данных
    await isar.writeTxn(() async {
      await isar.taskModels.delete(task.id);
    });

    //обновление списка задач
    tasks = await isar.taskModels.where().findAll();
    update();

    //Отмена запланированного уведомления, так как задача удалена
    await NotificationsService.cancelNotification(task.id);
  }
}
