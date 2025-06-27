import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_app/core/services/local_storage.dart';
import 'package:task_app/core/widgets/app_text.dart';
import 'package:task_app/features/break_timer/presentation/break_screen.dart';
import 'package:task_app/features/questionnaire/presentation/widgets/rounded_progress_bar.dart';

const String yes = "Yes";
const String no = "No";

const List<String> taskOptions = [
  "Cutting vegetables",
  "Sweeping",
  "Mopping",
  "Cleaning bathrooms",
  "Laundry",
  "Washing dishes",
  "None of the above",
];

const Color primaryColor = Color(0xFF371382);
const Color headingTextColor = Color(0xFF101840);
const Color secondaryTextColor = Color(0xFF525871);

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final _dayController = TextEditingController();
  final _monthController = TextEditingController();
  final _yearController = TextEditingController();

  final Set<String> selectedTasks = {};

  String? hasSmartphone;
  String? canGetPhone;
  String? usedGoogleMaps;

  bool isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadPreviousAnswers();
  }

  @override
  void dispose() {
    _dayController.dispose();
    _monthController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  bool get isFormValid {
    final phoneValid = hasSmartphone != null;
    final mapsValid = usedGoogleMaps != null;
    final phoneConditionalValid =
        hasSmartphone == 'Yes' ||
        (hasSmartphone == 'No' && canGetPhone != null);

    return phoneValid && mapsValid && phoneConditionalValid && isValidDate();
  }

  bool isValidDate() {
    final day = int.tryParse(_dayController.text);
    final month = int.tryParse(_monthController.text);
    final year = int.tryParse(_yearController.text);

    if (day == null || month == null || year == null) return false;
    if (day < 1 || day > 31 || month < 1 || month > 12 || year < 1900) {
      return false;
    }
    return true;
  }

  double get progress {
    int answered = 0;
    int total = 3;

    if (selectedTasks.isNotEmpty) answered++;
    if (hasSmartphone != null) answered++;
    if (usedGoogleMaps != null) answered++;

    if (hasSmartphone == 'No') {
      total++;
      if (canGetPhone != null) answered++;
    }

    return answered / total;
  }

  void toggleTask(String task) {
    setState(() {
      if (task == "None of the above") {
        selectedTasks.clear();
        selectedTasks.add(task);
      } else {
        selectedTasks.remove("None of the above");
        selectedTasks.contains(task)
            ? selectedTasks.remove(task)
            : selectedTasks.add(task);
      }
    });
  }

  Future<void> submitData() async {
    if (isSubmitting) return;
    setState(() => isSubmitting = true);

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final dateOfBirth = {
        "day": _dayController.text.trim(),
        "month": _monthController.text.trim(),
        "year": _yearController.text.trim(),
      };

      final data = {
        "selectedTasks": selectedTasks.toList(),
        "hasSmartphone": hasSmartphone,
        "canGetPhone": canGetPhone,
        "usedGoogleMaps": usedGoogleMaps,
        "dateOfBirth": dateOfBirth,
        "timestamp": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('questionnaires')
          .doc(user.uid)
          .set(data);
      await LocalStorage.saveCurrentScreen('homescreen');

      // Navigator.pushReplacement(
      //   context,
      //   MaterialPageRoute(builder: (_) => const BreakScreen()),
      // );

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BreakScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Something went wrong")));
    } finally {
      setState(() => isSubmitting = false);
    }
  }

  Future<void> _loadPreviousAnswers() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc =
        await FirebaseFirestore.instance
            .collection('questionnaires')
            .doc(user.uid)
            .get();

    if (doc.exists) {
      final data = doc.data()!;
      setState(() {
        selectedTasks.addAll(List<String>.from(data['selectedTasks'] ?? []));
        hasSmartphone = data['hasSmartphone'];
        canGetPhone = data['canGetPhone'];
        usedGoogleMaps = data['usedGoogleMaps'];

        final dob = data['dateOfBirth'];
        if (dob != null && dob is Map) {
          _dayController.text = dob['day'] ?? '';
          _monthController.text = dob['month'] ?? '';
          _yearController.text = dob['year'] ?? '';
        }
      });
    }
  }

  Widget buildRadioGroup(
    String title,
    String? groupValue,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),

        AppText(
          text: title,
          fontWeight: FontWeight.w600,
          fontSize: 13,
          lineHeight: 18 / 13,
          letterSpacing: -0.24,
          color: Color(0xFF101840),
        ),

        const SizedBox(height: 16),

        Row(
          children:
              [yes, no].map((value) {
                final isSelected = groupValue == value;
                return GestureDetector(
                  onTap: () => onChanged(value),
                  child: Row(
                    children: [
                      Image.asset(
                        isSelected
                            ? 'assets/images/checkbox_checked.png'
                            : 'assets/images/checkbox_unchecked.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        value,
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                          height: 20 / 13,
                          letterSpacing: -0.24,
                          color: Color(0xFF525871),
                        ),
                      ),

                      const SizedBox(width: 24),
                    ],
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateBox(
    TextEditingController controller,
    String hint,
    int maxLength,
  ) {
    return Container(
      width: 70,
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Color(0xFFD0D5DD)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: TextFormField(
          controller: controller,
          maxLength: maxLength,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w500,
            letterSpacing: -0.24,
            color: Color(0xFF101840),
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.24,
              color: Color(0xFFDBDAE5),
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTaskRows(List<String> tasks) {
    final rows = <Widget>[];
    for (int i = 0; i < tasks.length; i += 2) {
      final row = Row(
        children: [
          Expanded(child: _buildCheckboxChip(tasks[i])),
          if (i + 1 < tasks.length)
            Expanded(child: _buildCheckboxChip(tasks[i + 1])),
        ],
      );
      rows.add(row);
    }
    return rows;
  }

  Widget _buildCheckboxChip(String task) {
    final isSelected = selectedTasks.contains(task);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => toggleTask(task),
            child: Image.asset(
              isSelected
                  ? 'assets/images/checkbox_checked_square.png'
                  : 'assets/images/checkbox_unchecked_Square.png',
              width: 24,
              height: 24,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              task,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF525871),
                letterSpacing: -0.24,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Image.asset(
            'assets/images/back_icon.png',
            width: 24,
            height: 24,
          ),
        ),
      ),

      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        width: double.infinity,
        height: 48,
        child: ElevatedButton(
          onPressed: isFormValid && !isSubmitting ? submitData : null,

          // onPressed: isFormValid ? submitData : null,
          // style: ButtonStyle(
          //   backgroundColor: MaterialStateProperty.resolveWith<Color>(
          //     (states) =>
          //         states.contains(MaterialState.disabled)
          //             ? const Color(0xFFE4E4EC)
          //             : const Color(0xFF371382),
          //   ),
          //   foregroundColor: MaterialStateProperty.resolveWith<Color>(
          //     (states) =>
          //         states.contains(MaterialState.disabled)
          //             ? const Color(0xFFA0A3BD)
          //             : Colors.white,
          //   ),
          //   padding: MaterialStateProperty.all<EdgeInsets>(
          //     const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          //   ),
          //   shape: MaterialStateProperty.all<RoundedRectangleBorder>(
          //     RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          //   ),
          //   textStyle: MaterialStateProperty.all<TextStyle>(
          //     const TextStyle(
          //       fontFamily: 'SFProDisplay',
          //       fontSize: 15,
          //       fontWeight: FontWeight.w600,
          //       height: 20 / 15, // ~1.33
          //       letterSpacing: -0.24,
          //     ),
          //   ),
          // ),
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.resolveWith<Color>(
              (states) =>
                  states.contains(MaterialState.disabled)
                      ? const Color(0xFFE4E4EC)
                      : const Color(0xFF371382),
            ),
            foregroundColor: MaterialStateProperty.resolveWith<Color>(
              (states) =>
                  states.contains(MaterialState.disabled)
                      ? const Color(0xFFA0A3BD)
                      : Colors.white,
            ),
            padding: MaterialStateProperty.all<EdgeInsets>(
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            ),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            textStyle: MaterialStateProperty.all<TextStyle>(
              const TextStyle(
                fontFamily: 'SFProDisplay',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                height: 1.33,
                letterSpacing: -0.24,
              ),
            ),
          ),
          child:
              isSubmitting
                  ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                  : const Text('Continue'),

          // child: const Text('Continue'),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16),
        child: ListView(
          children: [
            SizedBox(height: 16),
            RoundedProgressBar(
              progress: progress,
              height: 6,
              backgroundColor: const Color(0xFFDBDAE5),
              fillColor: const Color(0xFF3030D6),
            ),
            SizedBox(height: 36),

            AppText(
              text: "Skills",
              fontSize: 17,
              fontWeight: FontWeight.w600,
              lineHeight: 22 / 17,
              letterSpacing: -0.24,
              color: Color(0xFF101840),
            ),
            SizedBox(height: 4),

            AppText(
              text: "Tell us a bit more about yourself",
              fontSize: 13,
              fontWeight: FontWeight.w400,
              lineHeight: 18 / 13,
              letterSpacing: -0.24,
              color: Color(0xFF525871),
            ),

            const SizedBox(height: 24),
            AppText(
              text:
                  "How many of these tasks have you done before?\n(select all that apply)",
              fontSize: 13,
              fontWeight: FontWeight.w600,
              lineHeight: 18 / 13,
              letterSpacing: -0.24,
              color: Color(0xFF101840),
            ),

            const SizedBox(height: 16),
            ..._buildTaskRows(taskOptions),
            buildRadioGroup("Do you have your own smartphone?", hasSmartphone, (
              v,
            ) {
              setState(() {
                hasSmartphone = v;
                if (v == yes) canGetPhone = null;
              });
            }),
            if (hasSmartphone == 'No')
              buildRadioGroup(
                "Will you be able to get a phone for the job?",
                canGetPhone,
                (v) {
                  setState(() => canGetPhone = v);
                },
              ),
            buildRadioGroup("Have you ever used google maps?", usedGoogleMaps, (
              v,
            ) {
              setState(() => usedGoogleMaps = v);
            }),
            const SizedBox(height: 24),

            AppText(
              text: "Date of birth",
              fontSize: 13,
              fontWeight: FontWeight.w600,
              lineHeight: 18 / 13,
              letterSpacing: -0.24,
              color: Color(0xFF101840),
            ),

            const SizedBox(height: 8),
            Row(
              children: [
                _buildDateBox(_dayController, 'DD', 2),
                const SizedBox(width: 12),
                _buildDateBox(_monthController, 'MM', 2),
                const SizedBox(width: 12),
                _buildDateBox(_yearController, 'YYYY', 4),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
