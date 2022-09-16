import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:productivity_monster/allConstants/constants.dart';

class ChatHomeProvider {
  final FirebaseFirestore firebaseFirestore;

  ChatHomeProvider({
    required this.firebaseFirestore
  });

  Future<void> updateDataFirestore(String collectionPath, String path, Map<String, String> dataNeedUpdate) async {
    return firebaseFirestore.collection(collectionPath).doc(path).update(dataNeedUpdate);
  }

  Stream<QuerySnapshot> getStreamFirestore(String collectionPath, int limit, String? textSearch) {
    if(textSearch!.isNotEmpty == true) {
      return firebaseFirestore
          .collection(collectionPath)
          .limit(limit)
          .where(FirestoreConstants.nickname, isEqualTo: textSearch)
          .snapshots();
    } else {
      return firebaseFirestore
          .collection(collectionPath)
          .limit(limit)
          .snapshots();
    }
  }



}
