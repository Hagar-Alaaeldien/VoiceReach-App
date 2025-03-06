import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../localization/localization.dart';
import '../widgets/bottom_nav_bar.dart'; // Import the reusable BottomNavBar
import 'package:fl_chart/fl_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  int totalMinutes = 0; // Total minutes logged
  int completedTasks = 0; // Total completed tasks

  @override
  void initState() {
    super.initState();
    _calculateStats();
  }

  // Function to calculate total hours and completed tasks
  Future<void> _calculateStats() async {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      final QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('progress_logs')
          .where('userId', isEqualTo: user.uid)
          .get();

      int minutes = 0;
      int tasks = 0;

      for (var doc in querySnapshot.docs) {
        minutes += int.tryParse(doc['duration'] ?? '0') ?? 0;
        tasks += 1; // Increment for each logged task
      }

      setState(() {
        totalMinutes = minutes;
        completedTasks = tasks;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            LocalizationHelper.translate(context, 'error_loading_stats'),
          ),
        ),
      );
    }
  }

  // Function to handle navigation for the bottom navigation bar
  void _onItemTapped(int index) {
    if (_selectedIndex == index) return; // Prevent redundant navigation

    switch (index) {
      case 0: // Home
        break;
      case 1: // Chatbot
        Navigator.pushNamed(context, '/chatbot');
        break;
      case 2: // Add Progress
        Navigator.pushReplacementNamed(context, '/log_progress');
        break;
      case 3: // Community
        Navigator.pushNamed(context, '/community');
        break;
      case 4: // Extras Menu
        Navigator.pushNamed(context, '/extras');
        break;
    }

    setState(() {
      _selectedIndex = index;
    });
  }

  Stream<List<Map<String, dynamic>>> _getLatestExercises() {
    final User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return Stream.value([]); // Return an empty list if the user is not logged in
    }

    return FirebaseFirestore.instance
        .collection('progress_logs')
        .where('userId', isEqualTo: user.uid)
        .orderBy('date', descending: true) // Order by the date field
        .limit(10)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => {
                  'exerciseType': doc['exerciseType'] ??
                      LocalizationHelper.translate(
                          context, 'unknown_exercise'),
                  'duration': doc['duration'] ?? '0 mins',
                  'repetitions': doc['repetitions'] ?? '0',
                  'date': doc['date'], // Keep the date as a string for display
                })
            .toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true, // Allows the body to extend below the bottom navigation bar
      backgroundColor: const Color(0xFF264653), // Set consistent background
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              LocalizationHelper.translate(context, 'home_progress_title'),
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white, // Set color to white
              ),
            ),
            IconButton(
              icon: const Icon(Icons.notifications, color: Colors.white),
              onPressed: () {
                Navigator.pushNamed(context, '/notifications'); // Notifications route
              },
            ),
          ],
        ),
        centerTitle: false,
        backgroundColor: const Color(0xFF264653), // Dark teal matching theme
      ),
      body: Column(
        children: [
          // Top Section with Bar Chart
          Container(
            padding: const EdgeInsets.all(16.0),
            color: const Color(0xFF264653), // Dark teal matching theme
            child: SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: 8,
                          color: const Color(0xFFA5D6A7),
                        ), // Light green bar
                      ],
                    ),
                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: 6,
                          color: const Color(0xFFF4A261),
                        ), // Orange bar
                      ],
                    ),
                    BarChartGroupData(
                      x: 2,
                      barRods: [
                        BarChartRodData(
                          toY: 10,
                          color: const Color(0xFFE76F51),
                        ), // Red bar
                      ],
                    ),
                  ],
                  titlesData: FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  gridData: FlGridData(
                    drawHorizontalLine: true,
                    horizontalInterval: 2, // Gridline interval
                    getDrawingHorizontalLine: (value) {
                      return FlLine(
                        color: Colors.white.withOpacity(0.5),
                        strokeWidth: 1,
                        dashArray: [5, 5],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // Rounded Card for Total Hours, Completed Tasks, and Latest Exercises
          Expanded(
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(32),
                  topRight: Radius.circular(32),
                ),
              ),
              color: const Color(0xFFECECEC), // Light gray card background
              margin: EdgeInsets.zero, // Removed margin
              elevation: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatCard(
                            title: LocalizationHelper.translate(
                                context, 'total_hours'),
                            value:
                                '${totalMinutes ~/ 60} ${LocalizationHelper.translate(context, 'hours')} ${totalMinutes % 60} ${LocalizationHelper.translate(context, 'minutes')}',
                          ),
                          _buildStatCard(
                            title: LocalizationHelper.translate(
                                context, 'completed_tasks'),
                            value: '$completedTasks',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: StreamBuilder<List<Map<String, dynamic>>>(
                        stream: _getLatestExercises(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          if (snapshot.hasError) {
                            return Center(
                              child: Text(LocalizationHelper.translate(
                                  context, 'error_loading_exercises')),
                            );
                          }

                          final exercises = snapshot.data ?? [];

                          if (exercises.isEmpty) {
                            return Center(
                              child: Text(LocalizationHelper.translate(
                                  context, 'no_exercises_found')),
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            itemCount: exercises.length,
                            itemBuilder: (context, index) {
                              final exercise = exercises[index];
                              return _buildExerciseTile(
                                context,
                                title: exercise['exerciseType'] ?? '',
                                description:
                                    '${exercise['duration']} ${LocalizationHelper.translate(context, 'minutes')}, ${exercise['repetitions']} ${LocalizationHelper.translate(context, 'repetitions')}',
                                date: exercise['date'] ?? 'No date',
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavBar(
        selectedIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildStatCard({required String title, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.black54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildExerciseTile(BuildContext context,
      {required String title,
      required String description,
      required String date}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.secondary,
          child: Text(
            title.isNotEmpty ? title[0] : '?',
            style: const TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(title),
        subtitle: Text(description),
        trailing: Text(
          date,
          style: const TextStyle(color: Colors.black54),
        ),
      ),
    );
  }
}
