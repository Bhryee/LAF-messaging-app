import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user stream
  Stream<List<Map<String, dynamic>>> getUserStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  // send message
  Future<void> sendMessage(String receiverID, String message) async {
    try {
      // get current user info
      final String currentUserID = _auth.currentUser!.uid;
      final String currentUserEmail = _auth.currentUser!.email!;
      final Timestamp timestamp = Timestamp.now();

      // create a new message MAP
      Map<String, dynamic> newMessage = {
        'senderID': currentUserID,
        'senderEmail': currentUserEmail,
        'receiverID': receiverID,
        'message': message,
        'timestamp': timestamp,
      };

      // chat room id
      List<String> ids = [currentUserID, receiverID];
      ids.sort();
      String chatRoomID = ids.join("_");

      // add new message to database
      await _firestore
          .collection("ChatRooms")
          .doc(chatRoomID)
          .collection("Messages")
          .add(newMessage);

    } catch (e) {
      rethrow;
    }
  }

  // get messages
  Stream<QuerySnapshot> getMessages(String userID, String otherUserID) {
    try {
      List<String> ids = [userID, otherUserID];
      ids.sort();
      String chatRoomID = ids.join("_");

      return _firestore
          .collection("ChatRooms")
          .doc(chatRoomID)
          .collection("Messages")
          .orderBy("timestamp", descending: false)
          .snapshots();

    } catch (e) {
      rethrow;
    }
  }
}