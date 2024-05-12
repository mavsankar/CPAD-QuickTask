import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:parse_server_sdk/parse_server_sdk.dart';
import 'task_provider.dart';
import 'task_model.dart';
import 'package:intl/intl.dart';

class TaskScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    bool firstLogin = true;
    return Scaffold(
      appBar: AppBar(
        title: Text('Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            // on presed logout and clear the task list in TaskProvider
            onPressed: () async {
              (await ParseUser.currentUser())!.logout();
              Provider.of<TaskProvider>(context, listen: false).clearTasks();
              Navigator.of(context).pushReplacementNamed('/');
            },
            
          ),
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () => _showTaskDialog(context),
          ),
        ],
      ),
      body: Consumer<TaskProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(child: CircularProgressIndicator());
          }
          if (firstLogin) {
            provider.fetchTasks();
            firstLogin = false;
          }
          if (provider.tasks.isEmpty) {
            return Center(child: Text('No tasks added.'));
          }
          return ListView.builder(
            itemCount: provider.tasks.length,
            itemBuilder: (context, index) {
              final task = provider.tasks[index];
              String formattedDate =
                  DateFormat('yyyy-MM-dd').format(task.dueDate);
              return Card(
                margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: ListTile(
                  title: Text(task.title,
                      style: TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('Due: $formattedDate'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: Colors.green),
                        onPressed: () => _showTaskDialog(context, task: task),
                      ),
                      Checkbox(
                        value: task.isCompleted,
                        onChanged: (value) {
                          provider.updateTaskStatus(task, value!);
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _confirmDelete(context, task, provider);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showTaskDialog(BuildContext context, {Task? task}) {
    bool isEditing = task != null;
    var titleController = TextEditingController(text: task?.title ?? '');
    var dueDateController = TextEditingController(
        text:
            task != null ? DateFormat('yyyy-MM-dd').format(task.dueDate) : '');

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(isEditing ? 'Edit Task' : 'Add New Task',
              style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: "Task Title",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    prefixIcon: Icon(Icons.title),
                    fillColor: Colors.grey[200],
                    filled: true,
                  ),
                ),
                SizedBox(height: 20),
                TextField(
                  controller: dueDateController,
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: "Due Date",
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8)),
                    suffixIcon: Icon(Icons.calendar_today),
                    fillColor: Colors.grey[200],
                    filled: true,
                  ),
                  onTap: () async {
                    DateTime? pickedDate = await showDatePicker(
                      context: context,
                      initialDate: task?.dueDate ?? DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (pickedDate != null) {
                      dueDateController.text =
                          DateFormat('yyyy-MM-dd').format(pickedDate);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
              onPressed: () => Navigator.of(context).pop(),
            ),
            Consumer<TaskProvider>(
              builder: (context, provider, child) {
                return provider.isLoading
                    ? CircularProgressIndicator()
                    : TextButton(
                        child: Text(isEditing ? 'Save Changes' : 'Add',
                            style: TextStyle(color: Colors.blue)),
                        onPressed: () async {
                          if (titleController.text.isNotEmpty &&
                              dueDateController.text.isNotEmpty) {
                            DateTime dueDate =
                                DateTime.parse(dueDateController.text);
                            if (isEditing) {
                              provider.updateTask(task!.copyWith(
                                  title: titleController.text,
                                  dueDate: dueDate));
                            } else {
                              provider.addTask(titleController.text, dueDate,
                                  (await ParseUser.currentUser())!.username!);
                            }
                            Navigator.of(context).pop();
                          }
                        },
                      );
              },
            ),
          ],
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, Task task, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Delete'),
          content: Text('Are you sure you want to delete this task?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red)),
              onPressed: () {
                provider.deleteTask(task);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
