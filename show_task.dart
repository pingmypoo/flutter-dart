import 'package:flutter/material.dart';
import 'package:flutterapp2/database_helper.dart';
import 'package:flutterapp2/task_model.dart';

class ShowTask extends StatefulWidget {
  const ShowTask({super.key});

  @override
  State<ShowTask> createState() => _ShowTaskState();
}

class _ShowTaskState extends State<ShowTask> {
  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task List'),
        backgroundColor: Colors.blueAccent,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showInsertTaskForm();
        },
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Task>>(
        future: _fetchAllTasks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks available.'));
          } else {
            final tasks = snapshot.data!;
            return ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final task = tasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.description ?? ''),
                  trailing: Icon(
                    task.isDone ? Icons.check_box : Icons.check_box_outline_blank,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  void showInsertTaskForm() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Task'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _titleTextController,
                decoration: const InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _addNewTask(
                  _titleTextController.text,
                  _descriptionController.text,
                );
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addNewTask(String title, String description) async {
    if (title.isEmpty) return;

    final newTask = Task(title: title, description: description, isDone: false);
    await DatabaseHelper.instance.insertTask(newTask);
    _titleTextController.clear();
    _descriptionController.clear();
    if (mounted) {
      Navigator.of(context).pop();
      setState(() {}); // เพื่อรีเฟรชรายการในหน้าจอ
    }
  }

  Future<List<Task>> _fetchAllTasks() async {
    return await DatabaseHelper.instance.readAllTasks();
  }
}
