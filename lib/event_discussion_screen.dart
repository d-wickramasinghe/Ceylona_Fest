
import 'package:flutter/material.dart';
import '../services/db.dart';

class EventDiscussionScreen extends StatefulWidget {
  final String eventId;
  final Map<String, dynamic> eventData;

  const EventDiscussionScreen({
    super.key,
    required this.eventId,
    required this.eventData,
  });

  @override
  State<EventDiscussionScreen> createState() =>
      _EventDiscussionScreenState();
}

class _EventDiscussionScreenState
    extends State<EventDiscussionScreen> {
  final TextEditingController _commentController =
      TextEditingController();

  bool _posting = false;
  int _rating = 0;

  static const Color yellow = Color(0xFFFBBF24);
  static const Color dark = Color(0xFF111827);

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _postComment() async {
    final text = _commentController.text.trim();

    if (text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a comment'),
        ),
      );
      return;
    }

    setState(() => _posting = true);

    try {
      await Db.addComment(widget.eventId, text);
      _commentController.clear();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment posted')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not post comment: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _posting = false);
      }
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await Db.deleteComment(widget.eventId, commentId);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Comment deleted')),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete comment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.eventData;

    final title = event['title']?.toString() ?? 'Event';
    final date = event['date']?.toString() ?? '';
    final time = event['time']?.toString() ?? '';
    final location = event['location']?.toString() ?? '';

    final imageUrl = event['imageUrl']?.toString() ??
        event['image']?.toString() ??
        '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: yellow,
        foregroundColor: dark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Event Discussion',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Event information card
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: yellow, width: 1.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 105,
                    height: 105,
                    child: imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) =>
                                const Icon(Icons.event, size: 45),
                          )
                        : const Icon(Icons.event, size: 45),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'EVENT',
                        style: TextStyle(
                          color: Colors.green,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: dark,
                        ),
                      ),
                      const SizedBox(height: 7),
                      Text(
                        '$date${time.isNotEmpty ? ' • $time' : ''}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      if (location.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          location,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          const Text(
            'DISCUSSION FOR THIS EVENT',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: dark,
            ),
          ),

          const SizedBox(height: 10),

          // Add comment card
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: yellow, width: 1.5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    const CircleAvatar(
                      radius: 16,
                      backgroundColor: Color(0xFFFFE082),
                      child: Icon(
                        Icons.person,
                        color: dark,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _commentController,
                  maxLines: 3,
                  maxLength: 500,
                  decoration: InputDecoration(
                    hintText:
                        'Ask a question or share your thoughts...',
                    filled: true,
                    fillColor: const Color(0xFFF8FAFC),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: yellow,
                      foregroundColor: dark,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                    ),
                    onPressed: _posting ? null : _postComment,
                    icon: const Icon(Icons.send),
                    label: Text(
                      _posting ? 'Posting...' : 'Post Comment',
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 22),

          // Comments heading
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'All Comments',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                'Newest ↓',
                style: TextStyle(fontSize: 12),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Live comments from Firestore
          StreamBuilder(
            stream: Db.comments(widget.eventId),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Unable to load comments. Please try again.',
                  ),
                );
              }

              if (snapshot.connectionState ==
                  ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              final docs = snapshot.data?.docs ?? [];

              if (docs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(20),
                  child: Center(
                    child: Text(
                      'No comments yet. Be the first to comment!',
                    ),
                  ),
                );
              }

              return Column(
                children: docs.map<Widget>((doc) {
                  // Removed unnecessary cast
                  final comment = doc.data();

                  final commentUserId =
                      comment['userId']?.toString() ?? '';
                  final commentName =
                      comment['userName']?.toString() ?? 'User';
                  final commentText =
                      comment['text']?.toString() ?? '';

                  final isOwner = commentUserId == uid;

                  return Container(
                    width: double.infinity,
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: yellow,
                        width: 1.3,
                      ),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 17,
                              backgroundColor: Color(0xFFFFE082),
                              child: Icon(
                                Icons.person,
                                color: dark,
                              ),
                            ),
                            const SizedBox(width: 9),
                            Expanded(
                              child: Text(
                                commentName,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            if (isOwner)
                              IconButton(
                                tooltip: 'Delete comment',
                                onPressed: () =>
                                    _deleteComment(doc.id),
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: Colors.red,
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(commentText),
                      ],
                    ),
                  );
                }).toList(),
              );
            },
          ),

          const SizedBox(height: 20),

          const Text(
            'Add Rating (Optional)',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 8),

          Row(
            children: List.generate(5, (index) {
              final selected = index < _rating;

              return IconButton(
                onPressed: () {
                  setState(() => _rating = index + 1);
                },
                icon: Icon(
                  selected ? Icons.star : Icons.star_border,
                  color: yellow,
                  size: 30,
                ),
              );
            }),
          ),

          const Text(
            'Rating is a visual selection for now.',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
