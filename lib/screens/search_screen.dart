import 'package:flutter/material.dart';
import '../services/db.dart';
import 'event_details_screen.dart';
import '../widgets/event_image.dart';
import '../widgets/seeker_page_header.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final query = TextEditingController();
  String category = 'All';
  String location = 'All locations';
  String dateRange = 'Any date';
  final categories = const [
    'All',
    'Cultural',
    'Music',
    'Festivals',
    'Campus',
    'Sports',
    'Food',
    'Tech'
  ];

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xfffbfaf7),
        body: Column(children: [
          SeekerPageHeader(
              title: 'Find your next event',
              subtitle: 'Search festivals, music, food and more',
              actions: [
                IconButton(
                    tooltip: 'Clear filters',
                    onPressed: () => setState(() {
                          query.clear();
                          category = 'All';
                          location = 'All locations';
                          dateRange = 'Any date';
                        }),
                    icon: const Icon(Icons.restart_alt))
              ]),
          Expanded(child: StreamBuilder(
          stream: Db.approvedEvents(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                  child: Text('Could not load events: ${snapshot.error}'));
            }
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final events = snapshot.data!.docs.where((doc) {
              final data = doc.data();
              final text = '${data['title'] ?? ''} ${data['location'] ?? ''}'
                  .toLowerCase();
              final matchesQuery = text.contains(query.text.toLowerCase());
              final matchesCategory =
                  category == 'All' || data['category'] == category;
              final matchesLocation =
                  location == 'All locations' || data['location'] == location;
              return matchesQuery && matchesCategory && matchesLocation;
            }).toList();
            return Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: TextField(
                  controller: query,
                  decoration: const InputDecoration(
                      prefixIcon: Icon(Icons.search),
                      hintText: 'Search by event or location',
                      border: OutlineInputBorder()),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(children: [
                  Expanded(
                      child: DropdownButtonFormField<String>(
                          initialValue: location,
                          decoration: const InputDecoration(
                              labelText: 'Location',
                              border: OutlineInputBorder()),
                          items: const [
                            'All locations',
                            'Colombo',
                            'Kandy',
                            'Galle'
                          ]
                              .map((value) => DropdownMenuItem(
                                  value: value, child: Text(value)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => location = value!))),
                  const SizedBox(width: 8),
                  Expanded(
                      child: DropdownButtonFormField<String>(
                          initialValue: dateRange,
                          decoration: const InputDecoration(
                              labelText: 'Date range',
                              border: OutlineInputBorder()),
                          items: const [
                            'Any date',
                            'This Weekend',
                            'This Month'
                          ]
                              .map((value) => DropdownMenuItem(
                                  value: value, child: Text(value)))
                              .toList(),
                          onChanged: (value) =>
                              setState(() => dateRange = value!))),
                ]),
              ),
              Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                  child: SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                          onPressed: () => setState(() {}),
                          child: const Text('Apply Filters')))),
              SizedBox(
                height: 56,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  scrollDirection: Axis.horizontal,
                  children: categories
                      .map((value) => Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 8),
                            child: ChoiceChip(
                                label: Text(value),
                                selected: category == value,
                                onSelected: (_) =>
                                    setState(() => category = value)),
                          ))
                      .toList(),
                ),
              ),
              Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text(
                          '${events.length.toString().padLeft(2, '0')} Events Found Matching Criteria',
                          style:
                              const TextStyle(fontWeight: FontWeight.w700)))),
              Expanded(
                child: events.isEmpty
                    ? const Center(
                        child: Text('No approved events match your search'))
                    : ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final doc = events[index];
                          final data = doc.data();
                          return Card(
                            margin: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 5),
                            child: ListTile(
                              leading: EventImage(
                                  url: data['imageUrl']?.toString(),
                                  width: 64,
                                  height: 64,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(6))),
                              title: Text(data['title'] ?? 'Untitled event'),
                              subtitle: Text(
                                  '${data['date'] ?? ''} • ${data['location'] ?? ''}\n${data['price'] ?? 'Free'}'),
                              isThreeLine: true,
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) => EventDetailsScreen(
                                          id: doc.id, data: data))),
                            ),
                          );
                        },
                      ),
              ),
            ]);
          },
        )),
        ]),
      );
}
