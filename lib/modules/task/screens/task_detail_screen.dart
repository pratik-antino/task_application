import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_application/modules/task/screens/edit_task_screen.dart';
import '../model/task.dart';
import '../cubits/task_cubit.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;
  final String token;

  const TaskDetailScreen({Key? key, required this.task, required this.token})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(task.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                    builder: (context) => EditTaskScreen(task: task)),
              );
              context.read<TaskCubit>().fetchTasks(token);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow('Description:', task.description),
            const SizedBox(height: 10),
            _buildDetailRow('Priority:', task.priority),
            const SizedBox(height: 10),
            _buildDetailRow('Status:', task.status),
            const SizedBox(height: 10),
            _buildDetailRow('Due Date:', task.dueDate.toLocal().toString()),
            const SizedBox(height: 20),
            const Text('Comments:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(child: _buildCommentsSection(context)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addCommentDialog(context),
        child: const Icon(Icons.add_comment),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$label ', style: const TextStyle(fontWeight: FontWeight.bold)),
        Expanded(child: Text(value)),
      ],
    );
  }

  Widget _buildCommentsSection(BuildContext context) {
    // Dummy comments for now
    final comments =
        task.comments; // Make sure comments are part of the Task model

    return ListView.builder(
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return ListTile(
          title: Text(comment.content),
          subtitle: Text('By: ${comment.createdByName}'),
          // trailing: IconButton(
          //   icon: const Icon(Icons.delete),
          //   onPressed: () {
          //     // Add delete comment functionality
          //   },
          // ),
        );
      },
    );
  }

  void _addCommentDialog(BuildContext context) {
    final TextEditingController _controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Comment'),
          content: TextField(
            controller: _controller,
            maxLines: 3,
            decoration:
                const InputDecoration(hintText: 'Write your comment here'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                final content = _controller.text;
                if (content.isNotEmpty) {
                  // Call the API to add a comment
                  context.read<TaskCubit>().addComment(task.id, content, token);
                  Navigator.of(context).pop();
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
