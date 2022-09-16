import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get/get_navigation/src/snackbar/snackbar.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:productivity_monster/allConstants/firestore_constants.dart';
import 'package:productivity_monster/models/user_chat.dart';

enum Status {
  uninitialized,
  authenticated,
  authenticating,
  authenticateError,
  authenticateCancelled
}

class GoogleSignInProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth;
  final FirebaseFirestore firebaseFirestore;
  final SharedPreferences prefs;
  final GoogleSignIn googleSignIn;

  Status _status = Status.uninitialized;

  GoogleSignInProvider({
    required this.firebaseAuth,
    required this.firebaseFirestore,
    required this.prefs,
    required this.googleSignIn,
  });

  String? getUserFirebaseId() {
    return prefs.getString(FirestoreConstants.id);
  }

  Future<bool> isLoggedIn() async {
    bool isLoggedIn = await googleSignIn.isSignedIn();
    if (isLoggedIn &&
        prefs
            .getString(FirestoreConstants.id)
            ?.isNotEmpty == true) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> signInHandler() async {
    _status = Status.authenticating;
    notifyListeners();

    if(_status == Status.authenticating) {
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

    final googleUser = await googleSignIn.signIn();
    if (googleUser != null) {
      GoogleSignInAuthentication? googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

      // Get user
      User? firebaseUser =
          (await firebaseAuth.signInWithCredential(credential)).user;

      // If found then get the DOCS
      if (firebaseUser != null) {
        final QuerySnapshot result = await firebaseFirestore
            .collection(FirestoreConstants.pathUserCollection)
            .where(FirestoreConstants.id, isEqualTo: firebaseUser.uid)
            .get();

        final List<DocumentSnapshot> document = result.docs;

        // If they do not exist then make some.
        if (document.isEmpty) {
          firebaseFirestore
              .collection(FirestoreConstants.pathUserCollection)
              .doc(firebaseUser.uid)
              .set({
            FirestoreConstants.id: firebaseUser.uid,
            FirestoreConstants.nickname: firebaseUser.displayName,
            FirestoreConstants.photoUrl: firebaseUser.photoURL,
            "createdAt": DateTime
                .now()
                .millisecondsSinceEpoch
                .toString(),
            FirestoreConstants.chattingWith: null,
            "searchKey" : firebaseUser.displayName?.substring(0,1)
          });

          /// Set sharedPreferences to the currentUsers data.
          /// TO make it accessible for the UI.
          User? currentUser = firebaseUser;
          await prefs.setString(FirestoreConstants.id, currentUser.uid);
          await prefs.setString(
              FirestoreConstants.nickname, currentUser.displayName.toString());
          await prefs.setString(
              FirestoreConstants.photoUrl, currentUser.photoURL ?? "");
          await prefs.setString(
              FirestoreConstants.phoneNumber, currentUser.phoneNumber ?? "");
        } else {
          DocumentSnapshot documentSnapshot = document[0];

          UserChat userChat = UserChat.fromDocument(documentSnapshot);
          await prefs.setString(FirestoreConstants.id, userChat.id);
          await prefs.setString(FirestoreConstants.nickname, userChat.nickname);
          await prefs.setString(FirestoreConstants.photoUrl, userChat.photoUrl);
          await prefs.setString(FirestoreConstants.aboutMe, userChat.aboutMe);
          await prefs.setString(
              FirestoreConstants.phoneNumber, userChat.phoneNumber);
        }

        _status = Status.authenticated;
        notifyListeners();

        if (_status == Status.authenticated) {
          EasyLoading.dismiss();
          EasyLoading.showToast("Welcome Back",
              duration: const Duration(milliseconds: 800), dismissOnTap: false);
        }

        return true;
      } else {
        _status = Status.authenticateError;
        notifyListeners();
        Get.snackbar(
          "Try Again",
          "Something went wrong.",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.white,
          colorText: Colors.pink,
          icon: const Icon(
            Icons.warning_amber,
            color: Colors.red,
          ),
        );
        return false;
      }
    } else {
      EasyLoading.dismiss();
      _status = Status.authenticateCancelled;
      notifyListeners();
      Get.snackbar(
        "Try Again",
        "Something went wrong.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.white,
        colorText: Colors.pink,
        icon: const Icon(
          Icons.warning_amber,
          color: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<void> logoutHandler(BuildContext context) async {
    _status = Status.uninitialized;
    bool isLoggedIn = await googleSignIn.isSignedIn();

    if(isLoggedIn) {
      await googleSignIn.disconnect();
    }

    await firebaseAuth.signOut();

    Navigator.popUntil(context, ModalRoute.withName("/"));

    EasyLoading.showToast("Logged Out Successfully",
        duration: const Duration(milliseconds: 2000), dismissOnTap: false);
  }
}
