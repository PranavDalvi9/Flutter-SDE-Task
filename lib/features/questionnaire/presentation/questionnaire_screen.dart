import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_app/core/services/local_storage.dart';
import 'package:task_app/features/break_timer/presentation/break_screen.dart';

class QuestionnaireScreen extends StatefulWidget {
  const QuestionnaireScreen({super.key});

  @override
  State<QuestionnaireScreen> createState() => _QuestionnaireScreenState();
}

class _QuestionnaireScreenState extends State<QuestionnaireScreen> {
  final List<String> taskOptions = [
    "Cutting vegetables",
    "Sweeping",
    "Mopping",
    "Cleaning bathrooms",
    "Laundry",
    "Washing dishes",
    "None of the above",
  ];
  final Set<String> selectedTasks = {};

  String? hasSmartphone;
  String? canGetPhone;
  String? usedGoogleMaps;

  bool get isFormValid {
    final hasPhone = hasSmartphone != null;
    final mapsUsed = usedGoogleMaps != null;
    final phoneAnswerValid =
        hasSmartphone == "Yes" ||
        (hasSmartphone == "No" && canGetPhone != null);
    return hasPhone && mapsUsed && phoneAnswerValid;
  }

  void toggleTask(String task) {
    setState(() {
      if (task == "None of the above") {
        selectedTasks.clear();
        selectedTasks.add(task);
      } else {
        selectedTasks.remove("None of the above");
        if (selectedTasks.contains(task)) {
          selectedTasks.remove(task);
        } else {
          selectedTasks.add(task);
        }
      }
    });
  }

  Future<void> submitData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    await FirebaseFirestore.instance
        .collection('questionnaires')
        .doc(user.uid)
        .set({
          "selectedTasks": selectedTasks.toList(),
          "hasSmartphone": hasSmartphone,
          "canGetPhone": canGetPhone,
          "usedGoogleMaps": usedGoogleMaps,
          "timestamp": FieldValue.serverTimestamp(),
        });
    await LocalStorage.saveCurrentScreen('homescreen');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text("Responses submitted.")));
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => BreakScreen()),
    );
  }

  Widget buildRadioGroup(
    String title,
    String groupValue,
    Function(String?) onChanged,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children:
              ["Yes", "No"].map((value) {
                return Expanded(
                  child: RadioListTile<String>(
                    title: Text(value),
                    value: value,
                    groupValue: groupValue,
                    onChanged: onChanged,
                  ),
                );
              }).toList(),
        ),
      ],
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
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _loadPreviousAnswers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("")),
      bottomNavigationBar: Container(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        width: double.infinity,
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
          child: Text('Continue'),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              "Tell us a bit more about yourself",
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text("How many of these tasks have you done before?"),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children:
                  taskOptions.map((task) {
                    final isSelected = selectedTasks.contains(task);
                    return FilterChip(
                      label: Text(task),
                      selected: isSelected,
                      onSelected: (_) => toggleTask(task),
                    );
                  }).toList(),
            ),

            buildRadioGroup(
              "Do you have your own smartphone?",
              hasSmartphone ?? '',
              (v) => setState(() {
                hasSmartphone = v;
                if (v == "Yes") canGetPhone = null;
              }),
            ),

            if (hasSmartphone == "No")
              buildRadioGroup(
                "Will you be able to get a phone for the job?",
                canGetPhone ?? '',
                (v) => setState(() => canGetPhone = v),
              ),
            buildRadioGroup(
              "Have you ever used google maps?",
              usedGoogleMaps ?? '',
              (v) => setState(() => usedGoogleMaps = v),
            ),
          ],
        ),
      ),
    );
  }
}
