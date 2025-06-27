// import 'dart:async';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:percent_indicator/circular_percent_indicator.dart';
// import 'package:task_app/core/services/local_storage.dart';
// import 'package:task_app/core/widgets/app_text.dart';
// import 'package:task_app/features/auth/presentation/login_screen.dart';
// import 'package:task_app/features/break_timer/presentation/circular_timer.dart';

// class BreakScreen extends StatefulWidget {
//   const BreakScreen({super.key});

//   @override
//   State<BreakScreen> createState() => _Sample2State();
// }

// class _Sample2State extends State<BreakScreen> {
//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
//   bool isLoading = true;

//   Duration remaining = Duration.zero;
//   Duration breakDuration = Duration.zero;
//   Timer? timer;
//   DateTime? breakEndTime;
//   DateTime? scheduledStartTime;
//   bool breakEnded = false;
//   bool hasStarted = false;

//   @override
//   void initState() {
//     super.initState();
//     _createBreakIfNotExists();
//     _loadBreakData();
//   }

//   Future<void> _createBreakIfNotExists() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     final docRef = FirebaseFirestore.instance
//         .collection('breaks')
//         .doc(user.uid);
//     final doc = await docRef.get();

//     if (!doc.exists) {
//       final now = DateTime.now();

//       await docRef.set({'start_time': now, 'duration': 15});

//       print("Break document created.");
//     } else {
//       print("Break document already exists.");
//     }
//   }

//   Future<void> _loadBreakData() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     final docRef = FirebaseFirestore.instance
//         .collection('breaks')
//         .doc(user.uid);
//     final doc = await docRef.get();

//     if (!doc.exists) {
//       await docRef.set({'start_time': DateTime.now(), 'duration': 15});
//       print("Created default break for user.");
//       return _loadBreakData();
//     }

//     final data = doc.data()!;
//     final bool endedEarly = data['ended_early'] == true;

//     scheduledStartTime = (data['start_time'] as Timestamp).toDate();
//     breakDuration = Duration(minutes: data['duration']);

//     final end = scheduledStartTime!.add(breakDuration);
//     final now = DateTime.now();

//     if (!endedEarly && now.isBefore(end)) {
//       breakEndTime = end;
//       remaining = end.difference(now);
//       hasStarted = true;
//       _startTimer();
//     } else {
//       breakEnded = true;
//     }

//     isLoading = false;
//     setState(() {});
//   }

//   // void _startBreak() {
//   //   print(
//   //     '-----------------${scheduledStartTime} -- ${breakDuration.inSeconds}',
//   //   );
//   //   if (scheduledStartTime == null || breakDuration.inSeconds == 0) return;
//   //   setState(() {
//   //     breakEndTime = DateTime.now().add(breakDuration);
//   //     remaining = breakDuration;
//   //     hasStarted = true;
//   //   });
//   //   _startTimer();
//   // }

//   void _startTimer() {
//     timer = Timer.periodic(const Duration(seconds: 1), (t) {
//       final now = DateTime.now();
//       if (breakEndTime != null && now.isBefore(breakEndTime!)) {
//         setState(() {
//           remaining = breakEndTime!.difference(now);
//         });
//       } else {
//         timer?.cancel();
//         setState(() => breakEnded = true);
//       }
//     });
//   }

//   Future<void> _confirmEndBreakEarly() async {
//     final result = await showModalBottomSheet<bool>(
//       context: context,
//       isScrollControlled: true,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (BuildContext context) {
//         return Padding(
//           padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 36,
//                 height: 4,
//                 decoration: BoxDecoration(
//                   color: const Color(0xFFD1D1D1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//               const SizedBox(height: 16),

//               const AppText(
//                 text: "Ending break early?",
//                 textAlign: TextAlign.center,
//                 fontSize: 20,
//                 fontWeight: FontWeight.w600,
//                 color: Color(0xFF101840),
//                 lineHeight: 1.2,
//                 letterSpacing: 0,
//               ),

//               const SizedBox(height: 16),
//               const AppText(
//                 text:
//                     "Are you sure you want to end your break now? Take this time to recharge before your next task.",
//                 textAlign: TextAlign.center,
//                 fontSize: 15,
//                 fontWeight: FontWeight.w500,
//                 lineHeight: 1.33,
//                 letterSpacing: -0.24,
//                 color: Color(0xFF525871),
//               ),

//               const SizedBox(height: 31),
//               Row(
//                 children: [
//                   Expanded(
//                     child: InkWell(
//                       onTap: () {
//                         Navigator.of(context).pop();
//                       },
//                       child: Container(
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 4,
//                           horizontal: 8,
//                         ),
//                         height: 48, // Fixed height from Figma
//                         // padding: EdgeInsets.symmetric(vertical: 14),
//                         // decoration: BoxDecoration(
//                         //   color: Color(0xFF429777),
//                         //   borderRadius: BorderRadius.circular(16),
//                         // ),
//                         decoration: BoxDecoration(
//                           color: const Color(0xFF429777), // Fill color
//                           borderRadius: BorderRadius.circular(8), // Radius: 8px
//                           border: Border.all(
//                             color: const Color(0xFF429777), // Border color
//                             width: 1, // Border width: 1px
//                           ),
//                         ),
//                         alignment:
//                             Alignment.center, // To center the text vertically

//                         child: AppText(
//                           text: 'Continue',
//                           textAlign: TextAlign.center,
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ),
//                   const SizedBox(width: 8),

//                   Expanded(
//                     child: InkWell(
//                       onTap: () async {
//                         Navigator.of(context).pop();
//                         await _endBreakEarly();
//                       },
//                       child: Container(
//                         // padding: EdgeInsets.symmetric(vertical: 14),
//                         // decoration: BoxDecoration(
//                         //   border: Border.all(color: Color(0xFFA73636)),
//                         //   borderRadius: BorderRadius.circular(16),
//                         // ),
//                         height: 48, // Fixed height from Figma
//                         padding: const EdgeInsets.symmetric(
//                           vertical: 4,
//                           horizontal: 8,
//                         ),

//                         decoration: BoxDecoration(
//                           border: Border.all(
//                             color: Color(
//                               0xFFA73636,
//                             ), // Border color from Figma (Red/R50)
//                             width: 1,
//                           ),

//                           borderRadius: BorderRadius.circular(
//                             8,
//                           ), // Radius: 8px as per Figma
//                         ),
//                         alignment: Alignment.center,

//                         child: AppText(
//                           text: 'End now',
//                           textAlign: TextAlign.center,
//                           fontSize: 15,
//                           fontWeight: FontWeight.w600,
//                           color: const Color(0xFFA73636),
//                         ),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _endBreakEarly() async {
//     final user = FirebaseAuth.instance.currentUser;
//     if (user == null) return;

//     await FirebaseFirestore.instance.collection('breaks').doc(user.uid).update({
//       'ended_early': true,
//       'actual_end_time': DateTime.now(),
//     });

//     timer?.cancel();
//     setState(() => breakEnded = true);
//   }

//   String _formatDuration(Duration d) {
//     final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
//     final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
//     return "$m:$s";
//   }

//   @override
//   void dispose() {
//     timer?.cancel();
//     super.dispose();
//   }

//   Future<void> _handleLogout(BuildContext context) async {
//     await LocalStorage.clearAll();

//     await FirebaseAuth.instance.signOut();

//     Navigator.pushReplacement(
//       context,
//       MaterialPageRoute(builder: (_) => const LoginScreen()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) {
//       return const Scaffold(
//         backgroundColor: Colors.white,
//         body: Center(child: CircularProgressIndicator(color: Colors.black)),
//       );
//     }
//     return Scaffold(
//       key: _scaffoldKey,
//       drawer: Drawer(
//         child: ListView(
//           padding: EdgeInsets.zero,
//           children: [
//             DrawerHeader(
//               decoration: BoxDecoration(color: Colors.blue),
//               child: Text(
//                 'Menu',
//                 style: TextStyle(color: Colors.white, fontSize: 24),
//               ),
//             ),
//             ListTile(
//               leading: Icon(Icons.home),
//               title: Text('Home'),
//               onTap: () {
//                 Navigator.pop(context);
//               },
//             ),
//             ListTile(
//               leading: Icon(Icons.logout),
//               title: Text('Logout'),
//               onTap: () async {
//                 await _handleLogout(context);
//               },
//             ),
//           ],
//         ),
//       ),

//       body: Stack(
//         clipBehavior: Clip.none,
//         fit: StackFit.expand,
//         children: [
//           Column(
//             children: [
//               Container(
//                 height: 225 + MediaQuery.of(context).padding.top,
//                 decoration: BoxDecoration(
//                   image: DecorationImage(
//                     fit: BoxFit.cover,
//                     image: AssetImage('assets/images/appbar_background.png'),
//                   ),
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     SizedBox(height: MediaQuery.of(context).padding.top + 10),

//                     Container(
//                       padding: EdgeInsets.symmetric(
//                         horizontal: 16,
//                         vertical: 10,
//                       ),
//                       child: Row(
//                         children: [
//                           InkWell(
//                             onTap: () {
//                               _scaffoldKey.currentState?.openDrawer();
//                             },
//                             child: Image.asset(
//                               'assets/images/menu_icon.png',
//                               height: 24,
//                             ),
//                           ),
//                           Spacer(),
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 20,
//                               vertical: 8,
//                             ),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(
//                                 color: const Color(0xFFD8DAE5),
//                               ),
//                             ),

//                             child: Row(
//                               children: [
//                                 Text(
//                                   'Help',
//                                   style: TextStyle(
//                                     fontSize: 15,
//                                     color: Colors.white,
//                                     fontWeight: FontWeight.w600,
//                                   ),
//                                 ),
//                                 SizedBox(width: 8),
//                                 Image.asset(
//                                   'assets/images/call_icon.png',
//                                   height: 20,
//                                 ),
//                               ],
//                             ),
//                           ),
//                           SizedBox(width: 24),
//                           Container(
//                             padding: EdgeInsets.symmetric(
//                               horizontal: 12,
//                               vertical: 6,
//                             ),
//                             decoration: BoxDecoration(
//                               borderRadius: BorderRadius.circular(8),
//                               border: Border.all(
//                                 color: const Color(0xFFD8DAE5),
//                               ),
//                             ),
//                             child: Image.asset(
//                               'assets/images/tea_icon.png',
//                               height: 24,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),

//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: AppText(
//                         text: 'Hi, Reshma!',
//                         textAlign: TextAlign.center,
//                         fontSize: 13,
//                         fontWeight: FontWeight.w600,
//                         lineHeight: 18 / 13,
//                         letterSpacing: -0.24,
//                         color: Color(0xFFF5FBF8),
//                       ),
//                     ),

//                     SizedBox(height: 4),

//                     Container(
//                       padding: const EdgeInsets.symmetric(horizontal: 16),
//                       child: const AppText(
//                         text: 'You are on break!',
//                         fontSize: 22,
//                         fontWeight: FontWeight.w600,
//                         lineHeight: 26 / 22,
//                         letterSpacing: -0.24,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//           Positioned(
//             top: 121 + MediaQuery.of(context).padding.top + 20,
//             left: 0,
//             right: 0,
//             child:
//                 !breakEnded
//                     ? Container(
//                       decoration: BoxDecoration(
//                         borderRadius: BorderRadius.circular(
//                           16,
//                         ), // Rounded corners

//                         image: DecorationImage(
//                           fit: BoxFit.cover,
//                           image: AssetImage(
//                             'assets/images/card_background.png',
//                           ),
//                         ),
//                       ),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           SizedBox(height: 32),

//                           const AppText(
//                             text:
//                                 'We value your hard work!\nTake this time to relax',
//                             textAlign: TextAlign.center,

//                             fontSize: 17,
//                             fontWeight: FontWeight.w600,
//                             lineHeight: 22 / 17,
//                             letterSpacing: -0.24,
//                             color: Colors.white,
//                           ),

//                           const SizedBox(height: 30),

//                           // CircularPercentIndicator(
//                           //   radius: 140,
//                           //   lineWidth: 20,
//                           //   percent: (1 -
//                           //           remaining.inSeconds /
//                           //               breakDuration.inSeconds)
//                           //       .clamp(0.0, 1.0),
//                           //   startAngle: 210,
//                           //   arcType: ArcType.FULL,
//                           //   arcBackgroundColor: Colors.white.withOpacity(0.15),
//                           //   progressColor: Colors.white,
//                           //   backgroundColor: Colors.transparent,
//                           //   circularStrokeCap: CircularStrokeCap.round,
//                           //   center: Column(
//                           //     mainAxisAlignment: MainAxisAlignment.center,
//                           //     children: [
//                           //       Text(
//                           //         _formatDuration(remaining),
//                           //         style: const TextStyle(
//                           //           color: Colors.white,
//                           //           fontSize: 32,
//                           //           fontWeight: FontWeight.w800,
//                           //         ),
//                           //       ),
//                           //     ],
//                           //   ),
//                           // ),
//                           // CircularTimer(
//                           //   total: breakDuration,
//                           //   remaining: remaining,
//                           //   // breakDuration: breakDuration,
//                           //   label: 'Break Time',
//                           // ),
//                           CircularTimer(
//                             remaining: remaining,
//                             total: breakDuration,
//                             label: "Break",
//                           ),

//                           const SizedBox(height: 38),
//                           Container(
//                             width: double.infinity,
//                             margin: EdgeInsets.symmetric(horizontal: 36),
//                             // width: MediaQuery.of(context).size.width - 80,
//                             padding: EdgeInsets.symmetric(vertical: 16),
//                             decoration: BoxDecoration(
//                               border: Border(
//                                 top: BorderSide(
//                                   color: const Color(0xFFACC4E8CC),
//                                 ),
//                                 bottom: BorderSide(color: Color(0xFFACC4E8CC)),
//                               ),
//                             ),
//                             child:
//                             // AppText(
//                             //   text:
//                             //       "Break ends at ${DateFormat('hh:mm a').format(breakEndTime ?? DateTime.now())}",
//                             //   textAlign: TextAlign.center,
//                             //   color: Colors.white,
//                             //   fontSize: 17,
//                             //   fontWeight: FontWeight.w600,
//                             // ),
//                             AppText(
//                               text:
//                                   "Break ends at ${DateFormat('hh:mm a').format(breakEndTime ?? DateTime.now())}",
//                               textAlign: TextAlign.center,
//                               color: Colors.white,
//                               fontSize: 17,
//                               fontWeight: FontWeight.w600,
//                               letterSpacing: -0.24,
//                               lineHeight: 22 / 17, // ~1.29
//                             ),
//                           ),
//                           const SizedBox(height: 16),
//                           InkWell(
//                             onTap: _confirmEndBreakEarly,

//                             child: Container(
//                               margin: EdgeInsets.symmetric(horizontal: 36),
//                               width:
//                                   double
//                                       .infinity, // width: MediaQuery.of(context).size.width - 70,
//                               decoration: BoxDecoration(
//                                 color: Color(0xFFD14343),
//                                 borderRadius: BorderRadius.circular(16),
//                               ),
//                               padding: EdgeInsets.symmetric(vertical: 14.5),
//                               child:
//                               // const AppText(
//                               //   text: 'End my break',
//                               //   textAlign: TextAlign.center,
//                               //   fontSize: 13,
//                               //   fontWeight: FontWeight.w600,
//                               //   color: Colors.white,
//                               // ),
//                               const AppText(
//                                 text: 'End my break',
//                                 textAlign: TextAlign.center,
//                                 fontSize: 13,
//                                 fontWeight: FontWeight.w600,
//                                 letterSpacing: 0,
//                                 lineHeight: 18 / 13, // ≈ 1.38
//                                 color: Colors.white,
//                               ),
//                             ),
//                           ),
//                           const SizedBox(height: 32),
//                         ],
//                       ),
//                     )
//                     : Container(
//                       height: 307,
//                       decoration: BoxDecoration(
//                         image: DecorationImage(
//                           fit: BoxFit.fill,
//                           image: AssetImage(
//                             'assets/images/timer_end_background.png',
//                           ),
//                         ),
//                       ),
//                       child: Column(
//                         children: [
//                           SizedBox(height: 64),
//                           Image.asset(
//                             'assets/images/tick_icon.png',
//                             height: 123,
//                           ),
//                           SizedBox(height: 24),

//                           Container(
//                             padding: const EdgeInsets.symmetric(horizontal: 32),
//                             child: const AppText(
//                               text:
//                                   "Hope you are feeling refreshed and \nready to start working again",
//                               textAlign: TextAlign.center,

//                               fontSize: 17,
//                               fontWeight: FontWeight.w600,
//                               lineHeight: 22 / 17,
//                               letterSpacing: -0.24,
//                               color: Colors.white,
//                             ),
//                           ),

//                           SizedBox(height: 52),
//                         ],
//                       ),
//                     ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:task_app/core/services/local_storage.dart';
import 'package:task_app/core/widgets/app_text.dart';
import 'package:task_app/features/auth/presentation/login_screen.dart';
import 'package:task_app/features/break_timer/presentation/break_active_card.dart';
import 'package:task_app/features/break_timer/presentation/break_ended_card.dart';
import 'package:task_app/features/break_timer/presentation/circular_timer.dart';
// import 'package:task_app/features/break_timer/widgets/break_active_card.dart';
// import 'package:task_app/features/break_timer/widgets/break_ended_card.dart';

class BreakScreen extends StatefulWidget {
  const BreakScreen({super.key});

  @override
  State<BreakScreen> createState() => _BreakScreenState();
}

class _BreakScreenState extends State<BreakScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = true;
  bool isSubmitting = false;

  Duration remaining = Duration.zero;
  Duration breakDuration = Duration.zero;
  Timer? timer;
  DateTime? breakEndTime;
  DateTime? scheduledStartTime;
  bool breakEnded = false;

  @override
  void initState() {
    super.initState();
    // LocalStorage.setString('last_screen', 'break');
    _initBreakData();
  }

  Future<void> _initBreakData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('breaks')
        .doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      final now = DateTime.now();
      await docRef.set({'start_time': now, 'duration': 15});
      scheduledStartTime = now;
      breakDuration = Duration(minutes: 15);
    } else {
      final data = doc.data()!;
      scheduledStartTime = (data['start_time'] as Timestamp).toDate();
      breakDuration = Duration(minutes: data['duration']);
      breakEnded = data['ended_early'] == true;
    }

    final now = DateTime.now();
    final end = scheduledStartTime!.add(breakDuration);

    if (!breakEnded && now.isBefore(end)) {
      breakEndTime = end;
      remaining = end.difference(now);
      _startTimer();
    } else {
      breakEnded = true;
    }

    setState(() => isLoading = false);
  }

  void _startTimer() {
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      final now = DateTime.now();
      if (breakEndTime != null && now.isBefore(breakEndTime!)) {
        setState(() {
          remaining = breakEndTime!.difference(now);
        });
      } else {
        timer?.cancel();
        setState(() => breakEnded = true);
      }
    });
  }

  Future<void> _confirmEndBreakEarly() async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) => _buildEndBreakConfirmationSheet(),
    );

    if (result == true) {
      await _endBreakEarly();
    }
  }

  Widget _buildEndBreakConfirmationSheet() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFFD1D1D1),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          const SizedBox(height: 16),
          const AppText(
            text: "Ending break early?",
            fontSize: 20,
            fontWeight: FontWeight.w600,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const AppText(
            text:
                "Are you sure you want to end your break now? Take this time to recharge before your next task.",
            fontSize: 15,
            fontWeight: FontWeight.w500,
            textAlign: TextAlign.center,
            color: Color(0xFF525871),
          ),
          const SizedBox(height: 31),
          Row(
            children: [
              _actionButton(
                "Continue",
                Color(0xFF429777),
                Colors.white,
                () => Navigator.of(context).pop(false),
              ),
              const SizedBox(width: 8),
              _actionButton(
                "End now",
                Colors.white,
                Color(0xFFA73636),
                () => Navigator.of(context).pop(true),
                borderColor: Color(0xFFA73636),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _actionButton(
    String text,
    Color bgColor,
    Color textColor,
    VoidCallback onTap, {
    Color? borderColor,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Container(
          height: 48,
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: borderColor ?? bgColor),
          ),
          alignment: Alignment.center,
          child: AppText(
            text: text,
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }

  Future<void> _endBreakEarly() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    setState(() => isSubmitting = true);
    await FirebaseFirestore.instance.collection('breaks').doc(user.uid).update({
      'ended_early': true,
      'actual_end_time': DateTime.now(),
    });
    timer?.cancel();
    setState(() {
      breakEnded = true;
      isSubmitting = false;
    });
  }

  Future<void> _handleLogout() async {
    await LocalStorage.clearAll();
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading || isSubmitting) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.black)),
      );
    }

    return Scaffold(
      key: _scaffoldKey,
      drawer: _buildDrawer(),
      body: Stack(
        fit: StackFit.expand,
        children: [
          _buildHeader(context),
          Positioned(
            top: 121 + MediaQuery.of(context).padding.top,
            left: 0,
            right: 0,
            child:
                breakEnded
                    ? BreakEndedCard()
                    : BreakActiveCard(
                      remaining: remaining,
                      breakEndTime: breakEndTime!,
                      duration: breakDuration,
                      onEndNow: _confirmEndBreakEarly,
                    ),
          ),
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.blue),
            child: Text(
              'Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: _handleLogout,
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 225 + MediaQuery.of(context).padding.top,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/appbar_background.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top + 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    InkWell(
                      onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      child: Image.asset(
                        'assets/images/menu_icon.png',
                        height: 24,
                      ),
                    ),
                    const Spacer(),
                    _buildHelpWidget(),
                    const SizedBox(width: 24),
                    _buildIconBox('assets/images/tea_icon.png'),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: AppText(
                  text: 'Hi, Reshma!',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFF5FBF8),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: AppText(
                  text: 'You are on break!',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHelpWidget() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD8DAE5)),
      ),
      child: Row(
        children: [
          const Text(
            'Help',
            style: TextStyle(
              fontSize: 15,
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 8),
          Image.asset('assets/images/call_icon.png', height: 20),
        ],
      ),
    );
  }

  Widget _buildIconBox(String assetPath) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFD8DAE5)),
      ),
      child: Image.asset(assetPath, height: 24),
    );
  }
}
