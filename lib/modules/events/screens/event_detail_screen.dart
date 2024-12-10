import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_application/modules/auth/cubits/auth_cubit.dart';
import 'package:task_application/modules/events/cubits/event_cubit.dart';
import 'package:task_application/modules/events/edit_event_screen.dart';
import 'package:task_application/modules/events/event.dart';

class EventDetailScreen extends StatefulWidget {
  final Event event;
  final String token;
  const EventDetailScreen({Key? key, required this.event, required this.token})
      : super(key: key);

  @override
  _EventDetailScreenState createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  void _addComment() {
    final token = widget.token; // Replace with actual token
    final content = _commentController.text.trim();
    if (content.isNotEmpty) {
      context.read<EventCubit>().addComment(widget.event.id, content, token);
      context.read<EventCubit>().fetchEvents(token);

      _commentController.clear();
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;

    final isCreator = authState is AuthAuthenticated &&
        authState.userId == widget.event.ownerId;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.event.title),
        actions: [
          if (isCreator)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => AddEditEventScreen(event: widget.event),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
          padding: const EdgeInsets.all(16.0),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(
              child: ListView(
                children: [
                  ListTile(
                    leading: const Icon(Icons.event),
                    title: Text(widget.event.title,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.description),
                    title: const Text('Description'),
                    subtitle: Text(widget.event.description.isEmpty
                        ? 'No description provided'
                        : widget.event.description),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Start Time'),
                    subtitle: Text(widget.event.startTime.toString()),
                  ),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('End Time'),
                    subtitle: Text(widget.event.endTime.toString()),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.group),
                    title: const Text('Participants'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.event.participants.isEmpty
                          ? [const Text('No participants yet')]
                          : widget.event.participants
                              .map((participant) => Text(participant))
                              .toList(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  // if (!isCreator)
                  //   ElevatedButton(
                  //     onPressed: () => _joinEvent(context),
                  //     child: const Text('Join Event'),
                  //   ),
                  // if (isCreator)
                  //   ElevatedButton(
                  //     onPressed: () => _deleteEvent(context),
                  //     style: ElevatedButton.styleFrom(primary: Colors.red),
                  //     child: const Text('Delete Event'),
                  //   ),
                ],
              ),
            ),
            // const SizedBox(height: 20),
            const Text('Comments:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            Expanded(child: _buildCommentsSection(context)),
            // Row(
            //   children: [
            //     Expanded(
            //       child: TextField(
            //         controller: _commentController,
            //         decoration:
            //             const InputDecoration(hintText: 'Add a comment...'),
            //       ),
            //     ),
            //     IconButton(
            //       icon: const Icon(Icons.send),
            //       onPressed: _addComment,
            //     ),
            //   ],
            // ),
          ]
                  // style: Theme.of(context).textTheme.bodyText1
                  )),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addCommentDialog(context),
        child: const Icon(Icons.add_comment),
      ),
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
            controller: _commentController,
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
              onPressed: _addComment,
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCommentsSection(BuildContext context) {
    // Dummy comments for now
    final comments =
        widget.event.comments; // Make sure comments are part of the Task model

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
}
