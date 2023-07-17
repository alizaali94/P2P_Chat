import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/api/apis.dart';
import 'package:chatting_app/main.dart';
import '../models/message.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:voice_message_package/voice_message_package.dart';

import '../helper/dialogs.dart';
import '../helper/my_date_util.dart';
import '../models/message.dart';

class MessageCard extends StatefulWidget {
  final Message msg;
  const MessageCard({super.key, required this.msg});

  @override
  State<MessageCard> createState() => _MessageCardState();
}

class _MessageCardState extends State<MessageCard> {
  @override
  Widget build(BuildContext context) {
    bool isMe = APIs.user.uid == widget.msg.fromId;
    return InkWell(
        onLongPress: () {
          showBottomSheet(isMe);
        },
        child: isMe ? greenMessage() : blueMessage());
  }

  Widget blueMessage() {
    bool isPlaying = false;
    final Size textwidth = getTextWidth(
        widget.msg.msg, const TextStyle(fontSize: 13, color: Colors.black54));
    log('${textwidth.width}');
    final double maxwidth = mq.width * .8;
    if (widget.msg.read.isEmpty) {
      APIs.UpdateMessageReadStatus(widget.msg);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
            width: widget.msg.type == Type.image
                ? maxwidth
                : widget.msg.type == Type.audio
                    ? null
                    : textwidth.width > maxwidth
                        ? maxwidth
                        : null,
            child: Container(
                margin: EdgeInsets.symmetric(
                    horizontal: mq.width * .04, vertical: mq.height * .01),
                padding: EdgeInsets.all(widget.msg.type == Type.image
                    ? mq.width * .03
                    : widget.msg.type == Type.audio
                        ? mq.width * .01
                        : mq.width * .04),
                decoration: BoxDecoration(
                    color: Colors.blue.shade200,
                    border: Border.all(color: Colors.lightBlue),
                    borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                        bottomRight: Radius.circular(30))),
                child: widget.msg.type == Type.text
                    ? Text(
                        widget.msg.msg,
                        style:
                            const TextStyle(color: Colors.black, fontSize: 15),
                      )
                    : widget.msg.type == Type.audio
                        ? VoiceMessage(
                            audioSrc: widget.msg.msg,
                            played: true, // To show played badge or not.
                            me: false, // Set message side.
                            contactBgColor: Colors.blue.shade200,
                            contactPlayIconColor: Colors.black,
                            contactPlayIconBgColor: Colors.white,
                            contactFgColor: Colors.blue,
                            onPlay: () {}, // Do something when voice played.
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(15),
                            child: CachedNetworkImage(
                              fit: BoxFit.cover,
                              imageUrl: widget.msg.msg,
                              placeholder: (context, url) => const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Center(
                                  child: SizedBox(
                                    width: 50,
                                    height: 50,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const CircleAvatar(
                                child: Icon(
                                  Icons.image,
                                  size: 70,
                                ),
                              ),
                            ),
                          ))),
        Padding(
          padding: EdgeInsets.only(left: mq.width * .04),
          child: Text(
            MyDateUtil.getFormattedTime(
                context: context, time: widget.msg.sent),
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
        ),
      ],
    );
    //
  }

  Widget greenMessage() {
    final Size textwidth = getTextWidth(
        widget.msg.msg, const TextStyle(fontSize: 13, color: Colors.black54));
    log('${textwidth.width}');
    log("${widget.msg.type} ..... ${Type.audio}");
    final double maxwidth = mq.width * .8;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        SizedBox(
          width: widget.msg.type == Type.image
              ? maxwidth
              : widget.msg.type == Type.audio
                  ? null
                  : textwidth.width > maxwidth
                      ? maxwidth
                      : null,
          child: Container(
            margin: EdgeInsets.symmetric(
                horizontal: mq.width * .04, vertical: mq.height * .01),
            padding: EdgeInsets.all(widget.msg.type == Type.image
                ? mq.width * .03
                : widget.msg.type == Type.audio
                    ? mq.width * .01
                    : mq.width * .04),
            decoration: BoxDecoration(
                color: Colors.green.shade200,
                border: Border.all(color: Colors.lightGreen),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                    bottomLeft: Radius.circular(30))),
            child: widget.msg.type == Type.text
                ? Text(
                    widget.msg.msg,
                    style: const TextStyle(color: Colors.black, fontSize: 15),
                  )
                : widget.msg.type == Type.audio
                    ? VoiceMessage(
                        audioSrc: widget.msg.msg,
                        played: false, // To show played badge or not.
                        me: true,
                        meBgColor: Colors.green.shade200,
                        meFgColor: Colors.green,
                        mePlayIconColor: Colors.black,
                        // Set message side.
                        onPlay: () {}, // Do something when voice played.
                      )
                    : ClipRRect(
                        borderRadius: BorderRadius.circular(15),
                        child: CachedNetworkImage(
                          fit: BoxFit.cover,
                          imageUrl: widget.msg.msg,
                          placeholder: (context, url) => const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: SizedBox(
                                  width: 50,
                                  height: 50,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  )),
                            ),
                          ),
                          errorWidget: (context, url, error) =>
                              const CircleAvatar(
                            child: Icon(
                              Icons.image,
                              size: 70,
                            ),
                          ),
                        ),
                      ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(right: mq.width * .04),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              //sent time
              Text(
                MyDateUtil.getFormattedTime(
                    context: context, time: widget.msg.sent),
                style: const TextStyle(fontSize: 13, color: Colors.black54),
              ),
              SizedBox(width: mq.width * .02),
              (widget.msg.read.isNotEmpty)
                  ? const Icon(Icons.done_all_rounded,
                      color: Colors.blue, size: 20)
                  : widget.msg.read.isEmpty &&
                          widget.msg.fromId != APIs.user.uid
                      ? const Icon(Icons.done_all_rounded, size: 20)
                      : const Icon(Icons.check, color: Colors.grey, size: 20),
              const SizedBox(width: 2),
            ],
          ),
        ),
      ],
    );
  }

  void showBottomSheet(bool isMe) {
    showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20), topRight: Radius.circular(20))),
        builder: (_) {
          return ListView(
            shrinkWrap: true,
            children: [
              //black divider
              Container(
                height: 4,
                margin: EdgeInsets.symmetric(
                    vertical: mq.height * .015, horizontal: mq.width * .4),
                decoration: BoxDecoration(
                    color: Colors.grey, borderRadius: BorderRadius.circular(8)),
              ),

              widget.msg.type == Type.text
                  ?
                  //copy option
                  OptionItem(
                      icon: const Icon(Icons.copy_all_rounded,
                          color: Colors.blue, size: 26),
                      name: 'Copy Text',
                      onTap: () async {
                        await Clipboard.setData(
                                ClipboardData(text: widget.msg.msg))
                            .then((value) {
                          //for hiding bottom sheet
                          Navigator.pop(context);

                          Dialogs.showSnackbar(context, 'Text Copied!');
                        });
                      })
                  :
                  //save option
                  OptionItem(
                      icon: const Icon(Icons.download_rounded,
                          color: Colors.blue, size: 26),
                      name: 'Save Image',
                      onTap: () async {
                        try {
                          log('Image Url: ${widget.msg.msg}');
                          await GallerySaver.saveImage(widget.msg.msg,
                                  albumName: 'We Chat')
                              .then((success) {
                            //for hiding bottom sheet
                            Navigator.pop(context);
                            if (success != null && success) {
                              Dialogs.showSnackbar(
                                  context, 'Image Successfully Saved!');
                            }
                          });
                        } catch (e) {
                          log('ErrorWhileSavingImg: $e');
                        }
                      }),

              //separator or divider
              if (isMe)
                Divider(
                  color: Colors.black54,
                  endIndent: mq.width * .04,
                  indent: mq.width * .04,
                ),

              //edit option
              if (widget.msg.type == Type.text && isMe)
                OptionItem(
                    icon: const Icon(Icons.edit, color: Colors.blue, size: 26),
                    name: 'Edit Message',
                    onTap: () {
                      //for hiding bottom sheet
                      Navigator.pop(context);

                      showMessageUpdateDialog();
                    }),

              //delete option
              if (isMe)
                OptionItem(
                    icon: const Icon(Icons.delete_forever,
                        color: Colors.red, size: 26),
                    name: 'Delete Message',
                    onTap: () async {
                      await APIs.deleteMessage(widget.msg).then((value) {
                        //for hiding bottom sheet
                        Navigator.of(context, rootNavigator: true).pop();
                      });
                    }),

              //separator or divider
              Divider(
                color: Colors.black54,
                endIndent: mq.width * .04,
                indent: mq.width * .04,
              ),

              //sent time
              OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.blue),
                  name:
                      'Sent At: ${MyDateUtil.getMessageTime(context: context, time: widget.msg.sent)}',
                  onTap: () {}),

              //read time
              OptionItem(
                  icon: const Icon(Icons.remove_red_eye, color: Colors.green),
                  name: widget.msg.read.isEmpty
                      ? 'Read At: Not seen yet'
                      : 'Read At: ${MyDateUtil.getMessageTime(context: context, time: widget.msg.read)}',
                  onTap: () {}),
            ],
          );
        });
  }

  void showMessageUpdateDialog() {
    String updatedMsg = widget.msg.msg;

    showDialog(
        context: context,
        builder: (_) => AlertDialog(
              contentPadding: const EdgeInsets.only(
                  left: 24, right: 24, top: 20, bottom: 10),

              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),

              //title
              title: const Row(
                children: [
                  Icon(
                    Icons.message,
                    color: Colors.blue,
                    size: 28,
                  ),
                  Text(' Update Message')
                ],
              ),

              //content
              content: TextFormField(
                initialValue: updatedMsg,
                maxLines: null,
                onChanged: (value) => updatedMsg = value,
                decoration: InputDecoration(
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15))),
              ),

              //actions
              actions: [
                //cancel button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                    },
                    child: const Text(
                      'Cancel',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    )),

                //update button
                MaterialButton(
                    onPressed: () {
                      //hide alert dialog
                      Navigator.pop(context);
                      APIs.updateMessage(widget.msg, updatedMsg);
                    },
                    child: const Text(
                      'Update',
                      style: TextStyle(color: Colors.blue, fontSize: 16),
                    ))
              ],
            ));
  }
}

Size getTextWidth(String text, TextStyle style) {
  final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr)
    ..layout(minWidth: 0, maxWidth: double.infinity);
  return textPainter.size;
}

class OptionItem extends StatelessWidget {
  final Icon icon;
  final String name;
  final VoidCallback onTap;

  const OptionItem(
      {super.key, required this.icon, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: EdgeInsets.only(
              left: mq.width * .05,
              top: mq.height * .015,
              bottom: mq.height * .015),
          child: Row(children: [
            icon,
            Flexible(
                child: Text('    $name',
                    style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        letterSpacing: 0.5)))
          ]),
        ));
  }
}
