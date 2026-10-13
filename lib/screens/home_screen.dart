// import 'package:flutter/material.dart';
// import '../theme/app_theme.dart';
// import '../services/db.dart';
// import 'event_details_screen.dart';
// import 'search_screen.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});
//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   String q = '', cat = 'All';
//   static const cats = [
//     'All',
//     'Cultural',
//     'Music',
//     'Festivals',
//     'Campus',
//     'Food',
//     'Sports',
//     'Tech'
//   ];

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         backgroundColor: const Color(0xfffbfaf7),
//         body: StreamBuilder(
//           stream: Db.approvedEvents(),
//           builder: (context, snapshot) {
//             if (!snapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             final docs = snapshot.data!.docs.where((doc) {
//               final event = doc.data();
//               final matchesText =
//                   '${event['title'] ?? ''} ${event['location'] ?? ''}'
//                       .toLowerCase()
//                       .contains(q);
//               return matchesText && (cat == 'All' || event['category'] == cat);
//             }).toList();
//             return ListView(
//               padding: const EdgeInsets.only(bottom: 20),
//                 children: [
//                   _HomeHero(
//                     onSearch: (value) =>
//                       setState(() => q = value.toLowerCase())),
//                 const SizedBox(height: 12),
//                 Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 16),
//                 child: SizedBox(
//                   height: 38,
//                   child: ListView.separated(
//                     scrollDirection: Axis.horizontal,
//                     itemCount: cats.length,
//                     separatorBuilder: (_, __) =>
//                       const SizedBox(width: 8),
//                     itemBuilder: (context, index) => ChoiceChip(
//                       label: Text(cats[index]),
//                       selected: cat == cats[index],
//                       onSelected: (_) =>
//                         setState(() => cat = cats[index]))),
//                 ),
//                 ),
//                   const SizedBox(height: 20),
//                   _HomeSection(title: 'Popular Now in Sri Lanka', events: docs),
//                   _HomeSection(
//                       title: 'Nearby Suggestions',
//                       events: docs.reversed.toList()),
//                   for (final group in cats.skip(1))
//                     _HomeSection(
//                         title: '$group Events',
//                         events: docs
//                             .where((doc) => doc.data()['category'] == group)
//                             .toList()),
//                   if (docs.isEmpty)
//                     const Padding(
//                         padding: EdgeInsets.only(top: 24),
//                         child: Center(child: Text('No events found'))),
//                 ]);
//           },
//         ),
//       );
// }

// class _HomeSection extends StatelessWidget {
//   final String title;
//   final List<dynamic> events;
//   const _HomeSection({required this.title, required this.events});

//   @override
//   Widget build(BuildContext context) {
//     if (events.isEmpty) {
//       return const SizedBox.shrink();
//     }
//     return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//       Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
//         Text(title,
//             style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
//         TextButton(
//           onPressed: () => Navigator.push(context,
//             MaterialPageRoute(builder: (_) => const SearchScreen())),
//           child: const Text('See All')),
//       ]),
//       SizedBox(
//         height: 184,
//         child: ListView.separated(
//           scrollDirection: Axis.horizontal,
//           itemCount: events.length > 6 ? 6 : events.length,
//           separatorBuilder: (_, __) => const SizedBox(width: 10),
//           itemBuilder: (context, index) {
//             final doc = events[index];
//             final data = doc.data();
//             return SizedBox(
//               width: 220,
//               child: Card(
//                 margin: EdgeInsets.zero,
//                 child: InkWell(
//                   borderRadius: BorderRadius.circular(12),
//                   onTap: () => Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                           builder: (_) =>
//                               EventDetailsScreen(id: doc.id, data: data))),
//                   child: Padding(
//                     padding: const EdgeInsets.all(10),
//                     child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           _EventImage(
//                               url: data['imageUrl']?.toString(),
//                               height: 64),
//                           const SizedBox(height: 7),
//                           Row(children: [
//                             const Icon(Icons.verified,
//                                 size: 14, color: AppColors.success),
//                             const SizedBox(width: 4),
//                             Expanded(
//                                 child: Text(data['title'] ?? 'Untitled event',
//                                     maxLines: 1,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: const TextStyle(
//                                         fontWeight: FontWeight.w700,
//                                         fontSize: 12))),
//                           ]),
//                           const SizedBox(height: 4),
//                           Text('${data['date'] ?? ''} • ${data['time'] ?? ''}',
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(
//                                   fontSize: 10, color: Colors.grey)),
//                           Text(data['location'] ?? '',
//                               maxLines: 1,
//                               overflow: TextOverflow.ellipsis,
//                               style: const TextStyle(
//                                   fontSize: 10, color: Colors.grey)),
//                         ]),
//                   ),
//                 ),
//               ),
//             );
//           },
//         ),
//       ),
//     ]);
//   }
// }

// class _HomeHero extends StatelessWidget {
//   final ValueChanged<String> onSearch;
//   const _HomeHero({required this.onSearch});

//   @override
//   Widget build(BuildContext context) {
//     return SizedBox(
//       height: 190,
//       child: Stack(fit: StackFit.expand, children: [
//         Image.asset('assets/images/home_hero.jpg', fit: BoxFit.cover),
//         ColoredBox(color: Colors.black.withValues(alpha: .28)),
//         Padding(
//           padding: const EdgeInsets.fromLTRB(18, 28, 18, 18),
//           child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//             Text('Hello, $userName!',
//                 style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 24,
//                     fontWeight: FontWeight.w700)),
//             const Text('Ready to explore Sri Lanka?',
//                 style: TextStyle(color: Colors.white, fontSize: 12)),
//             const Spacer(),
//             TextField(
//                 onChanged: onSearch,
//                 decoration: InputDecoration(
//                     hintText: 'Search events, workshops, festivals...',
//                     prefixIcon: const Icon(Icons.search, size: 20),
//                     suffixIcon: const Icon(Icons.tune, size: 19),
//                     filled: true,
//                     fillColor: Colors.white,
//                     contentPadding:
//                         const EdgeInsets.symmetric(vertical: 10),
//                     border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(10),
//                         borderSide: BorderSide.none))),
//           ]),
//         ),
//       ]),
//     );
//   }
// }

// class _EventImage extends StatelessWidget {
//   final String? url;
//   final double height;
//   const _EventImage({required this.url, required this.height});

//   @override
//   Widget build(BuildContext context) {
//     final imageUrl = url?.trim() ?? '';
//     return Container(
//       height: height,
//       width: double.infinity,
//       decoration: BoxDecoration(
//           color: const Color(0xfffff3c4),
//           borderRadius: BorderRadius.circular(8)),
//       clipBehavior: Clip.antiAlias,
//       child: imageUrl.isEmpty
//           ? const Center(child: Icon(Icons.event, size: 28))
//           : Image.network(imageUrl,
//               fit: BoxFit.cover,
//               errorBuilder: (_, __, ___) =>
//                   const Center(child: Icon(Icons.event, size: 28))),
//     );
//   }
// }


import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/db.dart';
import 'event_details_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String q = '';
  String cat = 'All';

  static const cats = [
    'All',
    'Cultural',
    'Music',
    'Festivals',
    'Campus',
    'Food',
    'Sports',
    'Tech',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F8F6),
      body: StreamBuilder(
        stream: Db.approvedEvents(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const _LoadingView();
          }

          final docs = snapshot.data!.docs.where((doc) {
            final event = doc.data();

            final matchesText =
                '${event['title'] ?? ''} ${event['location'] ?? ''}'
                    .toLowerCase()
                    .contains(q);

            return matchesText &&
                (cat == 'All' || event['category'] == cat);
          }).toList();

          return ListView(
            padding: EdgeInsets.zero,
            physics: const BouncingScrollPhysics(),
            children: [
              _HomeHero(
                onSearch: (value) {
                  setState(() => q = value.toLowerCase());
                },
              ),

              const SizedBox(height: 22),

              _CategorySection(
                categories: cats,
                selectedCategory: cat,
                onSelected: (category) {
                  setState(() => cat = category);
                },
              ),

              const SizedBox(height: 28),

              if (docs.isNotEmpty) ...[
                _HomeSection(
                  title: 'Popular Now',
                  subtitle: 'Trending events around Sri Lanka',
                  icon: Icons.local_fire_department_rounded,
                  events: docs,
                ),

                const SizedBox(height: 12),

                _HomeSection(
                  title: 'Nearby Suggestions',
                  subtitle: 'Discover events happening around you',
                  icon: Icons.near_me_rounded,
                  events: docs.reversed.toList(),
                ),

                const SizedBox(height: 12),

                for (final group in cats.skip(1))
                  _HomeSection(
                    title: '$group Events',
                    subtitle: 'Explore the latest $group experiences',
                    icon: _categoryIcon(group),
                    events: docs
                        .where(
                          (doc) => doc.data()['category'] == group,
                        )
                        .toList(),
                  ),
              ],

              if (docs.isEmpty) const _EmptyEvents(),

              const SizedBox(height: 32),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// HERO
// ============================================================

class _HomeHero extends StatelessWidget {
  final ValueChanged<String> onSearch;

  const _HomeHero({
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 285,
      width: double.infinity,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/home_hero.jpg',
            fit: BoxFit.cover,
          ),

          // Gradient overlay
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.20),
                  Colors.black.withValues(alpha: 0.42),
                  Colors.black.withValues(alpha: 0.78),
                ],
              ),
            ),
          ),

          // Orange glow
          Positioned(
            right: -80,
            top: -70,
            child: Container(
              width: 210,
              height: 210,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFF8A00)
                    .withValues(alpha: 0.22),
              ),
            ),
          ),

          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                24,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row
                  Row(
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Colors.white,
                          size: 21,
                        ),
                      ),
                      const SizedBox(width: 11),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Explore Events',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Sri Lanka',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.18),
                          ),
                        ),
                        child: const Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                    ],
                  ),

                  const Spacer(),

                  Text(
                    'Hello, $userName!',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 27,
                      height: 1.1,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 7),

                  const Text(
                    'Find events, experiences and moments\nworth remembering.',
                    style: TextStyle(
                      color: Color(0xFFE8E8E8),
                      fontSize: 13,
                      height: 1.45,
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Search field
                  Container(
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(17),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.12),
                          blurRadius: 18,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: TextField(
                      onChanged: onSearch,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF222222),
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search events, workshops, festivals...',
                        hintStyle: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF9A9A9A),
                        ),
                        prefixIcon: const Padding(
                          padding: EdgeInsets.only(
                            left: 4,
                          ),
                          child: Icon(
                            Icons.search_rounded,
                            size: 22,
                            color: Color(0xFF2B2B2B),
                          ),
                        ),
                        suffixIcon: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF8A00),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.tune_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                        filled: true,
                        fillColor: Colors.transparent,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(17),
                          borderSide: const BorderSide(
                            color: Color(0xFFFF8A00),
                            width: 1.4,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CATEGORIES
// ============================================================

class _CategorySection extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const _CategorySection({
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 18),
          child: Text(
            'Browse Categories',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF202020),
              letterSpacing: -0.2,
            ),
          ),
        ),

        const SizedBox(height: 14),

        SizedBox(
          height: 42,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 9),
            itemBuilder: (context, index) {
              final category = categories[index];
              final selected = selectedCategory == category;

              return GestureDetector(
                onTap: () => onSelected(category),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                  ),
                  decoration: BoxDecoration(
                    color: selected
                        ? const Color(0xFFFF8A00)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(
                      color: selected
                          ? const Color(0xFFFF8A00)
                          : const Color(0xFFECECE8),
                    ),
                    boxShadow: selected
                        ? [
                            BoxShadow(
                              color: const Color(0xFFFF8A00)
                                  .withValues(alpha: 0.18),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ]
                        : [],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _categoryIcon(category),
                        size: 16,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF777777),
                      ),
                      const SizedBox(width: 7),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w600,
                          color: selected
                              ? Colors.white
                              : const Color(0xFF555555),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ============================================================
// EVENT SECTION
// ============================================================

class _HomeSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<dynamic> events;

  const _HomeSection({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.events,
  });

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF0DF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFFFF8A00),
                    size: 19,
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          height: 1.1,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF202020),
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10.5,
                          color: Color(0xFF969696),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),

                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SearchScreen(),
                      ),
                    );
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFFFF8A00),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                    ),
                  ),
                  child: const Row(
                    children: [
                      Text(
                        'See All',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          // Cards
          SizedBox(
            height: 248,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
              ),
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              itemCount: events.length > 6 ? 6 : events.length,
              separatorBuilder: (_, __) => const SizedBox(width: 14),
              itemBuilder: (context, index) {
                final doc = events[index];
                final data = doc.data();

                return _EventCard(
                  data: data,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EventDetailsScreen(
                          id: doc.id,
                          data: data,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EVENT CARD
// ============================================================

class _EventCard extends StatelessWidget {
  final dynamic data;
  final VoidCallback onTap;

  const _EventCard({
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = data['title']?.toString() ?? 'Untitled event';
    final date = data['date']?.toString() ?? '';
    final time = data['time']?.toString() ?? '';
    final location = data['location']?.toString() ?? '';
    final category = data['category']?.toString() ?? 'Event';

    return SizedBox(
      width: 235,
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFFEEEEEA),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.045),
                  blurRadius: 18,
                  offset: const Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image
                Stack(
                  children: [
                    _EventImage(
                      url: data['imageUrl']?.toString(),
                      height: 125,
                    ),

                    Positioned(
                      left: 10,
                      top: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.93),
                          borderRadius: BorderRadius.circular(9),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            color: Color(0xFFFF7A00),
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),

                    Positioned(
                      right: 10,
                      top: 10,
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.93),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.bookmark_border_rounded,
                          size: 18,
                          color: Color(0xFF363636),
                        ),
                      ),
                    ),
                  ],
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      12,
                      11,
                      12,
                      10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                  height: 1.25,
                                  color: Color(0xFF242424),
                                ),
                              ),
                            ),
                            const SizedBox(width: 5),
                            const Padding(
                              padding: EdgeInsets.only(top: 1),
                              child: Icon(
                                Icons.verified_rounded,
                                size: 15,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_month_rounded,
                              size: 13,
                              color: Color(0xFFFF8A00),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                '$date${time.isNotEmpty ? '  •  $time' : ''}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  color: Color(0xFF777777),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Row(
                          children: [
                            const Icon(
                              Icons.location_on_outlined,
                              size: 13,
                              color: Color(0xFFFF8A00),
                            ),
                            const SizedBox(width: 5),
                            Expanded(
                              child: Text(
                                location.isEmpty
                                    ? 'Location unavailable'
                                    : location,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 9.5,
                                  color: Color(0xFF8A8A8A),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// EVENT IMAGE
// ============================================================

class _EventImage extends StatelessWidget {
  final String? url;
  final double height;

  const _EventImage({
    required this.url,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = url?.trim() ?? '';

    return Container(
      height: height,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Color(0xFFFFF2DE),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(19),
          topRight: Radius.circular(19),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: imageUrl.isEmpty
          ? const _ImagePlaceholder()
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) {
                return const _ImagePlaceholder();
              },
            ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFF3E1),
            Color(0xFFFFE0B5),
          ],
        ),
      ),
      child: const Center(
        child: Icon(
          Icons.event_rounded,
          size: 38,
          color: Color(0xFFFF9A31),
        ),
      ),
    );
  }
}

// ============================================================
// EMPTY STATE
// ============================================================

class _EmptyEvents extends StatelessWidget {
  const _EmptyEvents();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        25,
        60,
        25,
        50,
      ),
      child: Column(
        children: [
          Container(
            width: 85,
            height: 85,
            decoration: const BoxDecoration(
              color: Color(0xFFFFF0DF),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.event_busy_rounded,
              size: 36,
              color: Color(0xFFFF8A00),
            ),
          ),
          const SizedBox(height: 17),
          const Text(
            'No events found',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              color: Color(0xFF252525),
            ),
          ),
          const SizedBox(height: 7),
          const Text(
            'Try another search or choose a different category.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              height: 1.5,
              color: Color(0xFF919191),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LOADING
// ============================================================

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: Color(0xFFFF8A00),
        strokeWidth: 2.5,
      ),
    );
  }
}

// ============================================================
// CATEGORY ICONS
// ============================================================

IconData _categoryIcon(String category) {
  switch (category) {
    case 'Cultural':
      return Icons.temple_buddhist_rounded;

    case 'Music':
      return Icons.music_note_rounded;

    case 'Festivals':
      return Icons.celebration_rounded;

    case 'Campus':
      return Icons.school_rounded;

    case 'Food':
      return Icons.restaurant_rounded;

    case 'Sports':
      return Icons.sports_basketball_rounded;

    case 'Tech':
      return Icons.memory_rounded;

    default:
      return Icons.grid_view_rounded;
  }
}