import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../helpers/db_helper.dart';
import '../../models/task_model.dart';

class ModifyTasksScreen extends StatefulWidget {
  final int categoryId;
  final String categoryTitle;

  const ModifyTasksScreen({
    super.key,
    required this.categoryId,
    required this.categoryTitle,
  });

  @override
  State<ModifyTasksScreen> createState() => _ModifyTasksScreenState();
}

class _ModifyTasksScreenState extends State<ModifyTasksScreen> {
  List<TaskModel> _tasks = [];
  bool isLoading = true;
  final _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => isLoading = true);
    _tasks = await DbHelper.getTasksByCategory(widget.categoryId);
    setState(() => isLoading = false);
  }

  Future<void> _showTaskDialog({
    required String title,
    String? initialText,
    required Function(String) onConfirm,
  }) async {
    _textController.text = initialText ?? '';
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          title,
          style: GoogleFonts.bahiana(fontSize: 28, color: Colors.black87),
        ),
        content: TextField(
          controller: _textController,
          decoration: InputDecoration(
            hintText: 'Task Description',
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[700]),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (_textController.text.trim().isEmpty) return;
              onConfirm(_textController.text.trim());
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              backgroundColor: Colors.deepPurple,
            ),
            child: Text(
              'Save',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteTask(TaskModel task) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white.withOpacity(0.95),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Delete Task?',
          style: GoogleFonts.bahiana(fontSize: 28, color: Colors.redAccent),
        ),
        content: Text(
          'Are you sure you want to delete this task?',
          style: GoogleFonts.poppins(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[700]),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              await DbHelper.deleteTask(task.id!);
              Navigator.pop(context);
              _loadTasks();
            },
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Colors.redAccent,
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _addNewTask() {
    _showTaskDialog(
      title: 'Add New Task',
      onConfirm: (text) async {
        await DbHelper.insertTask(
          TaskModel(
            categoryId: widget.categoryId,
            description: text,
            isCompleted: false,
          ),
        );
        _loadTasks();
      },
    );
  }

  void _editTask(TaskModel task) {
    _showTaskDialog(
      title: 'Edit Task',
      initialText: task.description,
      onConfirm: (text) async {
        await DbHelper.updateTask(task.copyWith(description: text));
        _loadTasks();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              widget.categoryId == 1
                  ? Colors.lightBlueAccent
                  : widget.categoryId == 2
                  ? Colors.orangeAccent
                  : widget.categoryId == 3
                  ? Colors.greenAccent
                  : widget.categoryId == 4
                  ? Colors.yellowAccent
                  : widget.categoryId == 5
                  ? Colors.purpleAccent
                  : Colors.pinkAccent,
              Colors.white.withOpacity(0.95),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    IconButton(
                      icon: const FaIcon(
                        FontAwesomeIcons.reply,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Stack(
                        children: [
                          Positioned(
                            left: 3,
                            top: 3,
                            child: Text(
                              widget.categoryTitle.toUpperCase(),
                              style: GoogleFonts.bahiana(
                                fontSize: 55,
                                foreground: Paint()
                                  ..style = PaintingStyle.stroke
                                  ..strokeWidth = 6
                                  ..color = Colors.black26,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            widget.categoryTitle.toUpperCase(),
                            style: GoogleFonts.bahiana(
                              fontSize: 55,
                              color: Colors.white,
                              shadows: const [
                                Shadow(
                                  color: Colors.black26,
                                  offset: Offset(2, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : _tasks.isEmpty
                    ? Center(
                        child: Text(
                          'No tasks yet!',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: _tasks.length,
                        itemBuilder: (context, index) {
                          final task = _tasks[index];
                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                            elevation: 6,
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            shadowColor: Colors.black45,
                            color: Colors.white.withOpacity(0.9),
                            child: ListTile(
                              title: Text(
                                task.description,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                task.isCompleted ? 'Completed' : 'Pending',
                                style: GoogleFonts.poppins(
                                  color: task.isCompleted
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const FaIcon(
                                      FontAwesomeIcons.pen,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => _editTask(task),
                                  ),
                                  IconButton(
                                    icon: const FaIcon(
                                      FontAwesomeIcons.trash,
                                      color: Colors.red,
                                    ),
                                    onPressed: () => _deleteTask(task),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),

              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: GestureDetector(
                  onTap: _addNewTask,
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.deepPurple, Colors.purpleAccent],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const FaIcon(
                            FontAwesomeIcons.plus,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Add New Task',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
