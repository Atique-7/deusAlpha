import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:productivity_monster/db/db_helper.dart';
import 'package:productivity_monster/models/task.dart';
import 'package:timezone/timezone.dart' as tz;

class TaskController extends GetxController {
  @override
  void onReady() {
    super.onReady();
  }

  var taskList = <Task>[].obs;
  var cleanUpTaskList = <Task>[].obs;

  //add task to database.
  Future<int> addTask({Task? task}) async {
    return await DBHelper.insert(task);
  }

  //get all the tasks from database.
  void getTasks() async {
    // Fill array for assessment.
    List<Map<String, dynamic>> preCleanUp = await DBHelper.query();
    cleanUpTaskList.assignAll(preCleanUp.map((data) => new Task.fromJson(data)).toList());

    if(cleanUpTaskList.isNotEmpty) {
      for (var task in taskList) {

        // Get the date of this particular task.
        DateTime taskDate = DateFormat.yMd().parse(task.date!);
        var pickedTime = DateTime(taskDate.year, taskDate.month, taskDate.day);

        // get today's date.
        DateTime today = DateTime.now();
        var todayTime = DateTime(today.year, today.month, today.day);

        // Compare Dates.
        var comparison = pickedTime.compareTo(todayTime);

        // Delete if the comparison says (-1).
        if(comparison == -1) DBHelper.delete(task);
      }
    }

    // re-fill the taskList array.
    List<Map<String, dynamic>> postCleanUp = await DBHelper.query();
    taskList.assignAll(postCleanUp.map((data) => new Task.fromJson(data)).toList());

    print(taskList.length);

  }

  void delete(Task task) {
    DBHelper.delete(task);
    EasyLoading.showError("Task Deleted",
        duration: const Duration(milliseconds: 500),
        dismissOnTap: true
    );
    getTasks();
  }

  void setTaskComplete(int id) async {
    await DBHelper.update(id);
    getTasks();
  }

}
