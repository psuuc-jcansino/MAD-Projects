import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../helpers/db_helper.dart';
import '../models/category_model.dart';

class TasksHistoryScreen extends StatefulWidget {
  const TasksHistoryScreen({super.key});

  @override
  State<TasksHistoryScreen> createState() => _TasksHistoryScreenState();
}

class _TasksHistoryScreenState extends State<TasksHistoryScreen> {
  List<TaskWithCategory> completedTasks = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCompletedTasks();
  }

  Future<void> _loadCompletedTasks() async {
    setState(() => isLoading = true);

    final tasks = await DbHelper.getCompletedTasksWithCategory();

    completedTasks = tasks.map((map) {
      final categoryId = map['categoryId'] ?? 0;

      final category = CategoryModel.defaultCategories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => CategoryModel(
          id: 0,
          title: map['categoryTitle'] ?? 'Unknown',
          icon: map['categoryIcon'] != null
              ? IconData(map['categoryIcon'], fontFamily: 'FontAwesomeSolid')
              : FontAwesomeIcons.question,
          color: map['categoryColor'] != null
              ? Color(map['categoryColor'])
              : Colors.blueGrey,
        ),
      );

      return TaskWithCategory(
        id: map['id'],
        description: map['description'] ?? '',
        categoryId: categoryId,
        isCompleted: map['isCompleted'] == 1,
        completedAt: map['completedAt'] != null
            ? DateTime.tryParse(map['completedAt'])
            : null,
        categoryTitle: category.title,
        categoryColor: category.color,
        categoryIcon: category.icon,
      );
    }).toList();

    setState(() => isLoading = false);
  }

  Future<void> _markTaskIncomplete(int id) async {
    await DbHelper.markTaskIncomplete(id);
    await _loadCompletedTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4DD0E1), Color(0xFFFFB74D)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 16),
              _buildTitle(),
              const SizedBox(height: 20),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : completedTasks.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: completedTasks.length,
                        itemBuilder: (context, index) {
                          final task = completedTasks[index];
                          final completedDate = task.completedAt != null
                              ? DateFormat(
                                  'MMM dd, yyyy',
                                ).format(task.completedAt!)
                              : 'Unknown';

                          return Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            elevation: 4,
                            color: task.categoryColor.withOpacity(0.9),
                            child: ListTile(
                              leading: FaIcon(
                                task.categoryIcon,
                                color: Colors.white,
                                size: 32,
                              ),
                              title: Text(
                                task.description,
                                style: GoogleFonts.poppins(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              subtitle: Text(
                                '${task.categoryTitle} • $completedDate',
                                style: GoogleFonts.poppins(
                                  color: Colors.white70,
                                ),
                              ),
                              trailing: GestureDetector(
                                onTap: () => _markTaskIncomplete(task.id!),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.redAccent,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    'Undo',
                                    style: GoogleFonts.poppins(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            icon: const FaIcon(
              FontAwesomeIcons.reply,
              color: Colors.white,
              size: 28,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Center(
              child: Stack(
                children: [
                  Positioned(
                    left: 4,
                    top: 4,
                    child: Text(
                      'TASK HISTORY',
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
                    'TASK HISTORY',
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
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(
            FontAwesomeIcons.clipboardCheck,
            size: 60,
            color: Colors.white70,
          ),
          const SizedBox(height: 20),
          Text(
            'No completed challenges yet',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Finish your first challenge to see it here!',
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.white70),
          ),
        ],
      ),
    );
  }
}

class TaskWithCategory {
  final int? id;
  final String description;
  final int categoryId;
  final bool isCompleted;
  final DateTime? completedAt;
  final String categoryTitle;
  final Color categoryColor;
  final IconData categoryIcon;

  TaskWithCategory({
    this.id,
    required this.description,
    required this.categoryId,
    this.isCompleted = false,
    this.completedAt,
    required this.categoryTitle,
    required this.categoryColor,
    required this.categoryIcon,
  });
}
