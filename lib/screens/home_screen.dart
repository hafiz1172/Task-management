import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_helper.dart';
import '../services/sync_service.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Task> _tasks = [];
  bool _isSyncing = false;
  bool _showCompleted = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadTasks();
    _autoSync();
  }

  Future<void> _loadTasks() async {
    final list = await DatabaseHelper.instance.getAllTasks();
    setState(() {
      _tasks = list;
    });
  }

  Future<void> _autoSync() async {
    setState(() => _isSyncing = true);
    await SyncService.syncWithGoogleSheets();
    await _loadTasks();
    setState(() => _isSyncing = false);
  }

  void _addNewTaskDialog() {
    final titleController = TextEditingController();
    final notesController = TextEditingController();
    bool isStarred = false;
    String? dueDate;
    String? dueTime;
    String? repeatRule;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1E1F25),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                top: 16, left: 16, right: 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'New task',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                  TextField(
                    controller: notesController,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Add details',
                      hintStyle: TextStyle(color: Colors.grey),
                      border: InputBorder.none,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          isStarred ? Icons.star_rounded : Icons.star_border_rounded,
                          color: isStarred ? const Color(0xFF8AB4F8) : Colors.grey,
                        ),
                        onPressed: () => setModalState(() => isStarred = !isStarred),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_today_rounded, color: Colors.grey),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime(2020),
                            lastDate: DateTime(2030),
                          );
                          if (picked != null) {
                            setModalState(() {
                              dueDate = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.access_time_rounded, color: Colors.grey),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );
                          if (picked != null) {
                            setModalState(() {
                              dueTime = picked.format(context);
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.repeat_rounded, color: Colors.grey),
                        onPressed: () {
                          setModalState(() {
                            repeatRule = 'Weekly';
                          });
                        },
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () async {
                          if (titleController.text.trim().isNotEmpty) {
                            final newTask = Task(
                              id: DateTime.now().millisecondsSinceEpoch.toString(),
                              title: titleController.text.trim(),
                              notes: notesController.text.trim(),
                              isStarred: isStarred,
                              dueDate: dueDate,
                              dueTime: dueTime,
                              repeatRule: repeatRule,
                            );
                            await DatabaseHelper.instance.insertOrUpdate(newTask);
                            if (mounted) {
                              Navigator.pop(context);
                            }
                            _loadTasks();
                            _autoSync();
                          }
                        },
                        child: const Text('Save', style: TextStyle(color: Color(0xFF8AB4F8), fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeTasks = _tasks.where((t) => !t.isCompleted).toList();
    final starredTasks = _tasks.where((t) => t.isStarred && !t.isCompleted).toList();
    final completedTasks = _tasks.where((t) => t.isCompleted).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF131318),
      appBar: AppBar(
        backgroundColor: const Color(0xFF131318),
        elevation: 0,
        title: const Text('Tasks', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w500)),
        actions: [
          IconButton(
            icon: _isSyncing
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Icon(Icons.sync_rounded, color: Colors.white),
            onPressed: _autoSync,
          ),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: Colors.white),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: const Color(0xFF8AB4F8),
          labelColor: const Color(0xFF8AB4F8),
          unselectedLabelColor: Colors.grey,
          tabs: const [
            Tab(text: 'My Tasks'),
            Tab(text: 'Starred'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildTaskList(activeTasks, completedTasks),
          _buildTaskList(starredTasks, []),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF1E88E5),
        child: const Icon(Icons.add_rounded, color: Colors.white, size: 30),
        onPressed: _addNewTaskDialog,
      ),
    );
  }

  Widget _buildTaskList(List<Task> active, List<Task> completed) {
    if (active.isEmpty && completed.isEmpty) {
      return const Center(
        child: Text('All tasks completed! Nice work!', style: TextStyle(color: Colors.grey, fontSize: 16)),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ...active.map((task) => _buildTaskTile(task)),
        if (completed.isNotEmpty) ...[
          const SizedBox(height: 15),
          InkWell(
            onTap: () => setState(() => _showCompleted = !_showCompleted),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Completed (${completed.length})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  Icon(_showCompleted ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded, color: Colors.white),
                ],
              ),
            ),
          ),
          if (_showCompleted)
            ...completed.map((task) => _buildTaskTile(task, isCompletedSection: true)),
        ],
      ],
    );
  }

  Widget _buildTaskTile(Task task, {bool isCompletedSection = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1F25),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Checkbox(
          value: task.isCompleted,
          activeColor: const Color(0xFF8AB4F8),
          checkColor: Colors.black,
          shape: const CircleBorder(),
          onChanged: (val) async {
            task.isCompleted = val ?? false;
            task.isSynced = 0;
            await DatabaseHelper.instance.insertOrUpdate(task);
            _loadTasks();
            _autoSync();
          },
        ),
        title: Text(
          task.title,
          style: TextStyle(
            color: Colors.white,
            decoration: isCompletedSection ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: (task.notes.isNotEmpty || task.dueDate != null)
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (task.notes.isNotEmpty) Text(task.notes, style: const TextStyle(color: Colors.grey, fontSize: 12)),
                  if (task.dueDate != null)
                    Text('${task.dueDate} ${task.dueTime ?? ''}', style: const TextStyle(color: Color(0xFF8AB4F8), fontSize: 11)),
                ],
              )
            : null,
        trailing: IconButton(
          icon: Icon(
            task.isStarred ? Icons.star_rounded : Icons.star_border_rounded,
            color: task.isStarred ? const Color(0xFF8AB4F8) : Colors.grey,
          ),
          onPressed: () async {
            task.isStarred = !task.isStarred;
            task.isSynced = 0;
            await DatabaseHelper.instance.insertOrUpdate(task);
            _loadTasks();
            _autoSync();
          },
        ),
      ),
    );
  }
}
