import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:task_app/core/services/local_storage.dart';
import 'package:task_app/features/auth/presentation/login_screen.dart';

class BreakScreen extends StatefulWidget {
  const BreakScreen({super.key});

  @override
  State<BreakScreen> createState() => _Sample2State();
}

class _Sample2State extends State<BreakScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  Duration remaining = Duration.zero;
  Duration breakDuration = Duration.zero;
  Timer? timer;
  DateTime? breakEndTime;
  DateTime? scheduledStartTime;
  bool breakEnded = false;
  bool hasStarted = false;

  @override
  void initState() {
    super.initState();
    _createBreakIfNotExists();
    _loadBreakData();
  }

  Future<void> _createBreakIfNotExists() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('breaks')
        .doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      final now = DateTime.now();

      await docRef.set({'start_time': now, 'duration': 15});

      print("Break document created.");
    } else {
      print("Break document already exists.");
    }
  }

  Future<void> _loadBreakData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final docRef = FirebaseFirestore.instance
        .collection('breaks')
        .doc(user.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      await docRef.set({'start_time': DateTime.now(), 'duration': 15});
      print("Created default break for user.");
      return _loadBreakData();
    }

    final data = doc.data()!;
    final bool endedEarly = data['ended_early'] == true;

    scheduledStartTime = (data['start_time'] as Timestamp).toDate();
    breakDuration = Duration(minutes: data['duration']);

    final end = scheduledStartTime!.add(breakDuration);
    final now = DateTime.now();

    if (!endedEarly && now.isBefore(end)) {
      breakEndTime = end;
      remaining = end.difference(now);
      hasStarted = true;
      _startTimer();
    } else {
      breakEnded = true;
    }

    setState(() {});
  }

  // void _startBreak() {
  //   print(
  //     '-----------------${scheduledStartTime} -- ${breakDuration.inSeconds}',
  //   );
  //   if (scheduledStartTime == null || breakDuration.inSeconds == 0) return;
  //   setState(() {
  //     breakEndTime = DateTime.now().add(breakDuration);
  //     remaining = breakDuration;
  //     hasStarted = true;
  //   });
  //   _startTimer();
  // }

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
      builder: (BuildContext context) {
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
              const SizedBox(height: 30),
              const Text(
                "Ending break early?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              const Text(
                "Are you sure you want to end your break now? Take this time to recharge before your next task.",
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 31),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color: Color(0xFF429777),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Continue',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),

                  Expanded(
                    child: InkWell(
                      onTap: () async {
                        Navigator.of(context).pop();
                        await _endBreakEarly();
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFFA73636)),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'End now',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFA73636),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _endBreakEarly() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance.collection('breaks').doc(user.uid).update({
      'ended_early': true,
      'actual_end_time': DateTime.now(),
    });

    timer?.cancel();
    setState(() => breakEnded = true);
  }

  String _formatDuration(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _handleLogout(BuildContext context) async {
    await LocalStorage.clearAll();

    await FirebaseAuth.instance.signOut();

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text(
                'Menu',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
            ),
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: () async {
                await _handleLogout(context);
              },
            ),
          ],
        ),
      ),

      body: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          Column(
            children: [
              Container(
                height: 280,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: AssetImage('assets/images/appbar_background.png'),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: MediaQuery.of(context).padding.top + 10),

                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              _scaffoldKey.currentState
                                  ?.openDrawer(); // 🔓 Opens the drawer
                            },
                            child: Image.asset(
                              'assets/images/menu_icon.png',
                              height: 24,
                            ),
                          ),
                          Spacer(),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFD8DAE5),
                              ),
                            ),

                            child: Row(
                              children: [
                                Text(
                                  'Help',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Image.asset(
                                  'assets/images/call_icon.png',
                                  height: 20,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 24),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: const Color(0xFFD8DAE5),
                              ),
                            ),
                            child: Image.asset(
                              'assets/images/tea_icon.png',
                              height: 24,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Hi, Reshma!',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    SizedBox(height: 4),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 16),

                      child: Text(
                        'You are on break!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            top: 121 + MediaQuery.of(context).padding.top + 20,
            left: 0,
            right: 0,
            child:
                !breakEnded
                    ? Container(
                      padding: EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.cover,
                          image: AssetImage(
                            'assets/images/card_background.png',
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(height: 32),
                          const Text(
                            'We value your hard work!\nTake this time to relax',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 17,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 24),

                          CircularPercentIndicator(
                            radius: 140,
                            lineWidth: 16,
                            startAngle: 209,
                            percent: 0.84,
                            backgroundColor: Colors.transparent,
                            progressColor: Colors.white,
                            circularStrokeCap: CircularStrokeCap.square,
                            center: Text(
                              _formatDuration(remaining!),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          const SizedBox(height: 38),
                          Container(
                            width: MediaQuery.of(context).size.width - 80,
                            padding: EdgeInsets.symmetric(vertical: 8),
                            decoration: BoxDecoration(
                              border: Border(
                                top: BorderSide(
                                  color: const Color(0xFFACC4E8CC),
                                ),
                                bottom: BorderSide(color: Color(0xFFACC4E8CC)),
                              ),
                            ),
                            child: Text(
                              "Break ends at ${breakEndTime?.hour.toString().padLeft(2, '0')}:${breakEndTime?.minute.toString().padLeft(2, '0')}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          InkWell(
                            onTap: _confirmEndBreakEarly,

                            child: Container(
                              width: MediaQuery.of(context).size.width - 70,
                              decoration: BoxDecoration(
                                color: Color(0xFFD14343),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 14.5),
                              child: const Text(
                                'End my break',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 32),
                        ],
                      ),
                    )
                    : Container(
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          fit: BoxFit.fill,
                          image: AssetImage(
                            'assets/images/timer_end_background.png',
                          ),
                        ),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: 64),
                          Image.asset(
                            'assets/images/tick_icon.png',
                            height: 123,
                          ),
                          SizedBox(height: 24),
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              "Hope you are feeling refreshed and ready to start working again",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 52),
                        ],
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
