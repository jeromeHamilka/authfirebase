import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

import '../../common/loading.dart';
import '../../models/chat_params.dart';
import '../../models/message.dart';
import '../../services/message_database.dart';
import 'message_item.dart';

class Chat extends StatefulWidget {
  final ChatParams chatParams;

  const Chat({super.key, required this.chatParams});

  @override
  State<Chat> createState() => _ChatState(chatParams);
}

class _ChatState extends State<Chat> {
  final MessageDatabaseService messageService = MessageDatabaseService();

  _ChatState(this.chatParams);

  final ChatParams chatParams;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();

  int _nbElement = 20;
  static const int PAGINATION_INCREMENT = 20;
  bool isLoading = false;

  // File? _photo;
  // final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    listScrollController.addListener(_scrollListener);
  }

  _scrollListener() {
    if (listScrollController.offset >=
            listScrollController.position.maxScrollExtent &&
        !listScrollController.position.outOfRange) {
      setState(() {
        _nbElement += PAGINATION_INCREMENT;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [buildListMessage(), buildInput()],
        ),
        isLoading ? const Loading() : Container()
      ],
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: StreamBuilder<List<Message>>(
        stream: messageService.getMessage(chatParams.getChatGroupId(), _nbElement),
        builder: (BuildContext context, AsyncSnapshot<List<Message>> snapshot) {
          if (snapshot.hasData) {
            List<Message> listMessage = snapshot.data?? List.from([]);
            return ListView.builder(
              padding: const EdgeInsets.all(10.0),
              itemBuilder: (context, index) => MessageItem(
                  message: listMessage[index],
                  userId: chatParams.userUid,
                  isLastMessage: isLastMessage(index, listMessage)
              ),
              itemCount: listMessage.length,
              reverse: true,
              controller: listScrollController,
            );
          } else {
            return const Center(child:Loading());
          }
        },
      ),
    );
  }

  bool isLastMessage(int index, List<Message> listMessage) {
    if (index == 0) return true;
    if (listMessage[index].idFrom != listMessage[index - 1].idFrom) return true;
    return false;
  }

  Widget buildInput() {
    return Container(
      width: double.infinity,
      height: 50.0,
      decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: Colors.black, width: 0.5)),
          color: Colors.white),
      child: Row(
        children: [
          Material(
            color: Colors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1.0),
              child: IconButton(
                icon: const Icon(Icons.image),
                onPressed: getImage,
                color: Colors.blueGrey,
              ),
            ),
          ),
          Flexible(
            child: TextField(
              onSubmitted: (value) {
                onSendMessage(textEditingController.text, 0);
              },
              style: const TextStyle(color: Colors.blueGrey, fontSize: 15.0),
              controller: textEditingController,
              decoration: const InputDecoration.collapsed(
                hintText: 'Your message...',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
          // Button send message
          Material(
            color: Colors.white,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 8.0),
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: () => onSendMessage(textEditingController.text, 0),
                color: Colors.blueGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future getImage() async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile? pickedFile =
        await imagePicker.getImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        isLoading = true;
      });
      uploadFile(pickedFile);
    }
  }

  // Future getImage() async {
  //   // File? deviceImage;
  //   // final picker = ImagePicker();
  //   final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
  //   setState(() {
  //     if (pickedFile != null) {
  //       _photo = File(pickedFile.path);
  //       uploadFile(_photo!);
  //     } else {
  //       print('No image selected.');
  //     }
  //   });
  //   // if (pickedFile != null && mounted) {
  //   //   deviceImage = File(pickedFile.path);
  //   //   setState(() {
  //   //     isLoading = true;
  //   //   });
  //   //   uploadFile(deviceImage);
  //   // }
  // }

  Future uploadFile(PickedFile file) async {
  //Future uploadFile(File file) async {
    String fileName = "${DateTime.now().millisecondsSinceEpoch}.jpeg";
    try {
      Reference reference = FirebaseStorage.instance.ref().child(fileName);
      final metadata = SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'picked-file-path': file.path});
      TaskSnapshot snapshot;
      // if (kIsWeb) {
      //   snapshot = await reference.putData(await file.readAsBytes(), metadata);
      // } else {
      //   snapshot = await reference.putFile(File(file.path), metadata);
      // }
      print("file.path: ${file.path}");
      snapshot = await reference.putFile(File(file.path), metadata);

      String imageUrl = await snapshot.ref.getDownloadURL();
      print("imageUrl: $imageUrl");
      setState(() {
        isLoading = false;
        onSendMessage(imageUrl, 1);
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      Fluttertoast.showToast(msg: "Error! Try again!");
      print("erreur: $e");
    }
  }

  void onSendMessage(String content, int type) {
    if (content.trim() != '') {
      messageService.onSendMessage(
          chatParams.getChatGroupId(),
          Message(
              idFrom: chatParams.userUid,
              idTo: chatParams.peer.uid,
              timestamp: DateTime.now().millisecondsSinceEpoch.toString(),
              content: content,
              type: type));
      listScrollController.animateTo(0.0,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
      textEditingController.clear();
    } else {
      Fluttertoast.showToast(
          msg: 'Nothing to send',
          backgroundColor: Colors.red,
          textColor: Colors.white);
    }
  }
}
