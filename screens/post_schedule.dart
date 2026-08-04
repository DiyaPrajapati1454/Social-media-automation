import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../Notification_helper.dart';

class PostSchedulerScreen extends StatefulWidget {
  const PostSchedulerScreen({super.key});

  @override
  State<PostSchedulerScreen> createState() => _PostSchedulerScreenState();
}

class _PostSchedulerScreenState extends State<PostSchedulerScreen> {
  final _formKey = GlobalKey<FormState>();
  final topicController = TextEditingController();
  final descriptionController = TextEditingController();
  DateTime? selectedDateTime;

  // Function to pick date & time
  Future<void> _pickDateTime() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (pickedTime != null) {
        setState(() {
          selectedDateTime = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _schedulePost() async {
    if (_formKey.currentState!.validate() && selectedDateTime != null) {
      // Ensure selected time is in the future
      if (selectedDateTime!.isBefore(DateTime.now())) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(' Please select a future date & time!'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Schedule Notification
      await NotificationHelper.scheduleNotification(
        id: DateTime.now().millisecondsSinceEpoch ~/ 1000, // Unique ID
        title: topicController.text,
        body: descriptionController.text,
        scheduledTime: selectedDateTime!,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post Scheduled Successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(' Please fill all fields and select a date & time!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Schedule a Post"),
        backgroundColor: Colors.blueAccent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Post Topic Field
              TextFormField(
                controller: topicController,
                validator: (value) =>
                value!.isEmpty ? "Please enter a topic" : null,
                decoration: InputDecoration(
                  labelText: "Post Topic",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Post Description Field
              TextFormField(
                controller: descriptionController,
                validator: (value) =>
                value!.isEmpty ? "Please enter a description" : null,
                maxLines: 4,
                decoration: InputDecoration(
                  labelText: "Post Description",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Date & Time Picker
              ListTile(
                title: Text(
                  selectedDateTime == null
                      ? "Pick Date & Time"
                      : "Scheduled: ${DateFormat('yyyy-MM-dd HH:mm').format(selectedDateTime!)}",
                ),
                trailing: Icon(Icons.calendar_today),
                onTap: _pickDateTime,
              ),
              SizedBox(height: 20),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _schedulePost,
                  child: Text(" Schedule Post"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}