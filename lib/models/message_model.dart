import 'package:cloud_firestore/cloud_firestore.dart';

import '../allConstants/firestore_constants.dart';

class MessageModel {
  String idFrom;
  String idTo;
  String timestamp;
  String content;
  int type;

  MessageModel({
    required this.idFrom,
    required this.idTo,
    required this.timestamp,
    required this.content,
    required this.type
  });

  Map<String, dynamic> toJson() {

    return{
      FirestoreConstants.idFrom: idFrom,
      FirestoreConstants.idTo: idTo,
      FirestoreConstants.timestamp: timestamp,
      FirestoreConstants.content: content,
      FirestoreConstants.type: type
    };

  }

  factory MessageModel.fromDocument(DocumentSnapshot doc) {
    String idFrom = doc.get(FirestoreConstants.idFrom);
    String idTo = doc.get(FirestoreConstants.idTo);
    String timestamp = doc.get(FirestoreConstants.timestamp);
    String content = doc.get(FirestoreConstants.content);
    int type = doc.get(FirestoreConstants.type);

    return MessageModel( idFrom: idFrom, idTo: idTo, content: content, timestamp: timestamp, type: type);
  }


}