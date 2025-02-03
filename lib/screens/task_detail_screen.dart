import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../task_model/task_model.dart';

class TaskDetailScreen extends StatefulWidget {
  final TaskModel? task; // If null, we are creating a new task

  const TaskDetailScreen({this.task});

  @override
  _TaskDetailScreenState createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref("tasks");
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late TextEditingController _dueDateController;

  String _selectedPriority = "Low";
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task?.title ?? "");
    _descriptionController = TextEditingController(
      text: widget.task?.description ?? "",
    );
    _dueDateController = TextEditingController(
      text:
          widget.task?.dueDate ??
          DateFormat('yyyy-MM-dd').format(DateTime.now()),
    );
    _selectedPriority = widget.task?.priority ?? "Low";
    _isCompleted = widget.task?.isCompleted ?? false;
  }

  // Show a date picker for the due date field
  Future<void> _selectDueDate() async {
    DateTime initialDate;
    try {
      initialDate = DateTime.parse(_dueDateController.text);
    } catch (e) {
      initialDate = DateTime.now();
    }
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      _dueDateController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  // Save (create/update) the task to Firebase
  void _saveTask() {
    if (_formKey.currentState!.validate()) {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("You must be logged in to save tasks")),
        );
        return;
      }

      TaskModel task = TaskModel(
        widget.task?.id ?? "",
        _titleController.text,
        _descriptionController.text,
        _dueDateController.text,
        _selectedPriority,
        user.uid, // Associate task with logged-in user
        isCompleted: _isCompleted,
      );

      if (widget.task == null) {
        // Create new task
        String newTaskId = databaseRef.push().key!;
        task = task.copyWith(id: newTaskId);
        databaseRef.child(newTaskId).set(task.toMap());
      } else {
        // Update existing task
        databaseRef.child(task.id).set(task.toMap());
      }

      Navigator.pop(context);
    }
  }

  /// Delete the task from Firebase
  void _deleteTask() {
    if (widget.task != null) {
      databaseRef.child(widget.task!.id).remove();
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.task != null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Task" : "New Task"),
        actions:
            isEditing
                ? [IconButton(icon: Icon(Icons.delete), onPressed: _deleteTask)]
                : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: "Title"),
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? "Please enter a title"
                                : null,
                  ),
                  SizedBox(height: 16),
                  TextFormField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: "Description"),
                    maxLines: 3,
                    validator:
                        (value) =>
                            value == null || value.isEmpty
                                ? "Please enter a description"
                                : null,
                  ),
                  SizedBox(height: 16),
                  GestureDetector(
                    onTap: _selectDueDate,
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: _dueDateController,
                        decoration: InputDecoration(
                          labelText: "Due Date",
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                        validator:
                            (value) =>
                                value == null || value.isEmpty
                                    ? "Please select a due date"
                                    : null,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    value: _selectedPriority,
                    decoration: InputDecoration(labelText: "Priority"),
                    items:
                        ["Low", "Medium", "High"].map((priority) {
                          return DropdownMenuItem<String>(
                            value: priority,
                            child: Text(priority),
                          );
                        }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedPriority = value!;
                      });
                    },
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Text("Mark as Completed", style: TextStyle(fontSize: 16)),
                      Spacer(),
                      Switch(
                        value: _isCompleted,
                        activeColor: Colors.deepPurple,
                        inactiveTrackColor: Colors.deepPurple,
                        onChanged: (value) {
                          setState(() {
                            _isCompleted = value;
                          });
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.deepPurple,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _saveTask,
                    child: Text(
                      isEditing ? "Update Task" : "Create Task",
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
