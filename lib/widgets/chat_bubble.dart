import 'package:flutter/material.dart';
class MyChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  const MyChatBubble({super.key, required this.message, required this.isCurrentUser});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isCurrentUser ? Color(0xFFD0C4BB) : Color(0xFFB5A199),
        borderRadius: BorderRadius.circular(10)
      ),
      padding: EdgeInsets.all(10),
      margin : EdgeInsets.symmetric(horizontal: 25, vertical: 5),
      child: Text(message),
    );
  }
}
