// import 'dart:developer';

// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:chatting_app/models/chat_users.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../api/apis.dart';
import '../helper/dialogs.dart';
import '../main.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  final ChatUsers user;

  const ProfileScreen({super.key, required this.user});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<ChatUsers> list = [];
  final _formKey = GlobalKey<FormState>();
  String? _image;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(' User Profile Screen'),
        ),
        body: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: mq.width * .05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    width: mq.width,
                    height: mq.height * .03,
                  ),
                  Stack(
                    children: [
                      _image != null
                          ? ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: Image.file(
                                File(_image!),
                                width: mq.height * .2,
                                height: mq.height * .2,
                                fit: BoxFit.cover,
                              ),
                            )
                          : ClipRRect(
                              borderRadius:
                                  BorderRadius.circular(mq.height * .1),
                              child: CachedNetworkImage(
                                fit: BoxFit.cover,
                                width: mq.height * .2,
                                height: mq.height * .2,
                                imageUrl: widget.user.image,
                                placeholder: (context, url) =>
                                    const CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    const CircleAvatar(
                                  child: Icon(CupertinoIcons.person),
                                ),
                              ),
                            ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: MaterialButton(
                          elevation: 1,
                          color: Colors.white,
                          shape: const CircleBorder(),
                          onPressed: () {
                            ShowBottomSheet();
                          },
                          child: const Icon(
                            Icons.edit,
                            color: Colors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                  SizedBox(
                    height: mq.height * .03,
                  ),
                  Text(widget.user.email,
                      style:
                          const TextStyle(color: Colors.black54, fontSize: 16)),
                  SizedBox(
                    height: mq.height * .05,
                  ),
                  TextFormField(
                    initialValue: widget.user.name,
                    onSaved: (newValue) => widget.user.name = newValue ?? "",
                    validator: (newValue) =>
                        newValue != null && newValue.isNotEmpty
                            ? null
                            : 'Required Field',
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.person,
                            color: Color.fromARGB(255, 17, 114, 50)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'eg. Mx Well',
                        label: const Text('Name')),
                  ),
                  SizedBox(
                    height: mq.height * .03,
                  ),
                  TextFormField(
                    initialValue: widget.user.about,
                    onSaved: (newValue) => widget.user.about = newValue ?? "",
                    validator: (newValue) =>
                        newValue != null && newValue.isNotEmpty
                            ? null
                            : 'Required Field',
                    decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.info_outline,
                            color: Color.fromARGB(255, 17, 114, 50)),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12)),
                        hintText: 'e.g. Feeling Happy ..',
                        label: const Text('About')),
                  ),
                  SizedBox(height: mq.height * .05),
                  ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          shape: const StadiumBorder(),
                          minimumSize: Size(mq.width * .4, mq.height * .06)),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          APIs.updateUserInfo().then((value) =>
                              Dialogs.showSnackbar(
                                  context, 'Updated Successfully'));
                        }
                      },
                      icon: const Icon(Icons.edit, size: 28),
                      label:
                          const Text('Update', style: TextStyle(fontSize: 16)))
                ],
              ),
            ),
          ),
        ),
        floatingActionButton: Padding(
            padding: const EdgeInsets.only(bottom: 10.0),
            child: FloatingActionButton.extended(
                backgroundColor: Colors.red,
                onPressed: () async {
                  Dialogs.showProgressBar(context);
                  await APIs.updateActiveStatus(false);
                  await APIs.auth.signOut().then((value) async {
                    await GoogleSignIn().signOut().then((value) {
                      Navigator.pop(context);
                      Navigator.pop(context);
                      APIs.auth = FirebaseAuth.instance;
                      Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginScreen()));
                    });
                  });
                },
                icon: const Icon(Icons.logout, color: Colors.white),
                label: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ))),
      ),
    );
  }

  ShowBottomSheet() {
    showModalBottomSheet(
        context: context,
        builder: (_) {
          return ListView(
              shrinkWrap: true,
              padding:
                  EdgeInsets.only(top: mq.height * .03, bottom: mq.height * .1),
              children: [
                const Text(
                  'Pick Profile Picture',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                ),
                Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              fixedSize: Size(mq.width * .3, mq.height * .15),
                              shape: const CircleBorder(),
                              elevation: 1),
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            // Pick an image.
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.gallery, imageQuality: 80);
                            if (image != null) {
                              log('Image Path: ${image.path} -- Mime Type: ${image.mimeType}');
                              setState(() {
                                _image = image.path;
                              });
                              APIs.UpdateProfilePicture(File(_image!));
                              Navigator.pop(context);
                            }
                          },
                          child: Image.asset('images/add_image.png')),
                      ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              fixedSize: Size(mq.width * .3, mq.height * .15),
                              shape: const CircleBorder(),
                              elevation: 1),
                          onPressed: () async {
                            final ImagePicker picker = ImagePicker();
                            // Pick an image.
                            final XFile? image = await picker.pickImage(
                                source: ImageSource.camera, imageQuality: 80);
                            if (image != null) {
                              log('Image Path: ${image.path}');
                              setState(() {
                                _image = image.path;
                              });
                              APIs.UpdateProfilePicture(File(_image!));
                              Navigator.pop(context);
                            }
                          },
                          child: Image.asset('images/camera.png'))
                    ])
              ]);
        });
  }
}
