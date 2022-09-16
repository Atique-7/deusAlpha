import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:productivity_monster/UI/chat/chat_home.dart';
import 'package:productivity_monster/UI/task_app_scrap/theme.dart';
import 'package:productivity_monster/UI/widgets/add_task_bar.dart';
import 'package:productivity_monster/UI/shared/button.dart';
import 'package:productivity_monster/UI/widgets/task_tile.dart';
import 'package:productivity_monster/controllers/task_controller.dart';
import 'package:productivity_monster/models/task.dart';
import 'package:productivity_monster/models/user_chat.dart';
import 'package:productivity_monster/provider/google_sign_in.dart';
import 'package:productivity_monster/services/notification_services.dart';
import 'package:productivity_monster/services/theme_services.dart';
import 'package:date_picker_timeline/date_picker_timeline.dart';
import 'package:provider/provider.dart';

import '../allConstants/color_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late GoogleSignInProvider googleSignInProvider;

  DateTime _selectedDate = DateTime.now();
  final _taskController = Get.put(TaskController());
  var notifyHelper;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    googleSignInProvider = context.read<GoogleSignInProvider>();
    _taskController.getTasks();
    notifyHelper = NotifyHelper();
    notifyHelper.initializeNotification();
    notifyHelper.cancelNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _appbar(),
        backgroundColor: context.theme.backgroundColor,
        body: WillPopScope(
          onWillPop: onBackPress,
          child: Column(
            children: [
              _addTaskBar(),
              _addDatePickerBar(),
              const SizedBox(
                height: 10,
              ),
              Obx(() {
                return _taskController.taskList.isEmpty
                    ? _emptyTasks()
                    : _showTasks();
              })
            ],
          ),
        ));
  }

  _appbar() {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          ThemeService().switchTheme();
        },
        child: Icon(
            Get.isDarkMode
                ? Icons.wb_sunny_outlined
                : Icons.nightlight_round_outlined,
            size: 20,
            color: Get.isDarkMode ? Colors.white : Colors.black),
      ),
      actions: [
        GestureDetector(
          onTap: () => _chatModule(),
          child: Icon(Icons.chat_bubble_outline,
              size: 20, color: Get.isDarkMode ? Colors.white : Colors.black),
        ),
        const SizedBox(
          width: 20,
        )
      ],
    );
  }

  _chatModule() async {
    bool isLoggedIn = await GoogleSignIn().isSignedIn();

    if(isLoggedIn) {
      Get.to(() => const ChatHomePage());
    } else {
      openChatDialog();
      // Get.snackbar(
      //   "ERROR",
      //   "You have to be a Google User to access communication.",
      //   snackPosition: SnackPosition.BOTTOM,
      //   backgroundColor: Colors.white,
      //   colorText: Colors.pink,
      //   icon: const Icon(
      //     Icons.warning_amber,
      //     color: Colors.red)
      // );
    }
  }

  _addTaskBar() {
    return (Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(DateFormat.yMMMMd().format(DateTime.now()),
                    style: subHeadingStyle),
                Text(
                  "Today",
                  style: headingStyle,
                )
              ],
            ),
          ),
          MyButton(
            label: " + Add Task",
            onTap: () async {
              await Get.to(() => const AddTaskPage());
              _taskController.getTasks();
            },
            width: 110,
            height: 55,
          )
        ],
      ),
    ));
  }

  _addDatePickerBar() {
    return (Container(
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: DatePicker(
        DateTime.now(),
        height: 90,
        width: 80,
        initialSelectedDate: DateTime.now(),
        selectionColor: primaryColor,
        selectedTextColor: Colors.white,
        dateTextStyle: GoogleFonts.aBeeZee(
          textStyle: const TextStyle(
              fontSize: 25, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        dayTextStyle: GoogleFonts.aBeeZee(
          textStyle: const TextStyle(
              fontSize: 16, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        monthTextStyle: GoogleFonts.aBeeZee(
          textStyle: const TextStyle(
              fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey),
        ),
        onDateChange: (date) {
          setState(() {
            _selectedDate = date;
          });
        },
        daysCount: 28,
      ),
    ));
  }

  _emptyTasks() {
    return Expanded(
        child: Center(
            child: Column(
              children: const [
                SizedBox(height: 70),
                Text("🌎", style: TextStyle(fontSize: 100)),
                SizedBox(height: 70),
                Text("Add a Task.", style: TextStyle(fontSize: 28),)
              ],
            ),
          )
        );
  }

  _showTasks() {
    return Expanded(
      child: Obx(() {
        return ListView.builder(
            itemCount: _taskController.taskList.length,
            itemBuilder: (_, index) {
              // Get task instance.
              Task task = _taskController.taskList[index];

              /// check if today is day for the reminder
              // today's date
              DateTime today = DateTime.now();
              var present = DateTime(today.year, today.month, today.day);

              // tasks date
              DateTime taskDate = DateFormat.yMd().parse(task.date!);
              var pickedTime =
                  DateTime(taskDate.year, taskDate.month, taskDate.day);

              // compare them both, if they match then its a go.
              var comparison = pickedTime.compareTo(present);
              if (comparison == 0) {
                // Extracting start time from the TASK INSTANCE.
                DateTime date =
                    DateFormat.jm().parse(task.startTime.toString());
                var myTime = DateFormat("HH:mm").format(date);
                // Evoke the notifyHelper class to schedule the notifications for
                // the task instance
                notifyHelper.scheduledNotification(
                    int.parse(myTime.toString().split(":")[0]),
                    int.parse(myTime.toString().split(":")[1]),
                    task);
              }
              if (task.repeat == "Daily") {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  child: SlideAnimation(
                    child: FadeInAnimation(
                      child: Row(
                        children: [
                          GestureDetector(
                              onTap: () {
                                _showBottomBar(context, task);
                              },
                              child: TaskTile(task))
                        ],
                      ),
                    ),
                  ),
                );
              }
              if (task.date == DateFormat.yMd().format(_selectedDate)) {
                return AnimationConfiguration.staggeredList(
                  position: index,
                  child: SlideAnimation(
                    child: FadeInAnimation(
                      child: Row(
                        children: [
                          GestureDetector(
                              onTap: () {
                                _showBottomBar(context, task);
                              },
                              child: TaskTile(task))
                        ],
                      ),
                    ),
                  ),
                );
              } else {
                return Container();
              }
            });
      }),
    );
  }

  _showBottomBar(BuildContext context, Task task) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.only(top: 4),
        height: task.isCompleted == 1
            ? MediaQuery.of(context).size.height * 0.24
            : MediaQuery.of(context).size.height * 0.32,
        color: Get.isDarkMode ? darkGreyColor : Colors.white,
        child: Column(
          children: [
            const SizedBox(
              height: 5,
            ),
            Container(
              height: 6,
              width: 120,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Get.isDarkMode ? Colors.grey[600] : Colors.grey[300]),
            ),
            const Spacer(),
            task.isCompleted == 1
                ? Container()
                : _showBottomSheetButton(
                    label: "Completed",
                    onTap: () {
                      _taskController.setTaskComplete(task.id!);
                      EasyLoading.showInfo("Task Completed",
                          duration: const Duration(milliseconds: 500),
                          dismissOnTap: true);
                      Get.back();
                    },
                    color: Colors.green,
                    context: context),
            const SizedBox(height: 8),
            _showBottomSheetButton(
                label: "Delete Task",
                onTap: () {
                  _taskController.delete(task);
                  Get.back();
                },
                color: Colors.red,
                context: context),
            const SizedBox(height: 20),
            _showBottomSheetButton(
                label: "Close",
                onTap: () {
                  Get.back();
                },
                color: Colors.transparent,
                close: true,
                context: context),
            SizedBox(
              height: 10,
            )
          ],
        ),
      ),
    );
  }

  _showBottomSheetButton(
      {required String label,
      required Function()? onTap,
      required Color color,
      bool close = false,
      required BuildContext context}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        height: 55,
        width: MediaQuery.of(context).size.width * 0.9,
        decoration: BoxDecoration(
            border: Border.all(
              width: 2,
              color: close == true
                  ? Get.isDarkMode
                      ? Colors.grey[600]!
                      : Colors.grey[300]!
                  : color,
            ),
            color: color,
            borderRadius: BorderRadius.circular(20)),
        child: Center(
          child: Text(
            label,
            style: close == true
                ? titleStyle
                : titleStyle.copyWith(color: Colors.white),
          ),
        ),
      ),
    );
  }

  Future<bool> onBackPress() {
    openDialog();
    return Future.value(false);
  }

  Future<void> openDialog() async {
    switch(await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.zero,
          children: [
            Container(
              height: 50,
                color: ColorConstants.primaryColor,
                padding: const EdgeInsets.only(bottom: 10, top: 10),
                child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                       Text("You're leaving?", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold))
                    ]
                )
            ),
            /// @Todo: Put the button containers in a row.
            Container(
              color: Colors.grey[100],
              child: SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 1);
                },
                child: Row(
                  children: [
                    Container(
                      child: const Icon(Icons.check_circle, color: Colors.red),
                      margin: const EdgeInsets.only(right: 10),
                    ),
                    const Text("Yes", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            ),
            Container(
              color: Colors.grey[100],
              child: SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, 0);
                },
                child: Row(
                  children: [
                    Container(
                      child: const Icon(Icons.cancel, color: Colors.green),
                      margin: const EdgeInsets.only(right: 10),
                    ),
                    const Text("No", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
            )
          ],
        );
      },
    )) {
      case 0:
        break;
      case 1 :
        exit(0);
    }
  }

  Future<void> openChatDialog() async {
    switch(await showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          contentPadding: EdgeInsets.zero,
          children: [
            Container(
              child:
              Icon(
                  Icons.dangerous,
                  size: 50
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              color: ColorConstants.primaryColor,
              height: 60,
            ),
            Container(
                height: 50,
                color: ColorConstants.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                child: Text("You need a Google Account to use chat.", style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold))
            ),
            /// @Todo: Put the button containers in a row.
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  child: SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 0);
                    },
                    child: Row(
                      children: [
                        Container(
                          child: const Icon(Icons.logout_rounded, color: Colors.red),
                          margin: const EdgeInsets.only(right: 10),
                        ),
                        const Text("Logout", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 10),
                Container(
                  child: SimpleDialogOption(
                    onPressed: () {
                      Navigator.pop(context, 1);
                    },
                    child: Row(
                      children: [
                        Container(
                          child: const Icon(Icons.keyboard_return, color: Colors.green),
                          margin: const EdgeInsets.only(right: 10),
                        ),
                        const Text("Go back", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                      ],
                    ),
                  ),
                )
              ],
            )
          ],
        );
      },
    )) {
      case 0:
        _logout(context);
        break;
      case 1 :
        break;
    }
  }

  Future<void> _logout(BuildContext context) async {
    googleSignInProvider.logoutHandler(context);
  }

}

