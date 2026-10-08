// import 'package:flutter/material.dart';
// import '../services/db.dart';

// class AdminScreen extends StatelessWidget {
//   const AdminScreen({super.key});
//   @override
//   Widget build(BuildContext context) => Scaffold(
//         appBar: AppBar(title: const Text('Event Approvals')),
//         body: StreamBuilder(
//           stream: Db.pendingEvents(),
//           builder: (c, s) {
//             if (!s.hasData) return const Center(child: CircularProgressIndicator());
//             if (s.data!.docs.isEmpty) return const Center(child: Text('No pending events'));
//             return ListView(children: [
//               for (final d in s.data!.docs)
//                 Card(
//                   child: ListTile(
//                     title: Text(d['title']),
//                     subtitle: Text('${d['date']} • ${d['location']}'),
//                     trailing: Row(mainAxisSize: MainAxisSize.min, children: [
//                       IconButton(icon: const Icon(Icons.check_circle, color: Colors.green), onPressed: () => Db.setStatus(d.id, 'approved')),
//                       IconButton(icon: const Icon(Icons.cancel, color: Colors.red), onPressed: () => Db.setStatus(d.id, 'rejected')),
//                     ]),
//                   ),
//                 )
//             ]);
//           },
//         ),
//       );
// }


import 'package:flutter/material.dart';
import '../services/db.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: const Color(0xFFFDF6EC),
        appBar: AppBar(
          backgroundColor: const Color(0xFFFDF6EC),
          elevation: 0,
          title: const Text('Event Approvals', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
        ),
        body: StreamBuilder(
          stream: Db.pendingEvents(),
          builder: (c, s) {
            if (!s.hasData) return const Center(child: CircularProgressIndicator());
            if (s.data!.docs.isEmpty) return const Center(child: Text('No pending events'));
            return ListView(
              padding: const EdgeInsets.all(12),
              children: [
                for (final d in s.data!.docs)
                  Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFE8D9B5)),
                    ),
                    child: Row(children: [
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(d['title'] ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          const SizedBox(height: 4),
                          Text('${d['date'] ?? ''} • ${d['location'] ?? ''}',
                              style: const TextStyle(color: Colors.grey, fontSize: 12)),
                        ]),
                      ),
                      IconButton(
                        icon: const Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () => Db.setStatus(d.id, 'approved'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.cancel, color: Colors.red),
                        onPressed: () => Db.setStatus(d.id, 'rejected'),
                      ),
                    ]),
                  ),
              ],
            );
          },
        ),
      );
}