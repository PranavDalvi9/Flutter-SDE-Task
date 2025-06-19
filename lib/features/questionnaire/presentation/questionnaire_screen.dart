import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_app/core/services/local_storage.dart';
import 'package:task_app/features/break_timer/presentation/break_screen.dart';

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
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

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

    // ScaffoldMessenger.of(
    //   context,
    // ).showSnackBar(const SnackBar(content: Text("Responses submitted.")));

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BreakScreen()),
    );
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: headingTextColor,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children:
                [yes, no].map((value) {
                  final selected = groupValue == value;
                  return GestureDetector(
                    onTap: () => onChanged(value),
                    child: Row(
                      children: [
                        Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: selected ? primaryColor : Colors.transparent,
                            border: Border.all(
                              color:
                                  selected
                                      ? primaryColor
                                      : const Color(0xFFD1D5DB),
                              width: 2,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child:
                              selected
                                  ? const Icon(
                                    Icons.check,
                                    size: 14,
                                    color: Colors.white,
                                  )
                                  : null,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          value,
                          style: const TextStyle(
                            color: secondaryTextColor,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 24),
                      ],
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
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
        border: Border.all(color: const Color(0xFFD0D5DD)),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: TextFormField(
          controller: controller,
          maxLength: maxLength,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: headingTextColor,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            counterText: '',
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFB0B8C1)),
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
    return Row(
      children: [
        Theme(
          data: Theme.of(context).copyWith(unselectedWidgetColor: primaryColor),
          child: Transform.scale(
            scale: 1.1,
            child: Checkbox(
              activeColor: primaryColor,
              value: isSelected,
              onChanged: (_) => toggleTask(task),
            ),
          ),
        ),
        Expanded(
          child: Text(
            task,
            style: const TextStyle(
              color: secondaryTextColor,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: ElevatedButton(
          onPressed: isFormValid ? submitData : null,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isFormValid ? Theme.of(context).primaryColor : Colors.grey[300],
            foregroundColor: isFormValid ? Colors.white : Colors.black38,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
          ),
          child: const Text('Continue'),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: RoundedProgressBar(
              progress: progress,
              height: 8,
              backgroundColor: const Color(0xFFD8DAE5),
              fillColor: const Color(0xFF3030D6),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Skills",
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: headingTextColor,
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              "Tell us a bit more about yourself",
              style: TextStyle(fontSize: 13, color: secondaryTextColor),
            ),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "How many of these tasks have you done before? \n(select all that apply)",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: headingTextColor,
              ),
            ),
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
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Date of birth",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: headingTextColor,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _buildDateBox(_dayController, 'DD', 2),
                const SizedBox(width: 12),
                _buildDateBox(_monthController, 'MM', 2),
                const SizedBox(width: 12),
                _buildDateBox(_yearController, 'YYYY', 4),
              ],
            ),
          ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}

class RoundedProgressBar extends StatelessWidget {
  final double progress;
  final double height;
  final Color backgroundColor;
  final Color fillColor;

  const RoundedProgressBar({
    super.key,
    required this.progress,
    this.height = 8,
    this.backgroundColor = const Color(0xFFDADCE0),
    this.fillColor = const Color(0xFF3F51B5),
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final filledWidth = width * progress.clamp(0.0, 1.0);
        return Stack(
          children: [
            Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: filledWidth,
              height: height,
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(height / 2),
              ),
            ),
          ],
        );
      },
    );
  }
}
