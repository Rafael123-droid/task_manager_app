import 'package:flutter/material.dart';
import '../services/api_service.dart';

class TasksScreen extends StatefulWidget {
  final int userId;
  final String userName;

  const TasksScreen({super.key, required this.userId, required this.userName});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late Future<List<dynamic>> tasksFuture;
  String filter = "all";
  String search = "";

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    tasksFuture = ApiService.getTasks(userId: widget.userId);
  }

  Future<void> _addTask() async {
    final ctrl = TextEditingController();
    await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Task"),
        content: TextField(
          controller: ctrl,
          decoration: const InputDecoration(labelText: "Task title"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (ctrl.text.trim().isNotEmpty) {
                await ApiService.createTask(widget.userId, ctrl.text.trim());
                Navigator.pop(context);
                setState(_reload);
              }
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  Future<void> _markDone(int id) async {
    await ApiService.updateTask(id, status: 'done');
    setState(_reload);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("${widget.userName}'s Tasks")),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTask,
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<dynamic>>(
        future: tasksFuture,
        builder: (context, snap) {
          if (!snap.hasData)
            return const Center(child: CircularProgressIndicator());

          final all = snap.data!;
          final filtered = all
              .where((t) => t['title'].toLowerCase().contains(search))
              .where((t) => filter == "all" || t['status'] == filter)
              .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    hintText: "Search task...",
                  ),
                  onChanged: (v) => setState(() => search = v.toLowerCase()),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: ["all", "pending", "done"].map((s) {
                  return ChoiceChip(
                    label: Text(s.toUpperCase()),
                    selected: filter == s,
                    onSelected: (_) => setState(() => filter = s),
                  );
                }).toList(),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: filtered.isEmpty
                    ? const Center(child: Text("No tasks found"))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filtered.length,
                        itemBuilder: (_, i) {
                          final t = filtered[i];
                          final done = t['status'] == 'done';

                          return Card(
                            child: ListTile(
                              leading: Icon(
                                done
                                    ? Icons.check_circle
                                    : Icons.radio_button_unchecked,
                                color: done ? Colors.green : Colors.orange,
                              ),
                              title: Text(
                                t['title'],
                                style: TextStyle(
                                  decoration: done
                                      ? TextDecoration.lineThrough
                                      : null,
                                  color: done ? Colors.grey : Colors.black,
                                ),
                              ),
                              subtitle: Text(done ? "Completed" : "Pending"),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (!done)
                                    IconButton(
                                      icon: const Icon(
                                        Icons.check,
                                        color: Colors.green,
                                      ),
                                      onPressed: () => _markDone(t['id']),
                                    ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete,
                                      color: Colors.red,
                                    ),
                                    onPressed: () async {
                                      await ApiService.deleteTask(t['id']);
                                      setState(_reload);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}
