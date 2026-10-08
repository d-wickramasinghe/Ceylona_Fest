
import 'package:flutter/material.dart';
import '../services/db.dart';
import 'event_details_screen.dart';
import 'photo_gallery_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String q = '', cat = 'All';

  static const cats = [
    'All',
    'Music',
    'Cultural',
    'Food',
    'Sports',
    'University'
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text('Hello, $userName'),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.search),
                  hintText: 'Search by name or location',
                  border: OutlineInputBorder(),
                ),
                onChanged: (v) => setState(() => q = v.toLowerCase()),
              ),
            ),

            // Photo Gallery button
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 4,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PhotoGalleryScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Photo Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC107),
                    foregroundColor: const Color(0xFF111827),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
            ),

            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  for (final c in cats)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ChoiceChip(
                        label: Text(c),
                        selected: cat == c,
                        onSelected: (_) => setState(() => cat = c),
                      ),
                    ),
                ],
              ),
            ),

            Expanded(
              child: StreamBuilder(
                stream: Db.approvedEvents(),
                builder: (c, s) {
                  if (!s.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }

                  final docs = s.data!.docs.where((d) {
                    final e = d.data();
                    final match =
                        '${e['title']} ${e['location']}'
                            .toLowerCase()
                            .contains(q);

                    return match &&
                        (cat == 'All' || e['category'] == cat);
                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text('No events found'),
                    );
                  }

                  return ListView(
                    children: [
                      for (final d in docs)
                        Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: ListTile(
                            title: Text(d['title']),
                            subtitle: Text(
                              '${d['date']} • ${d['location']}\n'
                              '${d['price'] ?? 'Free'}',
                            ),
                            isThreeLine: true,
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.push(
                              c,
                              MaterialPageRoute(
                                builder: (_) => EventDetailsScreen(
                                  id: d.id,
                                  data: d.data(),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      );
}
