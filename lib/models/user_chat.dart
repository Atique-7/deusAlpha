import 'package:productivity_monster/allConstants/firestore_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserChat {
  String id;
  String photoUrl;
  String nickname;
  String aboutMe;
  String phoneNumber;

  UserChat({
    required this.id,
    required this.photoUrl,
    required this.nickname,
    required this.aboutMe,
    required this.phoneNumber
  });

  Map<String, String> toJson() {
    return {
      FirestoreConstants.nickname: nickname,
      FirestoreConstants.aboutMe: aboutMe,
      FirestoreConstants.photoUrl: photoUrl,
      FirestoreConstants.phoneNumber: phoneNumber,
    };
  }

  factory UserChat.fromDocument(DocumentSnapshot doc) {
    String photoUrl = "";
    String nickname = "";
    String aboutMe = "";
    String phoneNumber = "";

    try {
      photoUrl = doc.get(FirestoreConstants.photoUrl);
    } catch (e) {}

    try {
      nickname = doc.get(FirestoreConstants.nickname);
    } catch (e) {}

    try {
      aboutMe = doc.get(FirestoreConstants.aboutMe);
    } catch (e) {}

    try {
      phoneNumber = doc.get(FirestoreConstants.phoneNumber);
    } catch (e) {}

    return UserChat(id: doc.id,
        photoUrl: photoUrl,
        nickname: nickname,
        aboutMe: aboutMe,
        phoneNumber: phoneNumber);
  }
}