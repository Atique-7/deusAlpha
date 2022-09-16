import 'dart:io';
import 'package:country_picker/country_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:productivity_monster/UI/shared/button.dart';
import 'package:productivity_monster/allConstants/constants.dart';
import 'package:productivity_monster/auth/auth_page.dart';
import 'package:productivity_monster/provider/setting_provider.dart';
import 'package:provider/provider.dart';
import '../../models/user_chat.dart';
import '../../provider/google_sign_in.dart';
import '../task_app_scrap/theme.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appbar(context),
      backgroundColor: context.theme.backgroundColor,
      body: SettingsPageState(),
    );
  }

  _appbar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: Text(
        "Settings",
        style: TextStyle(color: Get.isDarkMode ? Colors.white : Colors.black),
      ),
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: Get.isDarkMode ? Colors.white : Colors.black),
      ),
    );
  }
}

class SettingsPageState extends StatefulWidget {
  const SettingsPageState({Key? key}) : super(key: key);

  @override
  State<SettingsPageState> createState() => _SettingsPageStateState();
}

class _SettingsPageStateState extends State<SettingsPageState> {
  TextEditingController? _controllerNickname;
  TextEditingController? _controllerAboutMe;

  String? dialCodeDigits = "+1";

  dynamic fl = "U+1F30E";

  final TextEditingController _controller = TextEditingController();

  String? id = '';
  String? nickname = '';
  String? aboutMe = '';
  String? photoUrl = '';
  String? phoneNumber = '';

  String flag = "";

  bool isLoading = false;

  File? avatarImageFile;
  late SettingProvider settingProvider;
  late GoogleSignInProvider googleSignInProvider;

  final FocusNode focusNodeNickname = FocusNode();
  final FocusNode focusNodeAboutMe = FocusNode();

  @override
  void initState() {
    super.initState();
    settingProvider = context.read<SettingProvider>();
    googleSignInProvider = context.read<GoogleSignInProvider>();
    readLocal();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      physics: const BouncingScrollPhysics(),
      children: [
        _profileWidget(),

        /// NAME
        Container(
          margin: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Name",
                style: titleStyle,
              ),
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                padding: const EdgeInsets.only(left: 14),
                height: 50,
                decoration: BoxDecoration(
                    border: Border.all(
                      width: 2.0,
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Expanded(
                    child: TextFormField(
                      onChanged: (value) {
                        nickname = value;
                      },
                      autofocus: false,
                      controller: _controllerNickname,
                      cursorColor:
                          Get.isDarkMode ? Colors.grey[100] : Colors.grey[800],
                      style: subTitleStyle,
                      decoration: InputDecoration(
                        hintText: nickname != '' ? nickname : "Who are you?",
                        hintStyle: subTitleStyle,
                        border: InputBorder.none,
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: context.theme.backgroundColor,
                                width: 0)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: context.theme.backgroundColor,
                                width: 0)),
                      ),
                    ),
                  )
                ]),
              )
            ],
          ),
        ),

        const SizedBox(height: 12),

        /// ABOUT ME
        Container(
          margin: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "About me",
                style: titleStyle,
              ),
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                padding: const EdgeInsets.only(left: 14),
                height: 100,
                decoration: BoxDecoration(
                    border: Border.all(
                      width: 2.0,
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  Expanded(
                    child: TextFormField(
                      onChanged: (value) {
                        aboutMe = value;
                      },
                      maxLines: 10,
                      autofocus: false,
                      controller: _controllerAboutMe,
                      cursorColor:
                          Get.isDarkMode ? Colors.grey[100] : Colors.grey[800],
                      style: subTitleStyle,
                      decoration: InputDecoration(
                        hintText: aboutMe != ""
                            ? aboutMe
                            : "Write something about yourself.",
                        hintStyle: subTitleStyle,
                        border: InputBorder.none,
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: context.theme.backgroundColor,
                                width: 0)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: context.theme.backgroundColor,
                                width: 0)),
                      ),
                    ),
                  )
                ]),
              )
            ],
          ),
        ),

        const SizedBox(height: 12),

        /// PHONE NUMBER
        Container(
          margin: const EdgeInsets.only(top: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Phone Number",
                style: titleStyle,
              ),
              Container(
                margin: const EdgeInsets.only(top: 8.0),
                padding: const EdgeInsets.only(left: 14),
                height: 60,
                decoration: BoxDecoration(
                    border: Border.all(
                      width: 2.0,
                      color: Colors.grey,
                    ),
                    borderRadius: BorderRadius.circular(12)),
                child: Row(children: [
                  flag != ""
                      ? Container(
                          child: Text(flag.toString(),
                              style: const TextStyle(fontSize: 25)),
                          margin: const EdgeInsets.only(right: 10),
                        )
                      : Container(),
                  Expanded(
                    child: TextFormField(
                      onChanged: (value) {
                        phoneNumber = value;
                      },
                      maxLines: 1,
                      maxLength: 10,
                      keyboardType: TextInputType.number,
                      autofocus: false,
                      controller: _controller,
                      cursorColor:
                          Get.isDarkMode ? Colors.grey[100] : Colors.grey[800],
                      style: phoneTitleStyle,
                      decoration: InputDecoration(
                        hintText: phoneHintText(),
                        counterText: "",
                        contentPadding: const EdgeInsets.only(top: 15),
                        hintStyle: phoneTitleStyle,
                        prefixIcon: GestureDetector(
                          onTap: () {
                            showCountryPicker(
                                context: context,
                                onSelect: (value) {
                                  setState(() {
                                    dialCodeDigits = "+" + value.phoneCode;
                                    flag = value.flagEmoji;
                                  });
                                },
                                countryListTheme: CountryListThemeData(
                                  flagSize: 25,
                                  bottomSheetHeight: 400,
                                  backgroundColor: Get.isDarkMode
                                      ? darkGreyColor
                                      : Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(20.0),
                                    topRight: Radius.circular(20.0),
                                  ),
                                  inputDecoration: InputDecoration(
                                    labelText: 'Search',
                                    hintText: 'Start typing to search',
                                    prefixIcon: const Icon(Icons.search),
                                    border: InputBorder.none,
                                    focusedBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Get.isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                          width: 3.0),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(
                                          color: Get.isDarkMode
                                              ? Colors.white
                                              : Colors.black,
                                          width: 3.0),
                                    ),
                                  ),
                                ),
                                favorite: <String>["IN", "US"]);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(
                                right: 15, top: 10, bottom: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 6),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(5),
                                    color: Get.isDarkMode
                                        ? Colors.grey[100]
                                        : Colors.grey[500],
                                  ),
                                  child: Text(
                                    dialCodeDigits! != "+1"
                                        ? dialCodeDigits!
                                        : "🌎",
                                    style: TextStyle(
                                        color: Get.isDarkMode
                                            ? Colors.grey[800]
                                            : Colors.grey[100],
                                        fontSize: 17),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                        border: InputBorder.none,
                        focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: context.theme.backgroundColor,
                                width: 0)),
                        enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                                color: context.theme.backgroundColor,
                                width: 0)),
                      ),
                    ),
                  ),
                ]),
              )
            ],
          ),
        ),

        const SizedBox(height: 45),

        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [

            /// SUBMIT BUTTON
            GestureDetector(
              onTap: () => handleUpdateData(),
              child: Container(
                //padding: EdgeInsets.symmetric(horizontal: 10),
                width: 120,
                height: 55,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), color: Get.isDarkMode ? Colors.black : Colors.grey[300]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.save, color: Colors.green),
                    SizedBox(width: 10),
                    Text(
                      "Save",
                      style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),

            /// Logout BUTTON
            GestureDetector(
              onTap: () => _logout(context),
              child: Container(
                //padding: EdgeInsets.symmetric(horizontal: 10),
                width: 120,
                height: 55,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20), color: Get.isDarkMode ? Colors.black : Colors.grey[300]),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.logout_rounded, color: Colors.red),
                    SizedBox(width: 5),
                    Text(
                      "Logout",
                      style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ],
                ),
              ),
            )
          ],
        )
      ],
    );
  }

   _profileWidget() {
    return Stack(alignment: Alignment.center, children: [
      CupertinoButton(
        onPressed: () {},
        child: Container(
          margin: const EdgeInsets.all(20),
          child: avatarImageFile == null
              ? photoUrl!.isNotEmpty
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(60),
                      child: Image.network(
                        photoUrl!,
                        fit: BoxFit.cover,
                        width: 120,
                        height: 120,
                        errorBuilder: (context, object, stackTrace) {
                          return const Icon(
                            Icons.account_circle,
                            size: 90,
                            color: ColorConstants.greyColor,
                          );
                        },
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return SizedBox(
                            width: 90,
                            height: 90,
                            child: Center(
                              child: CircularProgressIndicator(
                                color: Get.isDarkMode
                                    ? Colors.grey[100]
                                    : Colors.grey[800],
                                value: loadingProgress.expectedTotalBytes !=
                                            null &&
                                        loadingProgress.expectedTotalBytes !=
                                            null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            ),
                          );
                        },
                      ),
                    )
                  : const Icon(
                      Icons.account_circle,
                      size: 90,
                      color: ColorConstants.greyColor,
                    )
              : ClipRRect(
                  borderRadius: BorderRadius.circular(45),
                  child: Image.file(
                    avatarImageFile!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
      Positioned(
          bottom: 25,
          child: GestureDetector(
            onTap: getImage,
            child: Container(
              height: 30,
              width: 30,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25), color: Colors.blue),
              child: const Center(
                child: FaIcon(
                  FontAwesomeIcons.pen,
                  size: 15,
                ),
              ),
            ),
          )),
    ]);
  }

  void readLocal() {
    setState(() {
      id = settingProvider.getPreference(FirestoreConstants.id) ?? "";
      nickname =
          settingProvider.getPreference(FirestoreConstants.nickname) ?? "";
      aboutMe =
          settingProvider.getPreference(FirestoreConstants.aboutMe) ?? "";
      photoUrl =
          settingProvider.getPreference(FirestoreConstants.photoUrl) ?? "";
      phoneNumber =
          settingProvider.getPreference(FirestoreConstants.phoneNumber) ?? "";

      _controllerNickname = TextEditingController(text: nickname);
      _controllerAboutMe = TextEditingController(text: aboutMe);
    });


  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile =
        await imagePicker.getImage(source: ImageSource.gallery).catchError((e) {
      Get.snackbar("Error", "Something went wrong.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.isDarkMode ? Colors.grey[100] : Colors.grey[800],
          colorText: Colors.pink,
          icon: const Icon(
            Icons.warning_amber,
            color: Colors.red,
          ));
    });

    File? image;

    if (pickedFile != null) {
      image = File(pickedFile.path);
    }

    if (image != null) {
      avatarImageFile = image;
      isLoading = true;
      EasyLoading.instance
        ..indicatorType = EasyLoadingIndicatorType.dualRing
        ..indicatorSize = 45.0
        ..radius = 10.0
        ..userInteractions = false
        ..dismissOnTap = false;
      EasyLoading.show(
        status: "Loading...",
      );
    }

    uploadFile();
  }

  Future uploadFile() async {
    String fileName = id!;
    UploadTask uploadTask =
        settingProvider.uploadFile(avatarImageFile!, fileName);

    try {
      TaskSnapshot snapshot = await uploadTask;
      photoUrl = await snapshot.ref.getDownloadURL();

      UserChat updateInfo = UserChat(
          id: id!,
          photoUrl: photoUrl!,
          nickname: nickname!,
          aboutMe: aboutMe!,
          phoneNumber: phoneNumber!);

      settingProvider
          .updateDataFirestore(
              FirestoreConstants.pathUserCollection, id!, updateInfo.toJson())
          .then((data) async {
        await settingProvider.setPreference(
            FirestoreConstants.photoUrl, photoUrl!);
        setState(() {
          isLoading = false;
          EasyLoading.dismiss();
        });
      }).catchError((e) {
        setState(() {
          isLoading = false;
          EasyLoading.dismiss();
        });
        Get.snackbar("Error", "Something went wrong.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor:
                Get.isDarkMode ? Colors.grey[100] : Colors.grey[800],
            colorText: Colors.pink,
            icon: const Icon(
              Icons.warning_amber,
              color: Colors.red,
            ));
      });
    } on FirebaseException catch (e) {
      setState(() {
        isLoading = false;
        EasyLoading.dismiss();
      });

      Get.snackbar("Error", "Something went wrong.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.isDarkMode ? Colors.grey[100] : Colors.grey[800],
          colorText: Colors.pink,
          icon: const Icon(
            Icons.warning_amber,
            color: Colors.red,
          ));
    }
  }


  Future<void> _logout(BuildContext context) async {
    googleSignInProvider.logoutHandler(context);
  }


  void handleUpdateData() {
    if (_controllerAboutMe!.text == "" &&
        _controllerNickname?.text == "" &&
        _controller.text == "") {
      Get.snackbar("Required", "Fields have to be changed first.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Get.isDarkMode ? Colors.grey[100] : Colors.grey[800],
          colorText: Colors.pink,
          icon: const Icon(
            Icons.warning_amber,
            color: Colors.red,
          ));
    } else {
      focusNodeNickname.unfocus();
      focusNodeAboutMe.unfocus();

      setState(() {
        isLoading = true;
        EasyLoading.instance
          ..indicatorType = EasyLoadingIndicatorType.dualRing
          ..indicatorSize = 45.0
          ..radius = 10.0
          ..userInteractions = false
          ..dismissOnTap = false;
        EasyLoading.show(
          status: "Loading...",
        );
        if (dialCodeDigits != "+1" && _controller.text != "") {
          phoneNumber = dialCodeDigits! + _controller.text.toString();
        }
      });

      UserChat updateInfo = UserChat(
          id: id!,
          photoUrl: photoUrl!,
          nickname: nickname!,
          aboutMe: aboutMe!,
          phoneNumber: phoneNumber!);

      settingProvider
          .updateDataFirestore(
              FirestoreConstants.pathUserCollection, id!, updateInfo.toJson())
          .then((data) async {
        await settingProvider.setPreference(
            FirestoreConstants.nickname, nickname!);
        await settingProvider.setPreference(
            FirestoreConstants.aboutMe, aboutMe!);
        await settingProvider.setPreference(
            FirestoreConstants.photoUrl, photoUrl!);
        await settingProvider.setPreference(
            FirestoreConstants.phoneNumber, phoneNumber!);

        setState(() {
          isLoading = false;
          EasyLoading.dismiss();
        });

        Get.snackbar("Success", "Data Update Successful.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor:
                Get.isDarkMode ? Colors.grey[100] : Colors.grey[800],
            colorText: Colors.lightGreen,
            icon: const Icon(
              Icons.check_circle,
              color: Colors.green,
            ));
      }).catchError((e) {
        setState(() {
          isLoading = false;
          EasyLoading.dismiss();
        });

        Get.snackbar("Error", "Something went wrong.",
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor:
                Get.isDarkMode ? Colors.grey[100] : Colors.grey[800],
            colorText: Colors.pink,
            icon: const Icon(
              Icons.warning_amber,
              color: Colors.red,
            ));
      });
    }
  }

  String phoneHintText() {
    if (phoneNumber != "" && dialCodeDigits == "+1") {
      return phoneNumber.toString();
    } else {
      return "Phone Number";
    }
  }
}
