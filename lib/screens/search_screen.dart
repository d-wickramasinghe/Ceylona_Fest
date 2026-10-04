import 'package:flutter/material.dart';
import '../services/db.dart';
import 'event_details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final query = TextEditingController();
  String category = 'All';
  String location = 'All locations';
  final categories = const ['All', 'Cultural', 'Music', 'Festivals', 'Campus', 'Sports', 'Food', 'Tech'];

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text('Search Events')),
        body: StreamBuilder(
          stream: Db.approvedEvents(),
          builder: (context, snapshot) {
            if (snapshot.hasError) return Center(child: Text('Could not load events: ${snapshot.error}'));
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
            final events = snapshot.data!.docs.where((doc) {
              final data = doc.data();
              final text = '${data['title'] ?? ''} ${data['location'] ?? ''}'.toLowerCase();
              final matchesQuery = text.contains(query.text.toLowerCase());
              final matchesCategory = category == 'All' || data['category'] == category;
              final matchesLocation = location == 'All locations' || data['location'] == location;
              return matchesQuery && matchesCategory && matchesLocation;
            }).toList();
            return Column(children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
                child: TextField(
                  controller: query,
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search by event or location', border: OutlineInputBorder()),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              SizedBox(
                height: 56,
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  scrollDirection: Axis.horizontal,
                  children: categories.map((value) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    child: ChoiceChip(label: Text(value), selected: category == value, onSelected: (_) => setState(() => category = value)),
                  )).toList(),
                ),
              ),
              Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Text('${events.length} events found'))),
              Expanded(
                child: events.isEmpty
                    ? const Center(child: Text('No approved events match your search'))
                    : ListView.builder(
                        itemCount: events.length,
                        itemBuilder: (context, index) {
                          final doc = events[index];
                          final data = doc.data();
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                            child: ListTile(
                              title: Text(data['title'] ?? 'Untitled event'),
                              subtitle: Text('${data['date'] ?? ''} • ${data['location'] ?? ''}\n${data['price'] ?? 'Free'}'),
                              isThreeLine: true,
                              trailing: const Icon(Icons.chevron_right),
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailsScreen(id: doc.id, data: data))),
                            ),
                          );
                        },
                      ),
              ),
            ]);
          },
        ),
      );
}
