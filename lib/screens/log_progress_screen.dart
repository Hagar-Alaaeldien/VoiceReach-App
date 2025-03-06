import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Firebase Authentication
import '../localization/localization.dart';
import '../widgets/bottom_nav_bar.dart'; // Import the reusable BottomNavBar

class LogProgressScreen extends StatefulWidget {
  const LogProgressScreen({super.key});

  @override
  State<LogProgressScreen> createState() => _LogProgressScreenState();
}

class _LogProgressScreenState extends State<LogProgressScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _exerciseTypeController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _repetitionsController = TextEditingController();
  DateTime? _selectedDate;
  int _selectedIndex = 2; // Set default selected index for 'Add Progress'

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _resetForm() {
    _exerciseTypeController.clear();
    _durationController.clear();
    _repetitionsController.clear();
    setState(() {
      _selectedDate = null;
    });
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final String exerciseType = _exerciseTypeController.text.trim();
      final String duration = _durationController.text.trim();
      final String repetitions = _repetitionsController.text.trim();
      final String formattedDate = _selectedDate != null
          ? "${_selectedDate!.year.toString().padLeft(4, '0')}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}"
          : LocalizationHelper.translate(context, 'no_date_selected');

      // Get the current user
      final User? user = FirebaseAuth.instance.currentUser;

      if (user == null) {
        // If no user is logged in, show an error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocalizationHelper.translate(context, 'user_not_logged_in'))),
        );
        return;
      }

      try {
        // Save to Firestore
        await FirebaseFirestore.instance.collection('progress_logs').add({
          'userId': user.uid,
          'userEmail': user.email,
          'exerciseType': exerciseType,
          'duration': duration,
          'repetitions': repetitions,
          'date': formattedDate, // Date as YYYY-MM-DD string
          'timestamp': Timestamp.now(), // For sorting by timestamp
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(LocalizationHelper.translate(
              context,
              'progress_logged',
            )),
          ),
        );

        _resetForm();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(LocalizationHelper.translate(context, 'error_saving'))),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(LocalizationHelper.translate(context, 'fill_all_fields'))),
      );
    }
  }

  // Function to handle navigation for the bottom navigation bar
  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Prevent redundant navigation

    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0: // Home
        Navigator.pushReplacementNamed(context, '/home_screen');
        break;
      case 1: // Chatbot
        Navigator.pushReplacementNamed(context, '/chatbot');
        break;
      case 2: // Add Progress
        break; // Stay on the current page
      case 3: // Community
        Navigator.pushReplacementNamed(context, '/community');
        break;
      case 4: // Extras Menu
        Navigator.pushReplacementNamed(context, '/extras');
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          LocalizationHelper.translate(context, 'log_progress_title'),
          style: const TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white, // Set color to white
          ),
        ),
        backgroundColor: const Color(0xFF264653),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 24),
                TextFormField(
                  controller: _exerciseTypeController,
                  decoration: InputDecoration(
                    labelText: LocalizationHelper.translate(context, 'exercise_type_label'),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return LocalizationHelper.translate(context, 'exercise_type_error');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _durationController,
                  decoration: InputDecoration(
                    labelText: LocalizationHelper.translate(context, 'duration_label'),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return LocalizationHelper.translate(context, 'duration_error');
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return LocalizationHelper.translate(context, 'duration_invalid_error');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _repetitionsController,
                  decoration: InputDecoration(
                    labelText: LocalizationHelper.translate(context, 'repetitions_label'),
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return LocalizationHelper.translate(context, 'repetitions_error');
                    }
                    if (int.tryParse(value) == null || int.parse(value) <= 0) {
                      return LocalizationHelper.translate(context, 'repetitions_invalid_error');
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Container(
                    height: 56,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _selectedDate != null
                          ? '${LocalizationHelper.translate(context, 'date')}: ${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                          : LocalizationHelper.translate(context, 'select_date'),
                      style: TextStyle(
                        fontSize: 16,
                        color: _selectedDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 64),
                SizedBox(
                  height: 56,
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF264653),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    child: Text(
                      LocalizationHelper.translate(context, 'log_progress_button'),
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
