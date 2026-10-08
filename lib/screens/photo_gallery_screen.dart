
import 'package:flutter/material.dart';

class PhotoGalleryScreen extends StatefulWidget {
  const PhotoGalleryScreen({super.key});

  @override
  State<PhotoGalleryScreen> createState() => _PhotoGalleryScreenState();
}

class _PhotoGalleryScreenState extends State<PhotoGalleryScreen> {
  static const Color festivalYellow = Color(0xFFFFC107);
  static const Color darkNavy = Color(0xFF111827);

  String selectedCategory = 'All';

  final List<Map<String, dynamic>> photos = [
    {
      'title': 'Art Expo 2025',
      'date': 'May 10, 2025',
      'location': 'Viharamahadevi Park',
      'category': 'Art Expo',
      'image':
          'https://images.unsplash.com/photo-1531058020387-3be344556be6?w=700',
    },
    {
      'title': 'Food Festival 2025',
      'date': 'Apr 26, 2025',
      'location': 'Galle Face Green',
      'category': 'Food Fest',
      'image':
          'https://images.unsplash.com/photo-1555939594-58d7cb561ad1?w=700',
    },
    {
      'title': 'Music Carnival',
      'date': 'Mar 15, 2025',
      'location': 'Nelum Pokuna',
      'category': 'Music',
      'image':
          'https://images.unsplash.com/photo-1459749411175-04bf5292ceea?w=700',
    },
    {
      'title': 'Cultural Night',
      'date': 'Feb 10, 2025',
      'location': 'Town Hall',
      'category': 'Music',
      'image':
          'https://images.unsplash.com/photo-1508700115892-45ecd05ae2ad?w=700',
    },
    {
      'title': 'Festival Lights',
      'date': 'Jan 25, 2025',
      'location': 'Viharamahadevi Park',
      'category': 'Food Fest',
      'image':
          'https://images.unsplash.com/photo-1511795409834-ef04bbd61622?w=700',
    },
    {
      'title': 'Friends at Ceylona Fest',
      'date': 'Jan 12, 2025',
      'location': 'Galle Face Green',
      'category': 'Music',
      'image':
          'https://images.unsplash.com/photo-1501386761578-eac5c94b800a?w=700',
    },
  ];

  final Set<int> favorites = {};

  @override
  Widget build(BuildContext context) {
    final filteredPhotos = selectedCategory == 'All'
        ? photos
        : photos
            .where((photo) => photo['category'] == selectedCategory)
            .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFFEFC),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 22),
            _buildCategories(),
            const SizedBox(height: 26),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Recent Photos',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: darkNavy,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => selectedCategory = 'All');
                    },
                    child: const Text(
                      'View all  ›',
                      style: TextStyle(
                        color: Color(0xFFFFB300),
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                itemCount: filteredPhotos.length,
                gridDelegate:
                    const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  mainAxisExtent: 276,
                ),
                itemBuilder: (context, index) {
                  final photo = filteredPhotos[index];
                  final originalIndex = photos.indexOf(photo);

                  return _buildPhotoCard(photo, originalIndex);
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: festivalYellow,
        foregroundColor: darkNavy,
        elevation: 4,
        onPressed: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Photo upload will be added next.'),
            ),
          );
        },
        child: const Icon(Icons.add, size: 34),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
      decoration: const BoxDecoration(
        color: festivalYellow,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(90),
          bottomRight: Radius.circular(45),
        ),
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 28,
            ),
            style: IconButton.styleFrom(
              backgroundColor: darkNavy,
              fixedSize: const Size(48, 48),
            ),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Photo Gallery',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.w800,
                    color: darkNavy,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Capture the festival moments',
                  style: TextStyle(
                    fontSize: 14,
                    color: darkNavy,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategories() {
    const categories = ['All', 'Art Expo', 'Food Fest', 'Music'];

    return SizedBox(
      height: 48,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 18),
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = selectedCategory == category;

          return OutlinedButton(
            onPressed: () {
              setState(() => selectedCategory = category);
            },
            style: OutlinedButton.styleFrom(
              backgroundColor:
                  isSelected ? festivalYellow : Colors.white,
              foregroundColor:
                  isSelected ? Colors.white : darkNavy,
              side: BorderSide(
                color: isSelected
                    ? festivalYellow
                    : const Color(0xFFE5E7EB),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 18),
            ),
            child: Text(
              category,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhotoCard(Map<String, dynamic> photo, int index) {
    final isFavorite = favorites.contains(index);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: const Color(0xFFFFB800),
          width: 1.2,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  photo['image'],
                  width: double.infinity,
                  height: 132,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 132,
                      color: const Color(0xFFFFF3CD),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        size: 38,
                        color: darkNavy,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 5,
                right: 5,
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  onPressed: () {
                    setState(() {
                      if (isFavorite) {
                        favorites.remove(index);
                      } else {
                        favorites.add(index);
                      }
                    });
                  },
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.white,
                    size: 27,
                    shadows: const [
                      Shadow(color: Colors.black54, blurRadius: 5),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 9),
          Text(
            photo['title'],
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: darkNavy,
            ),
          ),
          const SizedBox(height: 7),
          _buildInfoRow(Icons.calendar_today_outlined, photo['date']),
          const SizedBox(height: 5),
          _buildInfoRow(Icons.location_on_outlined, photo['location']),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 15, color: const Color(0xFF374151)),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 11,
              color: Color(0xFF5B6472),
            ),
          ),
        ),
      ],
    );
  }
}
