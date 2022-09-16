import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:productivity_monster/UI/chat/settings_page.dart';
import 'package:productivity_monster/allConstants/constants.dart';
import 'package:productivity_monster/provider/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../../models/user_chat.dart';
import '../../provider/home_provider.dart';
import '../../utilities/debouncer.dart';
import '../../utilities/utilities.dart';
import '../task_app_scrap/theme.dart';
import 'chat_page.dart';

class ChatHomePage extends StatefulWidget {
  const ChatHomePage({Key? key}) : super(key: key);

  @override
  State<ChatHomePage> createState() => _ChatHomePageState();
}

class _ChatHomePageState extends State<ChatHomePage> {

  final FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  final GoogleSignIn googleSignIn = GoogleSignIn();
  final ScrollController _scrollController = ScrollController();

  int _limit = 20;
  final int _limitIncrement = 20;
  String _textSearch = "";

  bool isLoading = false;

  late String currentUserId;
  late GoogleSignInProvider googleSignInProvider;
  late ChatHomeProvider chatHomeProvider;

  Debouncer debouncer = Debouncer(milliSeconds: 300);

  TextEditingController searchBarController = TextEditingController();
  StreamController<bool> btnClearController = StreamController<bool>();


  @override
  void dispose() {
    _scrollController.dispose();
    btnClearController.close();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    googleSignInProvider = context.read<GoogleSignInProvider>();
    chatHomeProvider = context.read<ChatHomeProvider>();

    if (googleSignInProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = googleSignInProvider.getUserFirebaseId()!;
    }

    _scrollController.addListener(scrollListener);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _appbar(),
        backgroundColor: context.theme.backgroundColor,
        body: _body());
  }

  _appbar() {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      leading: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Icon(Icons.arrow_back_ios_new_rounded,
            size: 20, color: Get.isDarkMode ? Colors.white : Colors.black),
      ),
      actions: [
        GestureDetector(
          onTap: () => Get.to(() => const SettingsPage()),
          child: Icon(Icons.settings_applications_outlined,
              size: 20, color: Get.isDarkMode ? Colors.white : Colors.black),
        ),
        const SizedBox(
          width: 20,
        )
      ],
    );
  }


  _body() {
    return Stack(
      children: [
        Column(
          children: [
            buildSearchBar(),
            Expanded(
                child: StreamBuilder<QuerySnapshot>(
                    stream: chatHomeProvider.firebaseFirestore.collection(FirestoreConstants.pathUserCollection).snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasData) {
                        if ((snapshot.data?.docs.length ?? 0) > 0) {
                          return ListView.builder(
                            padding: EdgeInsets.all(10),
                            itemBuilder: (context, index) {
                              DocumentSnapshot? q = snapshot.data?.docs[index];
                              UserChat userChat = UserChat.fromDocument(q!);
                              if(userChat.nickname.toString().toLowerCase().startsWith(_textSearch.toLowerCase())) {
                                return buildItem(context, snapshot.data?.docs[index]);
                              }
                              else {
                              return Container();
                              }
                            },
                            itemCount: snapshot.data?.docs.length,
                            controller: _scrollController,
                          );
                        } else {
                          return const Center(
                            child: Text("USER NOT FOUND",
                                style: TextStyle(color: Colors.grey)),
                          );
                        }
                      } else {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Colors.grey,
                          ),
                        );
                      }
                    })),
          ],
        )
      ],
    );
  }

  Widget buildSearchBar() {
    return Container(
      height: 50,
      child: Row(
        children: [
          const Icon(Icons.search_outlined, color: ColorConstants.greyColor),
          const SizedBox(width: 5),
          Expanded(
              child: TextFormField(
            textInputAction: TextInputAction.search,
            controller: searchBarController,
            autofocus: false,
            cursorColor: Get.isDarkMode ? Colors.grey[100] : Colors.grey[800],
            style: subTitleStyle,
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              hintStyle: subTitleStyle,
              hintText: "Search",
              border: InputBorder.none,
              focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: context.theme.backgroundColor, width: 0)),
              enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: context.theme.backgroundColor, width: 0)),
            ),
            onChanged: (value) {
              if (value.isNotEmpty) {
                btnClearController.add(true);
                setState(() {
                  _textSearch = value;
                });
              } else {
                btnClearController.add(false);
                setState(() {
                  _textSearch = "";
                });
              }
            },
          )),
          StreamBuilder(
              stream: btnClearController.stream,
              builder: (context, snapshot) {
                return snapshot.data == true
                    ? GestureDetector(
                        onTap: () {
                          searchBarController.clear();
                          btnClearController.add(false);
                          setState(() {
                            _textSearch = "";
                          });
                        },
                        child: const Icon(Icons.clear_rounded,
                            color: ColorConstants.greyColor),
                      )
                    : const SizedBox.shrink();
              })
        ],
      ),
      padding: const EdgeInsets.only(left: 14, right: 14),
      decoration: BoxDecoration(
          border: Border.all(
            width: 2.0,
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(left: 12, right: 12, bottom: 12),
    );
  }

  void scrollListener() {
    if (_scrollController.offset >=
            _scrollController.position.maxScrollExtent &&
        !_scrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  Widget buildItem(BuildContext context, DocumentSnapshot? document) {
    if (document != null) {
      UserChat userChat = UserChat.fromDocument(document);
      if (userChat.id == currentUserId) {
        return Container();
      }
      else {
        return Container(
          child: TextButton(
            onPressed: () {
              if (Utilities.isKeyboardShowing()) {
                Utilities.closeKeyboard(context);
              }
              Get.to(() => ChatPage(
                  peerId: userChat.id,
                  peerAvatar: userChat.photoUrl,
                  peerNickname: userChat.nickname));
            },
            style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(
                    Colors.grey.withOpacity(.2)),
                shape: MaterialStateProperty.all<OutlinedBorder>(
                    RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)))),
            child: Row(
              children: [
                Material(
                  clipBehavior: Clip.hardEdge,
                  borderRadius: BorderRadius.circular(25),
                  child: userChat.photoUrl.isNotEmpty
                      ? Image.network(
                          userChat.photoUrl,
                          fit: BoxFit.cover,
                          width: 50,
                          height: 50,
                          errorBuilder: (context, object, stackTrace) {
                            return const Icon(
                              Icons.account_circle,
                              size: 50,
                              color: ColorConstants.greyColor,
                            );
                          },
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) return child;
                            return SizedBox(
                              width: 50,
                              height: 50,
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
                        )
                      : const Icon(
                          Icons.account_circle,
                          size: 50,
                          color: ColorConstants.greyColor,
                        ),
                ),
                Flexible(
                  child: Container(
                    child: Column(
                      children: [
                        Container(
                          child: Text(
                            userChat.nickname,
                            maxLines: 1,
                            style: GoogleFonts.lato(
                                textStyle: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Get.isDarkMode ? Colors.grey[100] : Colors.black,
                                )
                            )
                          ),
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                        ),
                        Container(
                          child: Text(
                            userChat.aboutMe,
                            maxLines: 1,
                            style: TextStyle(
                                color: Get.isDarkMode ? Colors.grey[500] : Colors.grey[600],
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                          alignment: Alignment.centerLeft,
                          margin: const EdgeInsets.fromLTRB(10, 0, 0, 5),
                        )
                      ],
                    ),
                    margin: EdgeInsets.only(left: 20),
                  ),
                )
              ],
            ),
          ),
          margin: const EdgeInsets.only(bottom: 10, left: 5, right: 5),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}
