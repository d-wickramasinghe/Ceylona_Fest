
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/db.dart';

const Color ceylonaYellow = Color(0xFFFFC107);
const Color ceylonaDark = Color(0xFF111827);
const Color ceylonaBackground = Color(0xFFFFFBF5);
const Color ceylonaBorder = Color(0xFFFFD76A);

class AddEventCommentScreen extends StatefulWidget {
  final String id;
  final Map<String, dynamic> data;

  const AddEventCommentScreen({
    super.key,
    required this.id,
    required this.data,
  });

  @override
  State<AddEventCommentScreen> createState() =>
      _AddEventCommentScreenState();
}

class _AddEventCommentScreenState
    extends State<AddEventCommentScreen> {
  final TextEditingController _commentController =
      TextEditingController();

  final ImagePicker _picker = ImagePicker();

  XFile? _selectedImage;
  bool _isPosting = false;
  bool _isPickingImage = false;
  int _selectedRating = 0;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_isPickingImage) return;

    setState(() => _isPickingImage = true);

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );

      if (!mounted) return;

      if (image != null) {
        setState(() => _selectedImage = image);
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to select photo.'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPickingImage = false);
      }
    }
  }

  Future<void> _postComment() async {
    final comment = _commentController.text.trim();

    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a comment.'),
        ),
      );
      return;
    }

    if (_isPosting) return;

    setState(() => _isPosting = true);

    try {
      // Save the comment using the existing database function.
     await Db.addComment(
  widget.id,
  comment,
  rating: _selectedRating,
);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comment added successfully!'),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to add comment: $e'),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isPosting = false);
      }
    }
  }

  Widget _eventImage() {
    final imageUrl =
        (widget.data['imageUrl'] ?? widget.data['image'] ?? '')
            .toString();

    if (imageUrl.isEmpty) {
      return Container(
        height: 105,
        width: 125,
        color: const Color(0xFFFFE8A3),
        child: const Icon(
          Icons.celebration,
          size: 40,
          color: Color(0xFF80600B),
        ),
      );
    }

    return Image.network(
      imageUrl,
      height: 105,
      width: 125,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        height: 105,
        width: 125,
        color: const Color(0xFFFFE8A3),
        child: const Icon(
          Icons.celebration,
          size: 40,
          color: Color(0xFF80600B),
        ),
      ),
    );
  }

  Widget _photoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Add Photo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: ceylonaDark,
              ),
            ),
            Text(
              ' (Optional)',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        InkWell(
          onTap: _isPickingImage ? null : _pickImage,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 130),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: ceylonaBorder),
              borderRadius: BorderRadius.circular(12),
            ),
            child: _isPickingImage
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : _selectedImage == null
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add_photo_alternate_outlined,
                            size: 34,
                            color: Colors.blueGrey,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Tap to Select Photo',
                            style: TextStyle(
                              color: Colors.blueGrey,
                            ),
                          ),
                        ],
                      )
                    : Column(
                        children: [
                          if (kIsWeb)
                            Image.network(
                              _selectedImage!.path,
                              height: 180,
                              fit: BoxFit.contain,
                            )
                          else
                            FutureBuilder<Uint8List>(
                              future: _selectedImage!.readAsBytes(),
                              builder: (context, snapshot) {
                                if (!snapshot.hasData) {
                                  return const SizedBox(
                                    height: 100,
                                    child: Center(
                                      child:
                                          CircularProgressIndicator(),
                                    ),
                                  );
                                }

                                return Image.memory(
                                  snapshot.data!,
                                  height: 180,
                                  fit: BoxFit.contain,
                                );
                              },
                            ),
                          const SizedBox(height: 8),
                          TextButton.icon(
                            onPressed: () {
                              setState(() => _selectedImage = null);
                            },
                            icon: const Icon(Icons.delete_outline),
                            label: const Text('Remove Photo'),
                          ),
                        ],
                      ),
          ),
        ),
      ],
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
        elevation: 0,
        title: const Text(
          'Event Discussion',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          // Event information
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: ceylonaBorder),
              borderRadius: BorderRadius.circular(15),
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
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: ceylonaDark,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 7,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F4E5),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          'Verified Organizer',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(height: 7),
                      if (date.isNotEmpty || time.isNotEmpty)
                        Text(
                          '$date $time',
                          style: const TextStyle(fontSize: 12),
                        ),
                      if (location.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            location,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      if (price.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 5),
                          child: Text(
                            price,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          const Text(
            'Your Comment',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ceylonaDark,
            ),
          ),

          const SizedBox(height: 10),

          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: ceylonaBorder),
              borderRadius: BorderRadius.circular(14),
            ),
            child: TextField(
              controller: _commentController,
              minLines: 4,
              maxLines: 6,
              maxLength: 500,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText:
                    'Share your thoughts, ask a question or give your feedback...',
                contentPadding: EdgeInsets.all(14),
                border: InputBorder.none,
                counterText: '',
              ),
            ),
          ),

          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(top: 5),
              child: Text(
                '${_commentController.text.length}/500',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          Row(
            children: [
              const Text(
                'Add Rating',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                  color: ceylonaDark,
                ),
              ),
              Text(
                ' (Optional)',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: List.generate(5, (index) {
              return IconButton(
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.only(right: 5),
                constraints: const BoxConstraints(),
                onPressed: () {
                  setState(() => _selectedRating = index + 1);
                },
                icon: Icon(
                  index < _selectedRating
                      ? Icons.star
                      : Icons.star_border,
                  size: 30,
                  color: ceylonaYellow,
                ),
              );
            }),
          ),

          const SizedBox(height: 20),

          _photoSection(),

          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ceylonaDark,
                    side: const BorderSide(color: Colors.blueGrey),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isPosting
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: ceylonaYellow,
                    foregroundColor: ceylonaDark,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: _isPosting ? null : _postComment,
                  icon: _isPosting
                      ? const SizedBox(
                          width: 17,
                          height: 17,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.send, size: 18),
                  label: Text(
                    _isPosting ? 'Posting...' : 'Post Comment',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
