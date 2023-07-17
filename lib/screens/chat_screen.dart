import 'dart:developer';
import 'dart:io';
// import 'package:flutter/foundation.dart' as foundation;
// import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
// import 'package:voice_message_package/voice_message_package.dart';
import 'package:cached_network_image/cached_network_image.dart';
// import 'package:firebase_storage/firebase_storage.dart';
// import 'package:flutter/rendering.dart';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:image/image.dart' as img;
// import 'package:stories_editor/stories_editor.dart';
import 'package:chatting_app/models/chat_users.dart';
import 'package:chatting_app/screens/view_profile_screen.dart';
import 'package:chatting_app/widgets/message_card.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
// import 'package:gugor_emoji/emoji_picker_flutter.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';

// import 'package:flutter_drawing_board/flutter_drawing_board.dart';
import 'package:image_picker/image_picker.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:flutter_emoji/flutter_emoji.dart';
// import '../widgets/drawing_board_widget.dart';
// import 'calling_screen.dart';
import '../api/apis.dart';
import '../helper/my_date_util.dart';
import '../main.dart';
import '../models/message.dart';
import '../widgets/record_button.dart';

class ChatScreen extends StatefulWidget {
  final ChatUsers user;
  const ChatScreen({super.key, required this.user});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  List<Message> _list = [];
  bool _showEmoji = false;
  bool isTyping = false;
  String recordFilePath = "";
  bool isComplete = false;
  bool isRecording = false;
  bool isDragged = false;
  // Offset position = const Offset(100, 100);
  final double maxDragLength = 200;
  bool _isUploading = false;
  // late ChatProvider chatProvider;
  // AudioController audioController = Get.put(AudioController());
  // AudioPlayer audioPlayer = AudioPlayer();
  // String audioURL = "";
  // Future<bool> checkPermission() async {
  //   if (!await Permission.microphone.isGranted) {
  //     PermissionStatus status = await Permission.microphone.request();
  //     if (status != PermissionStatus.granted) {
  //       return false;
  //     }
  //   }
  //   return true;
  // }

  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: SafeArea(
        child: WillPopScope(
          onWillPop: () {
            if (_showEmoji) {
              setState(() {
                _showEmoji = !_showEmoji;
              });
              return Future.value(false);
            } else {
              return Future.value(true);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              flexibleSpace: _appBar(),
            ),
            backgroundColor: const Color.fromARGB(255, 221, 238, 224),
            body: Column(
              children: [
                Expanded(
                  child: StreamBuilder(
                    stream: APIs.getAllMessages(widget.user),
                    builder: (context, snapshot) {
                      switch (snapshot.connectionState) {
                        //if data is loading
                        case ConnectionState.waiting:
                        case ConnectionState.none:
                          return const SizedBox();
                        //if some or all data is loaded then show it
                        case ConnectionState.active:
                        case ConnectionState.done:
                          final data = snapshot.data?.docs;
                          // log('data: ${jsonEncode(data?[0].data())}');
                          // _list.clear();
                          _list = data
                                  ?.map((e) => Message.fromJson(e.data()))
                                  .toList() ??
                              [];
                          log('$_list');
                          if (_list.isNotEmpty) {
                            return ListView.builder(
                                reverse: true,
                                itemCount: _list.length,
                                padding: EdgeInsets.only(top: mq.width * .01),
                                physics: const BouncingScrollPhysics(),
                                itemBuilder: (context, index) {
                                  log('${_list[index]}');
                                  return MessageCard(msg: _list[index]);
                                  // return Text('Name: ${_list[index]}');
                                });
                          } else {
                            return const Center(
                              child: Text('Say Hi! 👋',
                                  style: TextStyle(fontSize: 20)),
                            );
                          }
                      }
                    },
                  ),
                ),
                if (_isUploading)
                  const Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                          padding:
                              EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                          child: CircularProgressIndicator(strokeWidth: 2))),
                _userInput(),
                if (_showEmoji)
                  SizedBox(
                    height: mq.height * .35,
                    child: EmojiPicker(
                      textEditingController: _textController,
                      config: Config(
                        bgColor: const Color.fromARGB(255, 234, 248, 255),
                        columns: 8,
                        emojiSizeMax: 32 * (Platform.isIOS ? 1.30 : 1.0),
                      ),
                    ),
                  )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _appBar() {
    return InkWell(
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => ViewProfileScreen(user: widget.user)));
        },
        child: StreamBuilder(
            stream: APIs.getUserInfo(widget.user),
            builder: (context, snapshot) {
              final data = snapshot.data?.docs;
              final list =
                  data?.map((e) => ChatUsers.fromJson(e.data())).toList() ?? [];

              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      //back button
                      IconButton(
                          onPressed: () => Navigator.pop(context),
                          icon: const Icon(Icons.arrow_back,
                              color: Colors.black54)),

                      //user profile picture
                      ClipRRect(
                        borderRadius: BorderRadius.circular(mq.height * .03),
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          width: mq.height * .05,
                          height: mq.height * .05,
                          imageUrl: list.isNotEmpty
                              ? list[0].image
                              : widget.user.image,
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                                  child: Icon(CupertinoIcons.person)),
                        ),
                      ),

                      //for adding some space
                      const SizedBox(width: 10),

                      //user name & last seen time
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          //user name
                          Text(
                              list.isNotEmpty ? list[0].name : widget.user.name,
                              style: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                  fontWeight: FontWeight.w500)),

                          //for adding some space
                          const SizedBox(height: 2),

                          //last seen time of user
                          Text(
                              list.isNotEmpty
                                  ? list[0].isOnline
                                      ? 'Online'
                                      : MyDateUtil.getLastActiveTime(
                                          context: context,
                                          lastActive: list[0].lastActive)
                                  : MyDateUtil.getLastActiveTime(
                                      context: context,
                                      lastActive: widget.user.lastActive),
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.black54)),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                      alignment: Alignment.topLeft,
                      onPressed: () {
                        log('Conversion Id Got: ${APIs.getConversationID(widget.user.id.toString())}');
                        // Navigator.push(
                        //     context,
                        //     MaterialPageRoute(
                        //         builder: (_) => CallScreen(
                        //               callId: APIs.getConversationID(
                        //                   widget.user.id.toString()),
                        //               userID: widget.user.about,
                        //               userName: widget.user.name,
                        //             )));
                      },
                      icon: const Icon(
                        Icons.video_call,
                        size: 30,
                        color: Color.fromARGB(255, 9, 82, 31),
                      )),
                ],
              );
            }));
  }

  // void _onTextChanged() {
  //   typingOperation?.cancel();
  //   // typingOperation = CancelableOperation.fromFuture(
  //   //   Future.delayed(const Duration(milliseconds: 2000)),
  //   // );

  //   typingOperation?.value.then((_) {
  //     setState(() {
  //     });
  //   });
  // }

  Widget _userInput() {
    return Padding(
      padding: EdgeInsets.symmetric(
          vertical: mq.height * .01, horizontal: mq.width * .025),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  IconButton(
                      onPressed: () {
                        FocusScope.of(context).unfocus();
                        setState(() {
                          _showEmoji = !_showEmoji;
                        });
                      },
                      icon: const Icon(
                        Icons.emoji_emotions,
                        size: 24,
                        color: Color.fromARGB(255, 9, 82, 31),
                      )),
                  Expanded(
                    child: TextFormField(
                      controller: _textController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      onTap: () {
                        if (_showEmoji) {
                          setState(() {
                            _showEmoji = !_showEmoji;
                          });
                          if (isTyping == false) {
                            setState(() {
                              isTyping = true;
                            });
                          }
                        }
                      },
                      decoration: const InputDecoration(
                          hintText: 'Type Your Message',
                          hintStyle:
                              TextStyle(color: Color.fromARGB(255, 9, 82, 31)),
                          border: InputBorder.none),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final List<XFile> images =
                            await picker.pickMultiImage(imageQuality: 70);
                        for (var i in images) {
                          log('Image Path: ${i.path}');
                          setState(() => _isUploading = true);
                          APIs.SentChatImage(
                              widget.user, File(i.path), Type.image);
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(Icons.image,
                          size: 26, color: Color.fromARGB(255, 9, 82, 31))),
                  IconButton(
                      onPressed: () async {
                        final ImagePicker picker = ImagePicker();
                        // Pick an image.
                        final XFile? image = await picker.pickImage(
                            source: ImageSource.camera, imageQuality: 70);
                        if (image != null) {
                          log('Image Path: ${image.path} -- Mime Type: ${image.mimeType}');
                          setState(() => _isUploading = true);
                          APIs.SentChatImage(
                              widget.user, File(image.path), Type.image);
                          setState(() => _isUploading = false);
                        }
                      },
                      icon: const Icon(Icons.camera_alt_rounded,
                          size: 26, color: Color.fromARGB(255, 9, 82, 31))),
                  // SizedBox(
                  //   width: mq.width * .0,
                  // )
                ],
              ),
            ),
          ),
          isTyping
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(60),
                  child: IconButton(
                    onPressed: () {
                      // if (_list.isEmpty) {
                      //   //on first message (add user to my_user collection of chat user)
                      //   APIs.sendFirstMessage(
                      //       widget.user, _textController.text, Type.text);
                      // } else {
                      //   //simply send message
                      //   APIs.sendMessage(
                      //       widget.user, _textController.text, Type.text);
                      // }
                      _textController.text = '';
                    },
                    style: const ButtonStyle(
                        backgroundColor: MaterialStatePropertyAll(
                            Color.fromARGB(255, 9, 82, 31))),
                    padding: const EdgeInsets.only(
                        top: 10, bottom: 10, left: 14, right: 7),
                    icon: const Icon(
                      Icons.send,
                      size: 26,
                      color: Colors.white,
                    ),
                  ),
                )
              : RecordButton(controller: controller, user: widget.user),
        ],
      ),
    );
  }

  // void startRecord() async {
  //   bool hasPermission = await checkPermission();
  //   if (hasPermission) {
  //     setState(() {
  //       isRecording = true;
  //     });
  //     recordFilePath = await getFilePath();
  //     isComplete = false;
  //     RecordMp3.instance.start(recordFilePath, (type) {
  //       log("Record error--->$type + $recordFilePath");
  //       setState(() {});
  //     });
  //   } else {
  //     // ignore: use_build_context_synchronously
  //     Dialogs.showSnackbar(context, 'Microphone is Not Connected');
  //   }
  // }

  // void stopRecord() async {
  //   bool stop = RecordMp3.instance.stop();
  //   audioController.end.value = DateTime.now();
  //   audioController.calcDuration();
  //   var ap = AudioPlayer();
  //   await ap.play(AssetSource("Notification.mp3"));
  //   ap.onPlayerComplete.listen((a) {});
  //   if (stop) {
  //     audioController.isRecording.value = false;
  //     audioController.isSending.value = true;
  //     await uploadAudio();
  //   }
  // }

  // uploadAudio() async {
  //   UploadTask uploadTask = chatProvider.uploadAudio(File(recordFilePath),
  //       "audio/${DateTime.now().millisecondsSinceEpoch.toString()}");
  //   try {
  //     TaskSnapshot snapshot = await uploadTask;
  //     audioURL = await snapshot.ref.getDownloadURL();
  //     String strVal = audioURL.toString();
  //     setState(() {
  //       audioController.isSending.value = false;
  //       audioSendMessage(strVal, 3, duration: audioController.total);
  //     });
  //   } on FirebaseException catch (e) {
  //     setState(() {
  //       audioController.isSending.value = false;
  //     });
  //     Dialogs.showSnackbar(context, "$e");
  //   }
  // }
}

Future<bool> checkPermission() async {
  if (!await Permission.microphone.isGranted) {
    PermissionStatus status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      return false;
    }
  }
  return true;
}

Future<String> getFilePath() async {
  Directory storageDirectory = await getApplicationDocumentsDirectory();
  String sdPath =
      "${storageDirectory.path}/record${DateTime.now().microsecondsSinceEpoch}.acc";
  var d = Directory(sdPath);
  if (!d.existsSync()) {
    d.createSync(recursive: true);
  }
  return "$sdPath/test_${APIs.me.id}.mp3";
}



// void openDrawingScreen(BuildContext context, ChatUsers user) {
//   showModalBottomSheet(
//     isDismissible: false,
//     backgroundColor: Colors.white,
//     context: context,
//     builder: (BuildContext context) {
//       return GestureDetector(
//         onVerticalDragDown: (_) {},
//         child: SizedBox(
//           height: MediaQuery.of(context).size.height * 0.8,
//           child: DrawingScreen(
//             user: user,
//           ),
//         ),
//       );
//     },
//   );
// }

// GlobalKey globalKey = GlobalKey();

// class DrawingScreen extends StatelessWidget {
//   final ChatUsers user;
//   const DrawingScreen({super.key, required this.user});

//   @override
//   Widget build(BuildContext context) {
//     final DrawingController _drawingController = DrawingController();
//     return Column(
//       children: [
//         AppBar(
//           title: const Text('Custom Emojy'),
//           leading: IconButton(
//             icon: const Icon(Icons.close),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//         ),
//         Expanded(
//           child: RepaintBoundary(
//             key: globalKey,
//             child: DrawingBoard(
//               controller: _drawingController,
//               background: Container(
//                   width: mq.width,
//                   height: mq.height * .97,
//                   color: Colors.white),
//               showDefaultActions: true,
//               showDefaultTools: true,
//             ),
//           ),
//         ),
//         MaterialButton(
//           color: Colors.yellow,
//           shape:
//               RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//           elevation: 1,
//           onPressed: () {
//             // _saveAndConvert(context, _drawingController);
//             captureImage(user);
//             Navigator.pop(context);
//           },
//           child: const Text(
//             'Save',
//           ),
//         ),
//         const SizedBox(
//           height: 50,
//         )
//       ],
//     );
//   }

  // Future<void> captureImage(ChatUsers user) async {
  //   final time = DateTime.now().millisecondsSinceEpoch.toString();
  //   RenderRepaintBoundary boundary =
  //       globalKey.currentContext?.findRenderObject() as RenderRepaintBoundary;
  //   ui.Image image = await boundary.toImage();
  //   ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  //   Uint8List pngBytes = byteData!.buffer.asUint8List();
  //   Reference storageRef = FirebaseStorage.instance
  //       .ref()
  //       .child('images/${APIs.getConversationID(user.id)}/emojies')
  //       .child('$time.png');
  //   TaskSnapshot uploadTask = await storageRef.putData(pngBytes);

  //   // Get the download URL of the saved image
  //   String imageUrl = await uploadTask.ref.getDownloadURL();
  //   // log('Path: $imagePath');
  //   APIs.sendMessage(user, imageUrl, Type.image);
  //   // Save the `pngBytes` or perform further actions with the image data
  // }

//   Future<String> saveImageLocally(Uint8List imageBytes) async {
//     Directory directory = await getApplicationDocumentsDirectory();
//     String filePath = '${directory.path}/image1.png';
//     File imageFile = File(filePath);
//     await imageFile.writeAsBytes(imageBytes);
//     return filePath;
//   }

//   Future<void> _saveAndConvert(
//       BuildContext context, DrawingController controller) async {
//     final imageData = (await controller.getImageData())!.buffer.asUint8List();
//     // log('$imageData');

//     saveDrawingAndConvertToEmoji(context, imageData);
//   }
// }

// Future<void> saveDrawingAndConvertToEmoji(
//     BuildContext context, Uint8List imageData) async {
//   // Convert the image data to a temporary image file
//   final Directory directory = await getApplicationDocumentsDirectory();
//   final String filePath = '${directory.path}/drawing.png';
//   final File file = File(filePath);
//   await file.writeAsBytes(imageData);

//   final String unicodeText = await imageToUnicodeText(filePath);
//   if (unicodeText.isNotEmpty) {
//     final parser = EmojiParser();
//     String emojiText = parser.emojify(unicodeText);
//     log(emojiText);

//     // customEmojis?.add(CategoryEmoji(Category.CARS,
//     //     unicodeText)); // Add a placeholder emoji for the converted drawing
//   }

//   // final List<Emoji>? updatedCustomEmojis = await Navigator.push(
//   //   context,
//   //   MaterialPageRoute(
//   //     builder: (context) => CustomEmojiPickerScreen(customEmojis: customEmojis),
//   //   ),
//   // );

//   // if (updatedCustomEmojis != null) {
//   //   // Handle the updated custom emojis
//   //   // ...
//   // }
// }

// // List<Emoji> emoji = [];

// Future<String> imageToUnicodeText(String imagePath) async {
//   final File imageFile = File(imagePath);
//   final Uint8List bytes = await imageFile.readAsBytes();
//   final img.Image? image = img.decodeImage(bytes);

//   const String unicodeChars = '@%#*+=-:. ';
//   final StringBuffer buffer = StringBuffer();
//   for (int y = 0; y < image!.height; y++) {
//     for (int x = 0; x < image.width; x++) {
//       final img.Pixel pixel = image.getPixel(x, y);
//       final double grayscale =
//           pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114;
//       final int index = (grayscale * (unicodeChars.length - 1) / 255).round();
//       buffer.write(unicodeChars[index]);
//     }
//     buffer.writeln();
//   }
//   return buffer.toString();
// }
