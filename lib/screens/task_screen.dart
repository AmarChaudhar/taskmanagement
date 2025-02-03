import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:taskmanagement/authentication/auth_bloc.dart';
import 'package:taskmanagement/authentication/auth_event.dart';
import '../task_model/task_model.dart';
import 'login_screen.dart';
import 'task_detail_screen.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref("tasks");
  final TextEditingController searchController = TextEditingController();

  String _searchQuery = "";
  String _selectedPriorityFilter = "All";
  String _selectedStatusFilter = "All";

  List<TaskModel> tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  /// Fetch tasks from Firebase
  void _fetchTasks() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    databaseRef.orderByChild("userId").equalTo(user.uid).onValue.listen((
      event,
    ) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data != null) {
        List<TaskModel> loadedTasks = [];
        data.forEach((key, value) {
          loadedTasks.add(TaskModel.fromMap(key, value));
        });

        // Sort tasks by due date (earliest first)
        loadedTasks.sort((a, b) {
          DateTime dateA = DateTime.tryParse(a.dueDate) ?? DateTime.now();
          DateTime dateB = DateTime.tryParse(b.dueDate) ?? DateTime.now();
          return dateA.compareTo(dateB);
        });

        setState(() {
          tasks = loadedTasks;
        });
      } else {
        setState(() {
          tasks = [];
        });
      }
    });
  }

  /// Filter tasks based on search text, priority and status
  List<TaskModel> _applyFilters() {
    return tasks.where((task) {
      bool matchesSearch = task.title.toLowerCase().contains(
        _searchQuery.toLowerCase(),
      );
      bool matchesPriority =
          _selectedPriorityFilter == "All" ||
          task.priority.toLowerCase() == _selectedPriorityFilter.toLowerCase();
      bool matchesStatus =
          _selectedStatusFilter == "All" ||
          (_selectedStatusFilter == "Completed"
              ? task.isCompleted
              : !task.isCompleted);
      return matchesSearch && matchesPriority && matchesStatus;
    }).toList();
  }

  /// Get a color for each priority level
  Color _getPriorityColor(String priority) {
    switch (priority.toLowerCase()) {
      case "high":
        return Colors.redAccent;
      case "medium":
        return Colors.orangeAccent;
      case "low":
      default:
        return Colors.green;
    }
  }

  // search bar
  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: InputDecoration(
            hintText: "Search tasks...",
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.deepPurple),
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ),
    );
  }

  // Filter chips for priority and status filtering
  Widget _buildFilterChips() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Filter by Priority",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                ["All", "Low", "Medium", "High"].map((priority) {
                  return ChoiceChip(
                    label: Text(priority),
                    selected: _selectedPriorityFilter == priority,
                    onSelected: (selected) {
                      setState(() {
                        _selectedPriorityFilter = selected ? priority : "All";
                      });
                    },
                    selectedColor: Colors.deepPurple.shade200,
                  );
                }).toList(),
          ),
          SizedBox(height: 16),
          Text(
            "Filter by Status",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                ["All", "Completed", "Incomplete"].map((status) {
                  return ChoiceChip(
                    label: Text(status),
                    selected: _selectedStatusFilter == status,
                    onSelected: (selected) {
                      setState(() {
                        _selectedStatusFilter = selected ? status : "All";
                      });
                    },
                    selectedColor: Colors.deepPurple.shade200,
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  // An improved task card with a colored priority indicator
  Widget _buildTaskCard(TaskModel task) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          // Navigate to the detail screen for editing
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TaskDetailScreen(task: task),
            ),
          );
        },
        child: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              // priority indicator
              Container(
                width: 6,
                height: 60,
                decoration: BoxDecoration(
                  color: _getPriorityColor(task.priority),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Due: ${DateFormat.yMMMd().format(DateTime.parse(task.dueDate))}",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                    SizedBox(height: 4),
                    Text(
                      "Priority: ${task.priority}",
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              // Completion status checkbox
              Checkbox(
                value: task.isCompleted,
                activeColor: Colors.deepPurple,
                onChanged: (value) {
                  setState(() {
                    task.isCompleted = value!;
                  });
                  databaseRef.child(task.id).update({'isCompleted': value});
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    List<TaskModel> filteredTasks = _applyFilters();

    return Scaffold(
      appBar: AppBar(
        title: Text('Task Management'),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(SignOutRequested());
              Future.delayed(Duration(milliseconds: 200), () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (route) => false,
                );
              });
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child:
                filteredTasks.isEmpty
                    ? Center(
                      child: Text(
                        "No tasks found",
                        style: TextStyle(fontSize: 18),
                      ),
                    )
                    : ListView.builder(
                      padding: EdgeInsets.only(bottom: 16),
                      itemCount: filteredTasks.length,
                      itemBuilder: (context, index) {
                        return _buildTaskCard(filteredTasks[index]);
                      },
                    ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: () async {
          // Navigate to the create new task or edit task screen
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TaskDetailScreen()),
          );
        },
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
