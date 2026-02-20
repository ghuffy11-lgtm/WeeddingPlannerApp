import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../utils/snackbar_helper.dart';
import '../widgets/loading_state.dart';
import '../widgets/empty_state.dart';
import '../widgets/filter_chip_row.dart';
import '../widgets/task_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Map<String, dynamic>> _tasks = [];
  bool _isLoading = true;
  String _filter = 'All';

  static const List<String> _filterOptions = [
    'All',
    'Pending',
    'Completed',
    'Venue',
    'Catering',
    'Photography',
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final auth = context.read<AuthProvider>();
    final response = await auth.api.getTasks();

    if (mounted) {
      setState(() {
        if (response.isSuccess) {
          _tasks = List<Map<String, dynamic>>.from(response.responseData ?? []);
        }
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> get _filteredTasks {
    if (_filter == 'All') return _tasks;
    if (_filter == 'Pending') {
      return _tasks.where((t) => t['status'] != 'completed').toList();
    }
    if (_filter == 'Completed') {
      return _tasks.where((t) => t['status'] == 'completed').toList();
    }
    return _tasks.where((t) => t['category']?.toString().toLowerCase() == _filter.toLowerCase()).toList();
  }

  Future<void> _toggleTask(Map<String, dynamic> task) async {
    final auth = context.read<AuthProvider>();
    final isCompleted = task['status'] == 'completed';
    final response = await auth.api.updateTask(
      task['id'],
      {'status': isCompleted ? 'pending' : 'completed'},
    );

    if (response.isSuccess) {
      await _loadData();
    } else if (mounted) {
      SnackBarHelper.showError(context, response.errorMessage ?? 'Failed to update task');
    }
  }

  Future<void> _deleteTask(String id) async {
    final auth = context.read<AuthProvider>();
    final response = await auth.api.deleteTask(id);

    if (response.isSuccess) {
      await _loadData();
      if (mounted) SnackBarHelper.showSuccess(context, 'Task deleted');
    } else if (mounted) {
      SnackBarHelper.showError(context, response.errorMessage ?? 'Failed to delete');
    }
  }

  void _showTaskDialog([Map<String, dynamic>? existing]) {
    final isEdit = existing != null;
    final titleController = TextEditingController(text: existing?['title']);
    final descController = TextEditingController(text: existing?['description']);
    String category = existing?['category'] ?? 'other';
    String priority = existing?['priority'] ?? 'medium';
    DateTime dueDate = existing?['dueDate'] != null
        ? DateTime.tryParse(existing!['dueDate']) ?? DateTime.now().add(const Duration(days: 7))
        : DateTime.now().add(const Duration(days: 7));

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: Text(isEdit ? 'Edit Task' : 'Add Task'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(labelText: 'Description'),
                  maxLines: 2,
                  textCapitalization: TextCapitalization.sentences,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Category'),
                  items: const [
                    DropdownMenuItem(value: 'venue', child: Text('Venue')),
                    DropdownMenuItem(value: 'catering', child: Text('Catering')),
                    DropdownMenuItem(value: 'photography', child: Text('Photography')),
                    DropdownMenuItem(value: 'music', child: Text('Music')),
                    DropdownMenuItem(value: 'flowers', child: Text('Flowers')),
                    DropdownMenuItem(value: 'attire', child: Text('Attire')),
                    DropdownMenuItem(value: 'other', child: Text('Other')),
                  ],
                  onChanged: (v) => setDialogState(() => category = v!),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: const InputDecoration(labelText: 'Priority'),
                  items: const [
                    DropdownMenuItem(value: 'low', child: Text('Low')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium')),
                    DropdownMenuItem(value: 'high', child: Text('High')),
                  ],
                  onChanged: (v) => setDialogState(() => priority = v!),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Due Date'),
                  subtitle: Text('${dueDate.day}/${dueDate.month}/${dueDate.year}'),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: ctx,
                      initialDate: dueDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 1095)),
                    );
                    if (date != null) setDialogState(() => dueDate = date);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) return;
                Navigator.pop(ctx);

                final auth = context.read<AuthProvider>();
                final data = {
                  'title': titleController.text,
                  'description': descController.text,
                  'category': category,
                  'priority': priority,
                  'dueDate': dueDate.toIso8601String().split('T')[0],
                };

                final response = isEdit
                    ? await auth.api.updateTask(existing['id'], data)
                    : await auth.api.createTask(data);

                if (response.isSuccess) {
                  await _loadData();
                  if (mounted) {
                    SnackBarHelper.showSuccess(
                        context, isEdit ? 'Task updated' : 'Task created');
                  }
                } else if (mounted) {
                  SnackBarHelper.showError(
                      context, response.errorMessage ?? 'Failed');
                }
              },
              child: Text(isEdit ? 'Save' : 'Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredTasks;

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadData,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.only(top: 16, bottom: 8),
                child: FilterChipRow(
                  options: _filterOptions,
                  selected: _filter,
                  onSelected: (v) => setState(() => _filter = v),
                ),
              ),
            ),
            if (_isLoading)
              const SliverFillRemaining(child: LoadingState())
            else if (filtered.isEmpty)
              SliverFillRemaining(
                child: EmptyState(
                  icon: Icons.task_alt,
                  title: 'No tasks yet',
                  subtitle: 'Add your first task to get started',
                  actionLabel: 'Add Task',
                  onAction: () => _showTaskDialog(),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final task = filtered[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: TaskCard(
                          task: task,
                          onToggle: (_) => _toggleTask(task),
                          onTap: () => _showTaskDialog(task),
                          onDelete: () => _deleteTask(task['id']),
                        ),
                      );
                    },
                    childCount: filtered.length,
                  ),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Add Task'),
      ),
    );
  }
}
