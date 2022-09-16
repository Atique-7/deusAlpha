import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:productivity_monster/UI/shared/button.dart';
import 'package:productivity_monster/UI/shared/input_field.dart';
import 'package:productivity_monster/controllers/task_controller.dart';
import 'package:productivity_monster/models/task.dart';
import '../task_app_scrap/theme.dart';

class AddTaskPage extends StatefulWidget {
  const AddTaskPage({Key? key}) : super(key: key);

  @override
  State<AddTaskPage> createState() => _AddTaskPageState();
}

class _AddTaskPageState extends State<AddTaskPage> {
  final TaskController _taskController = Get.put(TaskController());
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // date form
  DateTime _selectedDate = DateTime.now();
  String _selectedStartTime =
      DateFormat("hh:mm a").format(DateTime.now()).toString();
  String _selectedEndTime =
      DateFormat("hh:mm a").format(DateTime.now()).toString();
  String _selectedRepeat = "None";
  int _selectedColor = 0;

  List<String> repeatList = ["None", "Daily"];
  List<MaterialColor> colorList = [
    Colors.amber,
    Colors.deepPurple,
    Colors.lime,
    Colors.green,
    Colors.pink,
    Colors.orange,
    Colors.teal,
    Colors.lightBlue,
    Colors.deepOrange,
    Colors.brown
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(context),
      backgroundColor: context.theme.backgroundColor,
      body: Container(
        padding: const EdgeInsets.only(right: 20, left: 20, top: 5),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Add Task",
                style: headingStyle,
              ),
              MyInputField(
                title: "Title",
                hint: "Enter your title",
                controller: _titleController,
              ),
              MyInputField(
                title: "Note",
                hint: "Enter your note",
                controller: _noteController,
              ),
              MyInputField(
                title: "Date",
                hint: DateFormat.yMMMd().format(_selectedDate),
                widget: IconButton(
                  icon: const Icon(Icons.calendar_today_outlined,
                      color: Colors.grey),
                  onPressed: () {
                    _getDateFromUser();
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                      child: MyInputField(
                    title: "Start Time",
                    hint: _selectedStartTime,
                    widget: IconButton(
                      onPressed: () {
                        _getTimeFromUser(isStartTime: true);
                      },
                      icon: const Icon(Icons.access_time_sharp,
                          color: Colors.grey),
                    ),
                  )),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                      child: MyInputField(
                    title: "End Time",
                    hint: _selectedEndTime,
                    widget: IconButton(
                      onPressed: () {
                        _getTimeFromUser(isStartTime: false);
                      },
                      icon: const Icon(Icons.access_time_sharp,
                          color: Colors.grey),
                    ),
                  )),
                ],
              ),
              MyInputField(
                title: "Repeat",
                hint: _selectedRepeat,
                widget: DropdownButton(
                  icon: const Icon(
                    Icons.bolt_outlined,
                    color: Colors.grey,
                  ),
                  iconSize: 32,
                  elevation: 4,
                  style: subTitleStyle,
                  onChanged: (String? value) {
                    setState(() {
                      _selectedRepeat = value!;
                    });
                  },
                  underline: Container(
                    height: 0,
                  ),
                  items:
                      repeatList.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem(
                      child: Text(value),
                      value: value,
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(
                height: 18.0,
              ),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   crossAxisAlignment: CrossAxisAlignment.center,
              //   children: [
              //     _showColorPallet(),
              //     MyButton(label: "Create Task", onTap: () => {_validateData()})
              //   ],
              // )
              _showColorPallet(),
              const SizedBox(
                height: 35,
              ),
              Center(
                  child: MyButton(
                label: "Create Task",
                onTap: () => {_validateData()},
                width: 135,
                height: 55,
              ))
            ],
          ),
        ),
      ),
    );
  }

  _appbar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Icon(Icons.arrow_back_ios_new_outlined,
            size: 20, color: Get.isDarkMode ? Colors.white : Colors.black),
      ),
      actions: [
        Icon(Icons.person,
            size: 20, color: Get.isDarkMode ? Colors.white : Colors.black),
        const SizedBox(
          width: 20,
        )
      ],
    );
  }

  _getDateFromUser() async {
    DateTime? _pickerDate = await showDatePicker(
        initialDate: DateTime.now(),
        context: context,
        lastDate: DateTime(2024),
        firstDate: DateTime.now());

    if (_pickerDate != null) {
      setState(() {
        _selectedDate = _pickerDate;
      });
    }
  }

  _getTimeFromUser({required bool isStartTime}) async {
    var pickedTime = await _showTimePicker();
    String _stringRepresentationOfPickedTime = pickedTime.format(context);

    if (pickedTime == null) {
      print("Time is null");
    } else if (isStartTime == true) {
      setState(() {
        _selectedStartTime = _stringRepresentationOfPickedTime;
      });
    } else if (isStartTime == false) {
      setState(() {
        _selectedEndTime = _stringRepresentationOfPickedTime;
      });
    }
  }

  // helper for _getTimeFromUser
  _showTimePicker() {
    return showTimePicker(
        initialTime: TimeOfDay(
            hour: int.parse(_selectedStartTime.split(":")[0]),
            minute: int.parse(_selectedStartTime.split(":")[1].split(" ")[0])),
        context: context,
        initialEntryMode: TimePickerEntryMode.input);
  }

  _showColorPallet() {
    return (Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Text(
            "Color",
            style: colorTitleStyle,
          ),
        ),
        const SizedBox(
          height: 10.0,
        ),
        Center(
          child: Wrap(
            children: List<Widget>.generate(
                colorList.length,
                (int index) => GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = index;
                        });
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: colorList[index],
                          child: _selectedColor == index
                              ? const Icon(
                                  Icons.dangerous_outlined,
                                  color: Colors.white,
                                  size: 16,
                                )
                              : Container(),
                        ),
                      ),
                    )),
          ),
        ),
      ],
    ));
  }

  _validateData() {
    if (_titleController.text.isNotEmpty && _noteController.text.isNotEmpty) {
      // add to database
      addTaskToDb();
      Get.back();
    } else if (_titleController.text.isEmpty || _noteController.text.isEmpty) {
      Get.snackbar(
        "Required",
        "All fields are required.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.pink,
        icon: const Icon(
          Icons.warning_amber,
          color: Colors.red,
        ),
      );
    }
  }

  addTaskToDb() async {
    var value = await _taskController.addTask(
        task: Task(
            note: _noteController.text,
            title: _titleController.text,
            date: DateFormat.yMd().format(_selectedDate),
            startTime: _selectedStartTime,
            endTime: _selectedEndTime,
            repeat: _selectedRepeat,
            color: _selectedColor,
            isCompleted: 0));

    if (value > 0) {
      EasyLoading.showSuccess("Task Added",
          duration: const Duration(milliseconds: 500), dismissOnTap: true);
    }
  }
}
