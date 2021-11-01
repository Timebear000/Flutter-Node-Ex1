import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:getx_chat/controller/chat_controller.dart';
import 'package:getx_chat/model/message.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Color purple = Color(0xFF6c5ce7);
  Color black = Color(0xFF191919);
  TextEditingController msgInputController = TextEditingController();
  ChatController chatController = ChatController();
  late IO.Socket socket;
  @override
  void initState() {
    socket = IO.io(
        'http://localhost:4000',
        IO.OptionBuilder()
            .setTransports(['websocket']) // for Flutter or Dart VM
            .disableAutoConnect() // disable auto-connectio
            .build());
    socket.connect();
    setUpSocketListener();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: black,
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Obx(() => Container(
                    margin: EdgeInsets.all(10),
                    child: Text(
                      "Connented User ${chatController.connentedUser.value}",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 15.0,
                      ),
                    ),
                  )),
            ),
            Expanded(
              flex: 9,
              child: Obx(
                () => ListView.builder(
                  itemCount: chatController.chatMessage.length,
                  itemBuilder: (_, index) {
                    var currentItem = chatController.chatMessage[index];
                    return MessageItem(
                      sentByMe: currentItem.sentByMe == socket.id,
                      message: currentItem.message,
                    );
                  },
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                child: TextField(
                  style: TextStyle(color: Colors.white),
                  cursorColor: purple,
                  controller: msgInputController,
                  decoration: InputDecoration(
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    suffixIcon: Container(
                      margin: EdgeInsets.only(right: 10),
                      decoration: BoxDecoration(
                        color: purple,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: IconButton(
                        onPressed: () {
                          sendMessage(msgInputController.text);
                          msgInputController.text = "";
                        },
                        icon: Icon(
                          Icons.send,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void sendMessage(String text) {
    var messageJson = {'message': text, 'sentByMe': socket.id};
    print(messageJson.toString());
    socket.emit('message', messageJson);
    chatController.chatMessage.add(Message.fromJson(messageJson));
  }

  void setUpSocketListener() {
    socket.on('message-receive', (data) {
      chatController.chatMessage.add(Message.fromJson(data));
    });

    socket.on('conented-user', (data) {
      chatController.connentedUser(data);
    });
  }
}

class MessageItem extends StatelessWidget {
  MessageItem({Key? key, required this.sentByMe, required this.message})
      : super(key: key);
  final bool sentByMe;
  final String message;
  @override
  Widget build(BuildContext context) {
    Color purple = Color(0xFF6c5ce7);
    Color white = Colors.white;

    Color black = Color(0xFF191919);
    return Align(
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: 5,
          horizontal: 10,
        ),
        margin: EdgeInsets.symmetric(
          vertical: 3,
          horizontal: 10,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: sentByMe ? purple : Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              message,
              style: TextStyle(
                fontSize: 18,
                color: sentByMe ? white : purple,
              ),
            ),
            SizedBox(width: 5),
            Text(
              '1:10 AM',
              style: TextStyle(
                fontSize: 10,
                color: (sentByMe ? white : purple).withOpacity(0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
