import 'package:flutter/material.dart';

import 'db/db_helper.dart';

class TaskPage extends StatefulWidget {
  @override
  _TaskPageState createState() => _TaskPageState();
}

class _TaskPageState extends State<TaskPage> {
  List<Map<String, dynamic>> tasks = [];
  final dbHelper = DBHelper();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final data = await dbHelper.getTasks();
    setState(() {
      tasks = data;
    });
  }

  void _showTaskDialog({Map<String, dynamic>? task}) {
    TextEditingController taskController = TextEditingController(
      text: task != null ? task['title'] : '',
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(task != null ? 'تعديل المهمة' : 'إضافة مهمة جديدة'),
          content: TextField(
            controller: taskController,
            decoration: InputDecoration(
              labelText: 'عنوان المهمة',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('إلغاء'),
            ),
            TextButton(
              onPressed: () async {
                String taskTitle = taskController.text.trim();
                if (taskTitle.isNotEmpty) {
                  if (task != null) {
                    await dbHelper.updateTask({
                      'id': task['id'],
                      'title': taskTitle,
                      'completed': task['completed']
                    });
                  } else {
                    await dbHelper.insertTask({
                      'title': taskTitle,
                      'completed': 0,
                    });
                  }
                  Navigator.of(context).pop();
                  _loadTasks();
                }
              },
              child: Text(task != null ? 'تعديل' : 'إضافة'),
            ),
          ],
        );
      },
    );
  }

  void _deleteTask(int id) async {
    await dbHelper.deleteTask(id);
    _loadTasks();
  }

  void _toggleTaskCompletion(Map<String, dynamic> task) async {
    await dbHelper.updateTask({
      'id': task['id'],
      'title': task['title'],
      'completed': task['completed'] == 1 ? 0 : 1
    });
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('قائمة المهام'),
      ),
      body: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          var task = tasks[index];
          return ListTile(
            title: Text(
              task['title'],
              style: TextStyle(
                decoration: task['completed'] == 1
                    ? TextDecoration.lineThrough
                    : TextDecoration.none,
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: Icon(Icons.edit),
                  onPressed: () {
                    _showTaskDialog(task: task);
                  },
                ),
                IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _deleteTask(task['id']);
                  },
                ),
              ],
            ),
            leading: Checkbox(
              value: task['completed'] == 1,
              onChanged: (value) {
                _toggleTaskCompletion(task);
              },
            ),
            onTap: () {
              _toggleTaskCompletion(task);
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTaskDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
