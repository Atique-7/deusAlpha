import 'dart:io';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:productivity_monster/UI/shared/photo_page.dart';
import 'package:productivity_monster/models/message_model.dart';
import 'package:productivity_monster/provider/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../../allConstants/firestore_constants.dart';
import '../../provider/chat_provider.dart';
import '../task_app_scrap/theme.dart';

class ChatPage extends StatefulWidget {
  final String peerId;
  final String peerAvatar;
  final String peerNickname;

  const ChatPage(
      {Key? key,
      required this.peerId,
      required this.peerAvatar,
      required this.peerNickname})
      : super(key: key);

  @override
  State createState() => ChatPageState(
        peerId: peerId,
        peerAvatar: peerAvatar,
        peerNickname: peerNickname,
      );
}

class ChatPageState extends State<ChatPage> {
  ChatPageState(
      {Key? key,
      required this.peerId,
      required this.peerAvatar,
      required this.peerNickname});

  String peerId;
  String peerAvatar;
  String peerNickname;
  late String currentUserId;

  List<QueryDocumentSnapshot> listMessages = new List.from([]);

  int _limit = 20;
  int _limitIncrement = 20;

  File? imageFile;

  bool isLoading = false;
  bool showSticker = false;

  String imageUrl = "";
  String groupChatId = "";

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  late ChatProvider chatProvider;
  late GoogleSignInProvider googleSignInProvider;

  @override
  void initState() {
    super.initState();

    chatProvider = context.read<ChatProvider>();
    googleSignInProvider = context.read<GoogleSignInProvider>();

    focusNode.addListener(onFocusChange);
    scrollController.addListener(_scrollListener);

    readLocal();
  }

  _scrollListener() {
    if (scrollController.offset >= scrollController.position.maxScrollExtent &&
        !scrollController.position.outOfRange) {
      setState(() {
        _limit += _limitIncrement;
      });
    }
  }

  void onFocusChange() {
    if (focusNode.hasFocus) {
      setState(() {
        showSticker = false;
      });
    }
  }

  void readLocal() {
    /// confirm if user exists
    if (googleSignInProvider.getUserFirebaseId()?.isNotEmpty == true) {
      currentUserId = googleSignInProvider.getUserFirebaseId()!;
    } else {
      googleSignInProvider.logoutHandler(context);
    }

    ///
    if (currentUserId.hashCode <= peerId.hashCode) {
      groupChatId = "$currentUserId-$peerId";
    } else {
      groupChatId = "$peerId-$currentUserId";
    }

    /// Update the chatProvider
    chatProvider.updateDataFirestore(FirestoreConstants.pathUserCollection,
        currentUserId, {FirestoreConstants.chattingWith: peerId});
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile;

    pickedFile = await imagePicker.getImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      imageFile = File(pickedFile.path);
      if (imageFile != null) {
        setState(() {
          EasyLoading.instance
            ..indicatorType = EasyLoadingIndicatorType.dualRing
            ..indicatorSize = 45.0
            ..radius = 10.0
            ..userInteractions = false
            ..dismissOnTap = false;
          EasyLoading.show(
            status: "Sending...",
          );
        });
        uploadFile();
      }
    }
  }

  void getSticker() async {
    focusNode.unfocus();
    setState(() {
      showSticker = !showSticker;
    });
  }

  Future uploadFile() async {
    String filename = DateTime.now().millisecondsSinceEpoch.toString();
    UploadTask uploadTask = chatProvider.uploadFile(imageFile!, filename);

    try {
      TaskSnapshot snapshot = await uploadTask;
      imageUrl = await snapshot.ref.getDownloadURL();

      setState(() {
        EasyLoading.dismiss();
        onSendMessage(imageUrl, TypeMessage.image);
      });
    } on FirebaseException catch (e) {
      setState(() {
        EasyLoading.dismiss();
      });

      Get.snackbar(
        "Error",
        "Something went wrong.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.isDarkMode ? Colors.grey[100] : Colors.grey[800],
        colorText: Colors.pink,
        icon: const Icon(
          Icons.warning_amber,
          color: Colors.red,
        ),
      );
    }
  }

  void onSendMessage(String content, int type) {
    if (content.trim().isNotEmpty) {
      textEditingController.clear();
      chatProvider.sendMessage(
          content, type, groupChatId, currentUserId, peerId);
      scrollController.animateTo(0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    } else {
      Get.snackbar(
        "Empty.",
        "Nothing to send.",
        duration: const Duration(seconds: 1),
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Get.isDarkMode ? Colors.grey[100] : Colors.grey[800],
        colorText: Colors.pink,
        icon: const Icon(
          Icons.not_interested,
          color: Colors.red,
        ),
      );
    }
  }

  bool isLastMessageLeft(int index) {
    if (index > 0 &&
            listMessages[index - 1].get(FirestoreConstants.idFrom) ==
                currentUserId ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool isLastMessageRight(int index) {
    if (index > 0 &&
            listMessages[index - 1].get(FirestoreConstants.idFrom) != currentUserId || index == 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> onBackPress() {
    EasyLoading.dismiss();
    if (showSticker) {
      setState(() {
        showSticker = false;
      });
    } else {
      chatProvider.updateDataFirestore(FirestoreConstants.pathUserCollection,
          currentUserId, {FirestoreConstants.chattingWith: null});
      Navigator.pop(context);
    }

    return Future.value(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.theme.backgroundColor,
      appBar: _appbar(),
      body: WillPopScope(
        onWillPop: onBackPress,
        child: Stack(
          children: [
            Column(
              children: [
                buildMessageList(),
                showSticker ? buildSticker() : const SizedBox.shrink(),
                buildInput()
              ],
            )
          ],
        ),
      ),
    );
  }

  _appbar() {
    return AppBar(
      elevation: 0,
      backgroundColor: context.theme.backgroundColor,
      centerTitle: true,
      leading: GestureDetector(
        onTap: () {
          Get.back();
        },
        child: Icon(Icons.arrow_back_ios_new_outlined,
            size: 20, color: Get.isDarkMode ? Colors.white : Colors.black),
      ),
      title: Text(
        peerNickname,
        style: titleStyle,
      ),
    );
  }

  Widget buildSticker() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Get.isDarkMode ? Colors.grey[800] : Colors.grey[200],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => onSendMessage("huh", TypeMessage.sticker),
                  child: Image.asset(
                    "assets/huh.png",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      onSendMessage("thinking", TypeMessage.sticker),
                  child: Image.asset(
                    "assets/thinking.png",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      onSendMessage("visibleConfusion", TypeMessage.sticker),
                  child: Image.asset(
                    "assets/visibleConfusion.png",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                )
              ]
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => onSendMessage("mimi9", TypeMessage.sticker),
                  child: Image.asset(
                    "assets/mimi9.gif",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage("OK", TypeMessage.sticker),
                  child: Image.asset(
                    "assets/OK.png",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage("mimi1", TypeMessage.sticker),
                  child: Image.asset(
                    "assets/mimi1.gif",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => onSendMessage("mimi2", TypeMessage.sticker),
                  child: Image.asset(
                    "assets/mimi2.gif",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage("mimi3", TypeMessage.sticker),
                  child: Image.asset(
                    "assets/mimi3.gif",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage("mimi4", TypeMessage.sticker),
                  child: Image.asset(
                    "assets/mimi4.gif",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => onSendMessage("mimi5", TypeMessage.sticker),
                  child: Image.asset(
                    "assets/mimi5.gif",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage("mimi6", TypeMessage.sticker),
                  child: Image.asset(
                    "assets/mimi6.gif",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
                TextButton(
                  onPressed: () => onSendMessage("mimi7", TypeMessage.sticker),
                  child: Image.asset(
                    "assets/mimi7.gif",
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget buildInput() {
    return Container(
      child: Row(
        children: [
          GestureDetector(
            onTap: getImage,
              child: Icon(Icons.photo, color: Get.isDarkMode ? Colors.teal : Colors.deepPurple)
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: getSticker,
              child: Icon(Icons.emoji_emotions_outlined,
                  color: Get.isDarkMode ? Colors.teal : Colors.deepPurple
              )),
          SizedBox(width: 8),
          Expanded(
            child: TextField(
              onSubmitted: (value) {
                onSendMessage(
                    textEditingController.text.trim(), TypeMessage.text);
              },
              style: subTitleStyle,
              controller: textEditingController,
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                hintText: "Type something nice.",
                hintStyle: subTitleStyle,
                border: InputBorder.none,
                focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: context.theme.backgroundColor, width: 0)),
                enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: context.theme.backgroundColor, width: 0)),
              ),
              focusNode: focusNode,
            ),
          ),
          GestureDetector(
            onTap: () => onSendMessage(textEditingController.text.trim(), TypeMessage.text),
            child: Icon(
              Icons.send,
              color: Get.isDarkMode ? Colors.green : Colors.deepPurple,
            ),
          )
        ],
      ),
      padding: const EdgeInsets.only(left: 14, right: 14),
      decoration: BoxDecoration(
          border: Border.all(
            width: 2.0,
            color: Get.isDarkMode ? Colors.teal : Colors.deepPurple,
          ),
          borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.only(left: 12, right: 12, bottom: 12),
      //width: double.infinity,
      height: 50,
    );
  }

  Widget buildItem(int index, DocumentSnapshot? document) {
    if (document != null) {
      MessageModel messageModel = MessageModel.fromDocument(document);

      if (messageModel.idFrom == currentUserId) {
        return Column(
          children: [
            Row(
              children: [
                messageModel.type == TypeMessage.text
                    ? Container(
                        decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.all(12),
                        margin: EdgeInsets.only(bottom: 10, right: 10),
                        child: Text(
                          messageModel.content,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                        ),
                      )
                    : messageModel.type == TypeMessage.image
                        ? Container(
                            child: OutlinedButton(
                              onPressed: () => Get.to(FullPhotoPage(url: messageModel.content)),
                              child: Material(
                                child: Image.network(
                                  messageModel.content,
                                  loadingBuilder: (BuildContext context,
                                      Widget child,
                                      ImageChunkEvent? loadingProgress) {
                                    if (loadingProgress == null) return child;
                                    return Container(
                                      decoration: BoxDecoration(
                                          color: Colors.grey,
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      width: 200,
                                      height: 200,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          color: Get.isDarkMode
                                              ? Colors.grey[100]
                                              : Colors.grey[800],
                                          value: loadingProgress
                                                          .expectedTotalBytes !=
                                                      null &&
                                                  loadingProgress
                                                          .expectedTotalBytes !=
                                                      null
                                              ? loadingProgress
                                                      .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                              : null,
                                        ),
                                      ),
                                    );
                                  },
                                  errorBuilder: (context, object, stackTrace) {
                                    return Material(
                                      child: Image.asset(
                                          'assets/img_not_available.jpeg',
                                          width: 200,
                                          height: 200,
                                          fit: BoxFit.cover),
                                      borderRadius: BorderRadius.circular(8),
                                      clipBehavior: Clip.hardEdge,
                                    );
                                  },
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                clipBehavior: Clip.hardEdge,
                              ),
                              style: ButtonStyle(
                                  padding:
                                      MaterialStateProperty.all<EdgeInsets>(
                                          const EdgeInsets.all(0))),
                            ),
                            margin: EdgeInsets.only(bottom: 10, right: 10),
                          )
                        : Container(
                            child: Image.asset(
                              messageModel.content.trim()[0] == "m" ?
                              'assets/${messageModel.content}.gif' :
                              'assets/${messageModel.content}.png' ,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(
                                bottom: 10, right: 10),
                          ),
              ],
              mainAxisAlignment: MainAxisAlignment.end,
            ),
            isLastMessageRight(index) ? const SizedBox(height: 10) : const SizedBox.shrink()
          ],
        );
      } else {
        return Column(
          children: [
            Row(
              children: [
                messageModel.type == TypeMessage.text
                    ? Container(
                        decoration: BoxDecoration(
                            color: Colors.deepPurple,
                            borderRadius: BorderRadius.circular(15)),
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          messageModel.content,
                          style: const TextStyle(
                              color: Colors.white, fontSize: 15),
                        ),
                  margin: EdgeInsets.only(bottom: 10, right: 10),
                      )
                    : messageModel.type == TypeMessage.image
                        ? Container(
                            child: TextButton(
                            onPressed: () => Get.to(FullPhotoPage(url: messageModel.content)),
                            child: Material(
                              child: Image.network(
                                messageModel.content,
                                loadingBuilder: (BuildContext context,
                                    Widget child,
                                    ImageChunkEvent? loadingProgress) {
                                  if (loadingProgress == null) return child;
                                  return Container(
                                    decoration: BoxDecoration(
                                        color: Colors.grey,
                                        borderRadius:
                                            BorderRadius.circular(8)),
                                    width: 200,
                                    height: 200,
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Get.isDarkMode
                                            ? Colors.grey[100]
                                            : Colors.grey[800],
                                        value: loadingProgress
                                                        .expectedTotalBytes !=
                                                    null &&
                                                loadingProgress
                                                        .expectedTotalBytes !=
                                                    null
                                            ? loadingProgress
                                                    .cumulativeBytesLoaded /
                                                loadingProgress
                                                    .expectedTotalBytes!
                                            : null,
                                      ),
                                    ),
                                  );
                                },
                                errorBuilder: (context, object, stackTrace) =>
                                    Material(
                                  child: Image.asset(
                                      'assets/img_not_available.jpeg',
                                      width: 200,
                                      height: 200,
                                      fit: BoxFit.cover),
                                  borderRadius: BorderRadius.circular(8),
                                  clipBehavior: Clip.hardEdge,
                                ),
                                width: 200,
                                height: 200,
                                fit: BoxFit.cover,
                              ),
                              borderRadius: BorderRadius.circular(8),
                              clipBehavior: Clip.hardEdge,
                            ),
                            style: ButtonStyle(
                                padding:
                                    MaterialStateProperty.all<EdgeInsets>(
                                        const EdgeInsets.all(0))),
                          ),
                  margin: EdgeInsets.only(bottom: 10, right: 10))
                        : Container(
                            child: Image.asset(
                              'assets/${messageModel.content}.png',
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            ),
                            margin: EdgeInsets.only(bottom: 10),
                          )
              ],
            ),
            isLastMessageLeft(index) ? Container(
              child: Text(
                DateFormat('dd MMM yyyy, hh:mm a')
                    .format(DateTime.fromMillisecondsSinceEpoch(int.parse(messageModel.timestamp))),
                style: lastSeenTitleStyle,
              ),
              margin: EdgeInsets.only(left:10, bottom:5)) : Container(),
            isLastMessageLeft(index) ? SizedBox(height: 10) : SizedBox.shrink()
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }

  Widget buildMessageList() {
    return Flexible(
        child: groupChatId.isNotEmpty
            ? StreamBuilder<QuerySnapshot>(
                stream: chatProvider.getChatStream(groupChatId, _limit),
                builder: (BuildContext context,
                    AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                      listMessages.addAll(snapshot.data!.docs);
                    return ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemBuilder: (context, index) =>
                          buildItem(index, snapshot.data?.docs[index]),
                      itemCount: snapshot.data?.docs.length,
                      reverse: true,
                      controller: scrollController,
                    );
                  } else {
                    return const Center(
                        child: CircularProgressIndicator(color: Colors.teal));
                  }
                },
              )
            : const Center(
                child: CircularProgressIndicator(color: Colors.teal)));
  }
}
