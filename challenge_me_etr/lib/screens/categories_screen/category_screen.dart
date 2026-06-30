import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:quickalert/quickalert.dart';
import '../../helpers/db_helper.dart';
import '../../models/task_model.dart';
import '../../models/category_model.dart';
import 'modify_tasks_screen.dart';

class CategoryScreen extends StatefulWidget {
  final CategoryModel category;

  const CategoryScreen({super.key, required this.category});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  TaskModel? _currentTask;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRandomTask();
  }

  Future<void> _loadRandomTask() async {
    setState(() => isLoading = true);

    final tasks = await DbHelper.getTasksByCategory(widget.category.id!);
    final availableTasks = tasks.where((task) => !task.isCompleted).toList();

    setState(() {
      if (availableTasks.isNotEmpty) {
        availableTasks.shuffle();
        _currentTask = availableTasks.first;
      } else {
        _currentTask = null;
      }
      isLoading = false;
    });
  }

  Future<void> _markAsDone() async {
    if (_currentTask == null) return;

    await DbHelper.markTaskCompleted(_currentTask!.id!);

    QuickAlert.show(
      context: context,
      type: QuickAlertType.success,
      title: 'Nice!',
      text: 'You completed the task 🎉',
      confirmBtnColor: widget.category.color,
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
      },
    );

    await _loadRandomTask();
  }

  Future<void> _resetTasks() async {
    await DbHelper.resetTasks(widget.category.id!);

    QuickAlert.show(
      context: context,
      type: QuickAlertType.info,
      title: 'Reset!',
      text: 'All tasks have been reset ✅',
      confirmBtnColor: widget.category.color,
      onConfirmBtnTap: () {
        Navigator.of(context).pop();
      },
    );

    await _loadRandomTask();
  }

  @override
  Widget build(BuildContext context) {
    final category = widget.category;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [category.color.withOpacity(0.85), category.color],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const FaIcon(
                      FontAwesomeIcons.reply,
                      color: Colors.white,
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),

                const SizedBox(height: 10),

                FaIcon(
                  category.icon,
                  size: 60,
                  color: Colors.white,
                  shadows: const [
                    Shadow(
                      color: Colors.black26,
                      offset: Offset(2, 2),
                      blurRadius: 6,
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                _buildTitle(category.title),

                const SizedBox(height: 6),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Take on challenges to grow in ${category.title}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white,
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(25),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          offset: Offset(0, 8),
                          blurRadius: 14,
                        ),
                        BoxShadow(
                          color: Colors.black12,
                          offset: Offset(0, 4),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          "TODAY'S CHALLENGE",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.black54,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 14),
                        if (isLoading)
                          const CircularProgressIndicator()
                        else
                          Text(
                            _currentTask?.description ?? 'No Task Yet',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: _currentTask == null ? null : _markAsDone,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 20,
                            ),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _currentTask == null
                                    ? [Colors.greenAccent, Colors.green]
                                    : [Colors.orangeAccent, Colors.deepOrange],
                              ),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                FaIcon(
                                  _currentTask == null
                                      ? FontAwesomeIcons.checkCircle
                                      : FontAwesomeIcons.circle,
                                  color: Colors.white,
                                  size: 18,
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  _currentTask == null
                                      ? 'Completed'
                                      : 'Mark as Done',
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
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: _buildActionButton(
                    icon: FontAwesomeIcons.shuffle,
                    label: 'Get Random Challenge',
                    onTap: _loadRandomTask,
                    color: _currentTask == null ? Colors.grey : Colors.black87,
                    isDisabled: _currentTask == null,
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    children: [
                      _buildActionButton(
                        icon: FontAwesomeIcons.pen,
                        label: 'Modify Tasks',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ModifyTasksScreen(
                                categoryId: category.id!,
                                categoryTitle: category.title,
                              ),
                            ),
                          ).then((_) => _loadRandomTask());
                        },
                        color: Colors.blueAccent,
                      ),
                      const SizedBox(height: 12),
                      _buildActionButton(
                        icon: FontAwesomeIcons.undo,
                        label: 'Reset Tasks',
                        onTap: _resetTasks,
                        color: Colors.redAccent,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 50),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle(String text) {
    return FittedBox(
      fit: BoxFit.scaleDown,
      child: Stack(
        children: [
          Positioned(
            left: 3,
            top: 3,
            child: Text(
              text,
              style: GoogleFonts.bahiana(
                fontSize: 60,
                foreground: Paint()
                  ..style = PaintingStyle.stroke
                  ..strokeWidth = 6
                  ..color = Colors.black45,
              ),
            ),
          ),
          Text(
            text,
            style: GoogleFonts.bahiana(
              fontSize: 60,
              color: Colors.white,
              shadows: const [
                Shadow(
                  color: Colors.black26,
                  offset: Offset(2, 2),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
    bool isDisabled = false,
  }) {
    return GestureDetector(
      onTap: isDisabled ? null : onTap,
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: isDisabled ? Colors.grey : (color ?? Colors.black87),
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
              FaIcon(icon, color: Colors.white, size: 18),
              const SizedBox(width: 10),
              Text(
                label,
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
    );
  }
}
