import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TimerPage(),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Cursive',
      ),
    );
  }
}

class TimerPage extends StatefulWidget {
  const TimerPage({super.key});

  @override
  _TimerPageState createState() => _TimerPageState();
}

class _TimerPageState extends State<TimerPage> {
  final TextEditingController _taskController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();

  List<Task> tasks = [];
  late Timer _timer;
  int totalDailyMinutes = 0;
  Task? _highlightedTask;

  void _startTimer(Task task) {
    setState(() {
      task.isRunning = true;
      _highlightedTask = task; // Store the currently running task
    });

    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (task.remainingTime == 0) {
        _timer.cancel();
        setState(() {
          task.isRunning = false;
          totalDailyMinutes += task.duration ~/ 60;
        });
        _showAlarm(task);
      } else {
        setState(() {
          task.remainingTime--;
        });
      }
    });
  }

  void _showAlarm(Task task) async {
    final player = AudioPlayer();
    await player.play(AssetSource('ding.mp3')); // Play the alarm sound

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.pinkAccent,
          title: Text("Time's Up!", style: TextStyle(color: Colors.white)),
          content: Text(
            'Your task "${task.name}" is completed my love!',
            style: TextStyle(color: Colors.white),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                player.stop(); // Stop the alarm sound
                Navigator.of(context).pop();
              },
              child: Text("Close", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _stopTimer(Task task) {
    _timer.cancel();
    setState(() {
      task.isRunning = false;
      if (_highlightedTask == task) {
        _highlightedTask = null; // Clear the highlighted task
      }
    });
  }

  void _addTask() {
    String taskName = _taskController.text;
    int? durationInMinutes = int.tryParse(_timeController.text);

    if (taskName.isNotEmpty &&
        durationInMinutes != null &&
        durationInMinutes > 0) {
      setState(() {
        tasks.add(Task(
          name: taskName,
          duration: durationInMinutes * 60,
          remainingTime: durationInMinutes * 60,
        ));
      });
      _taskController.clear();
      _timeController.clear();
    }
  }

  String _formatTime(int seconds) {
    int hours = seconds ~/ 3600;
    int minutes = (seconds % 3600) ~/ 60;
    int secondsRemaining = seconds % 60;
    return '$hours:${minutes.toString().padLeft(2, '0')}:${secondsRemaining.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/teddy.png'), // Background image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Highlighted Clock
                Container(
                  width: 200, // Increase width
                  height: 200, // Increase height
                  margin: EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white70,
                    border: Border.all(color: Colors.pinkAccent, width: 5),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 25),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment
                        .center, // Center align contents vertically
                    children: [
                      /*Text(
                        " $totalDailyMinutes",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: const Color.fromRGBO(99, 98, 98, 0.689),
                        ),
                      ),
                      SizedBox(height: 7),*/ // Space between label and timer
                      Text(
                          _highlightedTask != null
                              ? _formatTime(_highlightedTask!
                                  .remainingTime) // Current task timer
                              : "00:00:00", // Default when no task is running
                          style: TextStyle(
                            fontSize: 26, // Timer font size
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ))
                    ],
                  ),
                ),
                TextField(
                  controller: _taskController,
                  decoration: InputDecoration(
                    labelText: 'Enter Task (e.g. Study)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white70,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: _timeController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Duration (in minutes)',
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.white70,
                  ),
                ),
                SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _addTask,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    textStyle:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: Text('Add Task'),
                ),
                SizedBox(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: tasks.length,
                    itemBuilder: (context, index) {
                      final task = tasks[index];
                      return Card(
                        color: Colors.white70,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        margin: EdgeInsets.symmetric(vertical: 10),
                        child: ListTile(
                          title: Text(task.name,
                              style: TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold)),
                          subtitle: Text(
                              'Time Remaining: ${_formatTime(task.remainingTime)}'),
                          trailing: task.isRunning
                              ? IconButton(
                                  icon: Icon(Icons.stop, color: Colors.red),
                                  onPressed: () => _stopTimer(task),
                                )
                              : IconButton(
                                  icon: Icon(Icons.play_arrow,
                                      color: Colors.green),
                                  onPressed: () => _startTimer(task),
                                ),
                        ),
                      );
                    },
                  ),
                ),
                // Daily Tracker
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Text(
                    "Daily Record: $totalDailyMinutes minutes completed",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class Task {
  final String name;
  final int duration;
  int remainingTime;
  bool isRunning;

  Task({
    required this.name,
    required this.duration,
    required this.remainingTime,
    this.isRunning = false,
  });
}
