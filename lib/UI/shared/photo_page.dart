import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';

class FullPhotoPage extends StatelessWidget {
  final String url;

  const FullPhotoPage({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appbar(context),
      body: Container(
        child: PhotoView(
          imageProvider: NetworkImage(url),
        ),
      ),
    );
  }

  _appbar(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      centerTitle: true,
      leading: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Icon(Icons.arrow_back_ios_new_outlined,
            size: 20, color: Get.isDarkMode ? Colors.white : Colors.black
        )
      ),
      title: Text("Full View."),
    );
  }
}
