// import 'package:flutter/material.dart';
// import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';

// class CallScreen extends StatefulWidget {
//   final String callId;
//   final String userID;
//   final String userName;
//   const CallScreen({super.key, required this.callId, required this.userID, required this.userName});

//   @override
//   State<CallScreen> createState() => _CallScreenState();
// }

// class _CallScreenState extends State<CallScreen> {
//   @override
//   Widget build(BuildContext context) {
//     return ZegoUIKitPrebuiltCall(
//         appID:
//             1699391558, // Fill in the appID that you get from ZEGOCLOUD Admin Console.
//         appSign:
//             'f345c6e97a50099643f86f232d9c2b5509cd1c6c808b6907889e3beeaebdd208', // Fill in the appSign that you get from ZEGOCLOUD Admin Console.
//         userID: widget.userID,
//         userName: widget.userName,
//         callID: widget.callId,
//         // You can also use groupVideo/groupVoice/oneOnOneVoice to make more types of calls.
//         config: ZegoUIKitPrebuiltCallConfig.oneOnOneVideoCall());
//   }
// }
