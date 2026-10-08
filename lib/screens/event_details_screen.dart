import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter/material.dart';



import '../services/db.dart';

import 'add_event_comment_screen.dart';



const Color ceylonaYellow = Color(0xFFFFC107);

const Color ceylonaDark = Color(0xFF111827);

const Color ceylonaBackground = Color(0xFFFFFBF5);

const Color ceylonaBorder = Color(0xFFFFD76A);



class EventDetailsScreen extends StatefulWidget {

   final String id;

   final Map<String, dynamic> data;



   const EventDetailsScreen({

      super.key,

      required this.id,

      required this.data,

   });



   @override

   State<EventDetailsScreen> createState() =>

         _EventDetailsScreenState();

}



class _EventDetailsScreenState extends State<EventDetailsScreen> {

   Future<void> _deleteComment(String commentId) async {

      final confirm = await showDialog<bool>(

         context: context,

         builder: (dialogContext) => AlertDialog(

            title: const Text('Delete comment?'),

            content: const Text(

               'Are you sure you want to delete this comment?',

            ),

            actions: [

               TextButton(

                  onPressed: () => Navigator.pop(dialogContext, false),

                  child: const Text('Cancel'),

               ),

               FilledButton(

                  style: FilledButton.styleFrom(

                     backgroundColor: ceylonaYellow,

                     foregroundColor: ceylonaDark,

                  ),

                  onPressed: () => Navigator.pop(dialogContext, true),

                  child: const Text('Delete'),

               ),

            ],

         ),

      );



      if (confirm != true || !mounted) return;



      try {

         await Db.deleteComment(widget.id, commentId);



         if (!mounted) return;



         ScaffoldMessenger.of(context).showSnackBar(

            const SnackBar(

               content: Text('Comment deleted successfully.'),

            ),

         );

      } catch (e) {

         if (!mounted) return;



         ScaffoldMessenger.of(context).showSnackBar(

            SnackBar(

               content: Text('Failed to delete comment: $e'),

            ),

         );

      }

   }



   Future<void> _toggleLike(

      String commentId,

      bool isLiked,

   ) async {

      try {

         await Db.toggleCommentLike(

            widget.id,

            commentId,

            isLiked,

         );

      } catch (e) {

         if (!mounted) return;



         ScaffoldMessenger.of(context).showSnackBar(

            const SnackBar(

               content: Text(

                  'Unable to update like. Please check your connection or permissions.',

               ),

            ),

         );

      }

   }



   Future<void> _showReplyDialog(String commentId) async {
    final replyController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reply to comment'),
          content: TextField(
            controller: replyController,
            autofocus: true,
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Write your reply...',
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () async {
                final replyText = replyController.text.trim();
                if (replyText.isEmpty) return;

                try {
                  await Db.addCommentReply(
                    widget.id,
                    commentId,
                    replyText,
                  );
                  if (dialogContext.mounted) {
                    Navigator.pop(dialogContext);
                  }
                } catch (e) {
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to send reply: $e')),
                  );
                }
              },
              child: const Text('Send Reply'),
            ),
          ],
        );
      },
    );

    replyController.dispose();
  }

  Widget _eventImage() {

      final imageUrl =

            (widget.data['imageUrl'] ?? widget.data['image'] ?? '')

                  .toString();



      if (imageUrl.isEmpty) {

         return Container(

            height: 130,

            width: 130,

            color: const Color(0xFFFFE8A3),

            child: const Icon(

               Icons.celebration,

               size: 45,

               color: Color(0xFF80600B),

            ),

         );

      }



      return Image.network(

         imageUrl,

         height: 130,

         width: 130,

         fit: BoxFit.cover,

         errorBuilder: (_, __, ___) => Container(

            height: 130,

            width: 130,

            color: const Color(0xFFFFE8A3),

            child: const Icon(Icons.celebration, size: 45),

         ),

      );

   }



   Widget _eventInfo(IconData icon, String value) {

      if (value.isEmpty) return const SizedBox.shrink();



      return Padding(

         padding: const EdgeInsets.only(top: 5),

         child: Row(

            children: [

               Icon(icon, size: 15, color: ceylonaYellow),

               const SizedBox(width: 5),

               Expanded(

                  child: Text(

                     value,

                     style: const TextStyle(fontSize: 11),

                  ),

               ),

            ],

         ),

      );

   }



   Widget _commentCard(

      QueryDocumentSnapshot<Map<String, dynamic>> comment,

   ) {

      final data = comment.data();

      final commentUserId = data['userId']?.toString() ?? '';

      final commentName = data['userName']?.toString() ?? 'User';

      final commentText = data['text']?.toString() ?? '';

      final rating = ((data['rating'] as num?)?.toInt() ?? 0)

            .clamp(0, 5);



      final rawLikes = data['likes'];

      final likes = rawLikes is List

            ? rawLikes.map((item) => item.toString()).toList()

            : <String>[];



      final isLiked = likes.contains(uid);

      final isOwner = commentUserId == uid;

      final photoUrl = data['photoUrl']?.toString() ?? '';



      final rawTime = data['time'];

      DateTime? commentDate;



      if (rawTime is Timestamp) {

         commentDate = rawTime.toDate();

      } else if (rawTime is DateTime) {

         commentDate = rawTime;

      }



      String formattedDate = '';



      if (commentDate != null) {

         const months = [

            'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',

            'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',

         ];



         formattedDate =

               '${months[commentDate.month - 1]} ${commentDate.day}, ${commentDate.year}';

      }



      return Container(

         width: double.infinity,

         margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),

         padding: const EdgeInsets.fromLTRB(12, 12, 10, 10),

         decoration: BoxDecoration(

            color: Colors.white,

            border: Border.all(

               color: ceylonaBorder,

               width: 1.2,

            ),

            borderRadius: BorderRadius.circular(18),

         ),

         child: Row(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

               const CircleAvatar(

                  radius: 25,

                  backgroundColor: Color(0xFFFFE8A3),

                  child: Icon(

                     Icons.person,

                     color: ceylonaDark,

                     size: 27,

                  ),

               ),

               const SizedBox(width: 10),

               Expanded(

                  child: Column(

                     crossAxisAlignment: CrossAxisAlignment.start,

                     children: [

                        Row(

                           crossAxisAlignment: CrossAxisAlignment.start,

                           children: [

                              Expanded(

                                 child: Text(

                                    commentName,

                                    maxLines: 1,

                                    overflow: TextOverflow.ellipsis,

                                    style: const TextStyle(

                                       fontWeight: FontWeight.bold,

                                       fontSize: 15,

                                       color: ceylonaDark,

                                    ),

                                 ),

                              ),

                              if (rating > 0) ...[

                                 const SizedBox(width: 6),

                                 Row(

                                    mainAxisSize: MainAxisSize.min,

                                    children: List.generate(

                                       5,

                                       (index) => Icon(

                                          index < rating

                                                ? Icons.star

                                                : Icons.star_border,

                                          color: ceylonaYellow,

                                          size: 18,

                                       ),

                                    ),

                                 ),

                              ],

                           ],

                        ),

                        if (formattedDate.isNotEmpty) ...[

                           const SizedBox(height: 2),

                           Text(

                              formattedDate,

                              style: TextStyle(

                                 fontSize: 12,

                                 color: Colors.grey.shade600,

                              ),

                           ),

                        ],

                        const SizedBox(height: 10),

                        Text(

                           commentText,

                           style: const TextStyle(

                              fontSize: 14,

                              height: 1.4,

                              color: Color(0xFF374151),

                           ),

                        ),

                        if (photoUrl.isNotEmpty) ...[

                           const SizedBox(height: 10),

                           ClipRRect(

                              borderRadius: BorderRadius.circular(10),

                              child: Image.network(

                                 photoUrl,

                                 width: double.infinity,

                                 height: 180,

                                 fit: BoxFit.cover,

                                 errorBuilder: (_, __, ___) =>

                                       const SizedBox.shrink(),

                              ),

                           ),

                        ],

                        const SizedBox(height: 6),

                        Wrap(

                           crossAxisAlignment: WrapCrossAlignment.center,

                           spacing: 4,

                           children: [

                              IconButton(

                                 tooltip: isLiked

                                       ? 'Unlike comment'

                                       : 'Like comment',

                                 visualDensity: VisualDensity.compact,

                                 padding: EdgeInsets.zero,

                                 constraints: const BoxConstraints(

                                    minWidth: 30,

                                    minHeight: 30,

                                 ),

                                 onPressed: () =>

                                       _toggleLike(comment.id, isLiked),

                                 icon: Icon(

                                    isLiked

                                          ? Icons.favorite

                                          : Icons.favorite_border,

                                    color: isLiked

                                          ? Colors.red

                                          : Colors.blueGrey,

                                    size: 20,

                                 ),

                              ),

                              Text(

                                 '${likes.length}',

                                 style: const TextStyle(

                                    fontSize: 12,

                                    color: Color(0xFF4B5563),

                                 ),

                              ),

                              const SizedBox(width: 8),

                              TextButton.icon(
                                onPressed: () => _showReplyDialog(comment.id),
                                icon: const Icon(
                                  Icons.chat_bubble_outline,
                                  size: 17,
                                  color: Color(0xFF64748B),
                                ),
                                label: const Text(
                                  'Reply',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF4B5563),
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  visualDensity: VisualDensity.compact,
                                ),
                              ),

                           ],

                        ),

                     ],

                  ),

               ),

               if (isOwner)

                  IconButton(

                     tooltip: 'Delete comment',

                     visualDensity: VisualDensity.compact,

                     padding: EdgeInsets.zero,

                     constraints: const BoxConstraints(

                        minWidth: 30,

                        minHeight: 30,

                     ),

                     icon: const Icon(

                        Icons.delete_outline,

                        color: Color(0xFF80600B),

                        size: 21,

                     ),

                     onPressed: () => _deleteComment(comment.id),

                  ),

            ],

         ),

      );

   }



   @override

   Widget build(BuildContext context) {

      final data = widget.data;

      final title = data['title']?.toString() ?? 'Event';

      final date = data['date']?.toString() ?? '';

      final time = data['time']?.toString() ?? '';

      final location = data['location']?.toString() ?? '';

      final price = data['price']?.toString() ?? 'Free';



      return Scaffold(

         backgroundColor: ceylonaBackground,

         appBar: AppBar(

            backgroundColor: ceylonaYellow,

            foregroundColor: ceylonaDark,

            title: const Text(

               'Event Discussion',

               style: TextStyle(fontWeight: FontWeight.bold),

            ),

         ),

         body: ListView(

            padding: const EdgeInsets.only(bottom: 24),

            children: [

               Container(

                  margin: const EdgeInsets.all(16),

                  padding: const EdgeInsets.all(10),

                  decoration: BoxDecoration(

                     color: Colors.white,

                     border: Border.all(color: ceylonaBorder),

                     borderRadius: BorderRadius.circular(16),

                  ),

                  child: Row(

                     crossAxisAlignment: CrossAxisAlignment.start,

                     children: [

                        ClipRRect(

                           borderRadius: BorderRadius.circular(10),

                           child: _eventImage(),

                        ),

                        const SizedBox(width: 10),

                        Expanded(

                           child: Column(

                              crossAxisAlignment: CrossAxisAlignment.start,

                              children: [

                                 Text(

                                    title,

                                    style: const TextStyle(

                                       fontWeight: FontWeight.bold,

                                       fontSize: 15,

                                       color: ceylonaDark,

                                    ),

                                 ),

                                 const SizedBox(height: 6),

                                 Container(

                                    padding: const EdgeInsets.symmetric(

                                       horizontal: 7,

                                       vertical: 3,

                                    ),

                                    decoration: BoxDecoration(

                                       color: const Color(0xFFE6F4E5),

                                       borderRadius: BorderRadius.circular(5),

                                    ),

                                    child: const Text(

                                       'Verified Organizer',

                                       style: TextStyle(

                                          fontSize: 10,

                                          color: Colors.green,

                                       ),

                                    ),

                                 ),

                                 _eventInfo(

                                    Icons.calendar_month,

                                    '$date $time'.trim(),

                                 ),

                                 _eventInfo(Icons.location_on, location),

                                 _eventInfo(Icons.payments, price),

                              ],

                           ),

                        ),

                     ],

                  ),

               ),

               const Padding(

                  padding: EdgeInsets.fromLTRB(16, 0, 16, 10),

                  child: Text(

                     'DISCUSSION FOR THIS EVENT',

                     style: TextStyle(

                        fontSize: 13,

                        fontWeight: FontWeight.bold,

                        color: ceylonaDark,

                     ),

                  ),

               ),

               Padding(

                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  child: Container(

                     padding: const EdgeInsets.all(12),

                     decoration: BoxDecoration(

                        color: Colors.white,

                        border: Border.all(color: ceylonaBorder),

                        borderRadius: BorderRadius.circular(14),

                     ),

                     child: Column(

                        children: [

                           const Row(

                              children: [

                                 CircleAvatar(

                                    radius: 16,

                                    backgroundColor: Color(0xFFFFE8A3),

                                    child: Icon(

                                       Icons.person,

                                       color: ceylonaDark,

                                       size: 20,

                                    ),

                                 ),

                                 SizedBox(width: 8),

                                 Text(

                                    'Join the Discussion',

                                    style: TextStyle(

                                       fontWeight: FontWeight.bold,

                                    ),

                                 ),

                              ],

                           ),

                           const SizedBox(height: 12),

                           SizedBox(

                              width: double.infinity,

                              child: FilledButton.icon(

                                 style: FilledButton.styleFrom(

                                    backgroundColor: ceylonaYellow,

                                    foregroundColor: ceylonaDark,

                                 ),

                                 onPressed: () {

                                    Navigator.push(

                                       context,

                                       MaterialPageRoute(

                                          builder: (_) => AddEventCommentScreen(

                                             id: widget.id,

                                             data: widget.data,

                                          ),

                                       ),

                                    );

                                 },

                                 icon: const Icon(Icons.send),

                                 label: const Text('Add Comment'),

                              ),

                           ),

                        ],

                     ),

                  ),

               ),

               Padding(

                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),

                  child: Row(

                     mainAxisAlignment: MainAxisAlignment.spaceBetween,

                     children: [

                        const Text(

                           'All Comments',

                           style: TextStyle(

                              fontSize: 18,

                              fontWeight: FontWeight.bold,

                              color: ceylonaDark,

                           ),

                        ),

                        Text(

                           'Newest first',

                           style: TextStyle(

                              fontSize: 12,

                              color: Colors.grey.shade700,

                           ),

                        ),

                     ],

                  ),

               ),

               StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(

                  stream: Db.comments(widget.id),

                  builder: (context, snapshot) {

                     if (snapshot.hasError) {

                        return const Padding(

                           padding: EdgeInsets.all(16),

                           child: Text('Unable to load comments.'),

                        );

                     }



                     if (snapshot.connectionState ==

                           ConnectionState.waiting) {

                        return const Center(

                           child: Padding(

                              padding: EdgeInsets.all(20),

                              child: CircularProgressIndicator(),

                           ),

                        );

                     }



                     final comments = snapshot.data?.docs ?? [];



                     if (comments.isEmpty) {

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

                        children: comments.map(_commentCard).toList(),

                     );

                  },

               ),

            ],

         ),

      );

   }

}