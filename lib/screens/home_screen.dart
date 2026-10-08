import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/db.dart';
import 'event_details_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String q = '', cat = 'All';
  static const cats = [
    'All',
    'Cultural',
    'Music',
    'Festivals',
    'Campus',
    'Food',
    'Sports',
    'Tech'
  ];

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
            title:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Hello, $userName!',
              style:
                  const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const Text('Ready to explore Sri Lanka?',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.normal))
        ])),
        body: StreamBuilder(
          stream: Db.approvedEvents(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final docs = snapshot.data!.docs.where((doc) {
              final event = doc.data();
              final matchesText =
                  '${event['title'] ?? ''} ${event['location'] ?? ''}'
                      .toLowerCase()
                      .contains(q);
              return matchesText && (cat == 'All' || event['category'] == cat);
            }).toList();
            return ListView(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 20),
                children: [
                  TextField(
                      decoration: InputDecoration(
                          prefixIcon: const Icon(Icons.search),
                          hintText: 'Search events, venues or locations',
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none)),
                      onChanged: (value) =>
                          setState(() => q = value.toLowerCase())),
                  const SizedBox(height: 12),
                  SizedBox(
                      height: 38,
                      child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: cats.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (context, index) => ChoiceChip(
                              label: Text(cats[index]),
                              selected: cat == cats[index],
                              onSelected: (_) =>
                                  setState(() => cat = cats[index])))),
                  const SizedBox(height: 20),
                  _HomeSection(title: 'Popular Now in Sri Lanka', events: docs),
                  _HomeSection(
                      title: 'Nearby Suggestions',
                      events: docs.reversed.toList()),
                  for (final group in cats.skip(1))
                    _HomeSection(
                        title: '$group Events',
                        events: docs
                            .where((doc) => doc.data()['category'] == group)
                            .toList()),
                  if (docs.isEmpty)
                    const Padding(
                        padding: EdgeInsets.only(top: 24),
                        child: Center(child: Text('No events found'))),
                ]);
          },
        ),
      );
}

class _HomeSection extends StatelessWidget {
  final String title;
  final List<dynamic> events;
  const _HomeSection({required this.title, required this.events});

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        TextButton(onPressed: () {}, child: const Text('See All')),
      ]),
      SizedBox(
        height: 184,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: events.length > 6 ? 6 : events.length,
          separatorBuilder: (_, __) => const SizedBox(width: 10),
          itemBuilder: (context, index) {
            final doc = events[index];
            final data = doc.data();
            return SizedBox(
              width: 220,
              child: Card(
                margin: EdgeInsets.zero,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) =>
                              EventDetailsScreen(id: doc.id, data: data))),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _EventImage(
                              url: data['imageUrl']?.toString(),
                              height: 64),
                          const SizedBox(height: 7),
                          Row(children: [
                            const Icon(Icons.verified,
                                size: 14, color: AppColors.success),
                            const SizedBox(width: 4),
                            Expanded(
                                child: Text(data['title'] ?? 'Untitled event',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12))),
                          ]),
                          const SizedBox(height: 4),
                          Text('${data['date'] ?? ''} • ${data['time'] ?? ''}',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey)),
                          Text(data['location'] ?? '',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                  fontSize: 10, color: Colors.grey)),
                        ]),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ]);
  }
}

class _EventImage extends StatelessWidget {
  final String? url;
  final double height;
  const _EventImage({required this.url, required this.height});

  @override
  Widget build(BuildContext context) {
    final imageUrl = url?.trim() ?? '';
    return Container(
      height: height,
      width: double.infinity,
      decoration: BoxDecoration(
          color: const Color(0xfffff3c4),
          borderRadius: BorderRadius.circular(8)),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
          ? const Center(child: Icon(Icons.event, size: 28))
          : Image.network(imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) =>
                  const Center(child: Icon(Icons.event, size: 28))),
    );
  }
}
