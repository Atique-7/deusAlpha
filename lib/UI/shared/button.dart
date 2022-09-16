import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:productivity_monster/UI/task_app_scrap/theme.dart';

class MyButton extends StatelessWidget {
  final String label;
  final Function()? onTap;
  final double height;
  final double width;

  const MyButton({Key? key, required this.label, required this.onTap, required this.height, required this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,//120 50
        height: height,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20), color: primaryColor),
        child: Center(
          child: Text(
            label,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
