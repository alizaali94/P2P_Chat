import 'package:chatting_app/screens/auth/login_screen.dart';
import 'package:chatting_app/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../main.dart';
import 'dart:developer';
import '../../api/apis.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    
    Future.delayed(const Duration(seconds: 2), () {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
       SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
          systemNavigationBarColor: Colors.white,
          statusBarColor: Colors.white));
        log('\nUser: ${APIs.auth.currentUser}');
        if(APIs.auth.currentUser != null){
                Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const HomeScreen()));
        }else{
           Navigator.pushReplacement(context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()));
        }                  
    });
  }

  @override
  Widget build(BuildContext context) {
    mq = MediaQuery.of(context).size;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Welcome to P2P Chat'),
      ),
      body: Stack(
        children: [
          Positioned(
              top: mq.height * .15,
              right: mq.width * .25,
              width: mq.width * .5,
              child: Image.asset('images/chat.png')),
          Positioned(
              bottom: mq.height * .15,
              width: mq.width,
              child: const Text('Made By Aliza Ali 💗',textAlign: TextAlign.center, style: TextStyle(
                fontWeight: FontWeight.bold,
                letterSpacing: .5
              ))),
        ],
      ),
    );
  }
}
