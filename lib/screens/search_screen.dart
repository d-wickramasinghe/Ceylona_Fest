// import 'package:flutter/material.dart';
// import '../services/db.dart';
// import 'event_details_screen.dart';
// import '../widgets/event_image.dart';
// import '../widgets/seeker_page_header.dart';

// class SearchScreen extends StatefulWidget {
//   const SearchScreen({super.key});
//   @override
//   State<SearchScreen> createState() => _SearchScreenState();
// }

// class _SearchScreenState extends State<SearchScreen> {
//   final query = TextEditingController();
//   String category = 'All';
//   String location = 'All locations';
//   String dateRange = 'Any date';
//   final categories = const [
//     'All',
//     'Cultural',
//     'Music',
//     'Festivals',
//     'Campus',
//     'Sports',
//     'Food',
//     'Tech'
//   ];

//   @override
//   void dispose() {
//     query.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) => Scaffold(
//         backgroundColor: const Color(0xfffbfaf7),
//         body: Column(children: [
//           SeekerPageHeader(
//               title: 'Find your next event',
//               subtitle: 'Search festivals, music, food and more',
//               actions: [
//                 IconButton(
//                     tooltip: 'Clear filters',
//                     onPressed: () => setState(() {
//                           query.clear();
//                           category = 'All';
//                           location = 'All locations';
//                           dateRange = 'Any date';
//                         }),
//                     icon: const Icon(Icons.restart_alt))
//               ]),
//           Expanded(child: StreamBuilder(
//           stream: Db.approvedEvents(),
//           builder: (context, snapshot) {
//             if (snapshot.hasError) {
//               return Center(
//                   child: Text('Could not load events: ${snapshot.error}'));
//             }
//             if (!snapshot.hasData) {
//               return const Center(child: CircularProgressIndicator());
//             }
//             final events = snapshot.data!.docs.where((doc) {
//               final data = doc.data();
//               final text = '${data['title'] ?? ''} ${data['location'] ?? ''}'
//                   .toLowerCase();
//               final matchesQuery = text.contains(query.text.toLowerCase());
//               final matchesCategory =
//                   category == 'All' || data['category'] == category;
//               final matchesLocation =
//                   location == 'All locations' || data['location'] == location;
//               return matchesQuery && matchesCategory && matchesLocation;
//             }).toList();
//             return Column(children: [
//               Padding(
//                 padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
//                 child: TextField(
//                   controller: query,
//                   decoration: const InputDecoration(
//                       prefixIcon: Icon(Icons.search),
//                       hintText: 'Search by event or location',
//                       border: OutlineInputBorder()),
//                   onChanged: (_) => setState(() {}),
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.symmetric(horizontal: 12),
//                 child: Row(children: [
//                   Expanded(
//                       child: DropdownButtonFormField<String>(
//                           initialValue: location,
//                           decoration: const InputDecoration(
//                               labelText: 'Location',
//                               border: OutlineInputBorder()),
//                           items: const [
//                             'All locations',
//                             'Colombo',
//                             'Kandy',
//                             'Galle'
//                           ]
//                               .map((value) => DropdownMenuItem(
//                                   value: value, child: Text(value)))
//                               .toList(),
//                           onChanged: (value) =>
//                               setState(() => location = value!))),
//                   const SizedBox(width: 8),
//                   Expanded(
//                       child: DropdownButtonFormField<String>(
//                           initialValue: dateRange,
//                           decoration: const InputDecoration(
//                               labelText: 'Date range',
//                               border: OutlineInputBorder()),
//                           items: const [
//                             'Any date',
//                             'This Weekend',
//                             'This Month'
//                           ]
//                               .map((value) => DropdownMenuItem(
//                                   value: value, child: Text(value)))
//                               .toList(),
//                           onChanged: (value) =>
//                               setState(() => dateRange = value!))),
//                 ]),
//               ),
//               Padding(
//                   padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
//                   child: SizedBox(
//                       width: double.infinity,
//                       child: FilledButton(
//                           onPressed: () => setState(() {}),
//                           child: const Text('Apply Filters')))),
//               SizedBox(
//                 height: 56,
//                 child: ListView(
//                   padding: const EdgeInsets.symmetric(horizontal: 8),
//                   scrollDirection: Axis.horizontal,
//                   children: categories
//                       .map((value) => Padding(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 4, vertical: 8),
//                             child: ChoiceChip(
//                                 label: Text(value),
//                                 selected: category == value,
//                                 onSelected: (_) =>
//                                     setState(() => category = value)),
//                           ))
//                       .toList(),
//                 ),
//               ),
//               Align(
//                   alignment: Alignment.centerLeft,
//                   child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                           horizontal: 16, vertical: 8),
//                       child: Text(
//                           '${events.length.toString().padLeft(2, '0')} Events Found Matching Criteria',
//                           style:
//                               const TextStyle(fontWeight: FontWeight.w700)))),
//               Expanded(
//                 child: events.isEmpty
//                     ? const Center(
//                         child: Text('No approved events match your search'))
//                     : ListView.builder(
//                         itemCount: events.length,
//                         itemBuilder: (context, index) {
//                           final doc = events[index];
//                           final data = doc.data();
//                           return Card(
//                             margin: const EdgeInsets.symmetric(
//                                 horizontal: 12, vertical: 5),
//                             child: ListTile(
//                               leading: EventImage(
//                                   url: data['imageUrl']?.toString(),
//                                   width: 64,
//                                   height: 64,
//                                   borderRadius: const BorderRadius.all(
//                                       Radius.circular(6))),
//                               title: Text(data['title'] ?? 'Untitled event'),
//                               subtitle: Text(
//                                   '${data['date'] ?? ''} • ${data['location'] ?? ''}\n${data['price'] ?? 'Free'}'),
//                               isThreeLine: true,
//                               trailing: const Icon(Icons.chevron_right),
//                               onTap: () => Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                       builder: (_) => EventDetailsScreen(
//                                           id: doc.id, data: data))),
//                             ),
//                           );
//                         },
//                       ),
//               ),
//             ]);
//           },
//         )),
//         ]),
//       );
// }


import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';
import '../services/db.dart';
import 'event_details_screen.dart';
import '../widgets/event_image.dart';

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

  static const categories = [
    'All', 'Cultural', 'Music', 'Festivals',
    'Campus', 'Sports', 'Food', 'Tech',
  ];

  static const locations = [
    'All locations', 'Colombo', 'Kandy', 'Galle',
  ];

  static const dateRanges = [
    'Any date', 'This Weekend', 'This Month',
  ];

  @override
  void dispose() {
    query.dispose();
    super.dispose();
  }

  void _clearFilters() {
    setState(() {
      query.clear();
      category = 'All';
      location = 'All locations';
      dateRange = 'Any date';
    });
  }

  IconData _categoryIcon(String value) {
    switch (value) {
      case 'Cultural':
        return Icons.temple_buddhist_rounded;
      case 'Music':
        return Icons.music_note_rounded;
      case 'Festivals':
        return Icons.celebration_rounded;
      case 'Campus':
        return Icons.school_rounded;
      case 'Sports':
        return Icons.sports_basketball_rounded;
      case 'Food':
        return Icons.restaurant_rounded;
      case 'Tech':
        return Icons.memory_rounded;
      default:
        return Icons.grid_view_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            // FIXED HEADER + SEARCH BAR
            _buildFixedHeader(),

            // SCROLLABLE FILTERS AND RESULTS
            Expanded(
              child: StreamBuilder(
                stream: Db.approvedEvents(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'Could not load events: ${snapshot.error}',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primary,
                      ),
                    );
                  }

                  // ORIGINAL BACKEND FILTERING - UNCHANGED
                  final events = snapshot.data!.docs.where((doc) {
                    final data = doc.data();

                    final text =
                        '${data['title'] ?? ''} ${data['location'] ?? ''}'
                            .toLowerCase();

                    final matchesQuery =
                        text.contains(query.text.toLowerCase());

                    final matchesCategory =
                        category == 'All' ||
                        data['category'] == category;

                    final matchesLocation =
                        location == 'All locations' ||
                        data['location'] == location;

                    return matchesQuery &&
                        matchesCategory &&
                        matchesLocation;
                  }).toList();

                  return ListView(
                    physics: const BouncingScrollPhysics(),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    padding: const EdgeInsets.only(
                      bottom: 30,
                    ),
                    children: [
                      const SizedBox(height: 22),

                      _buildSectionTitle(
                        'Filter Events',
                        Icons.tune_rounded,
                        trailing: TextButton(
                          onPressed: _clearFilters,
                          child: const Text('Reset'),
                        ),
                      ),

                      const SizedBox(height: 12),

                      _buildFilters(),

                      const SizedBox(height: 14),

                      _buildApplyButton(),

                      const SizedBox(height: 27),

                      _buildSectionTitle(
                        'Explore Categories',
                        Icons.grid_view_rounded,
                      ),

                      const SizedBox(height: 13),

                      _buildCategories(),

                      const SizedBox(height: 27),

                      _buildResultsHeading(events.length),

                      const SizedBox(height: 12),

                      if (events.isEmpty)
                        _buildEmptyState()
                      else
                        ...events.map((doc) {
                          final data = doc.data();

                          return Padding(
                            padding: const EdgeInsets.fromLTRB(
                              16, 0, 16, 13,
                            ),
                            child: _SearchEventCard(
                              data: data,
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      EventDetailsScreen(
                                    id: doc.id,
                                    data: data,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // FIXED HEADER
  // ==========================================================

  Widget _buildFixedHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(
              alpha: 0.05,
            ),
            blurRadius: 18,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _headerIcon(
                Icons.arrow_back_ios_new_rounded,
                () {
                  if (Navigator.canPop(context)) {
                    Navigator.pop(context);
                  }
                },
              ),

              const Spacer(),

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 13,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.explore_rounded,
                      size: 15,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'EXPLORE',
                      style: GoogleFonts.poppins(
                        fontSize: 10,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              _headerIcon(
                Icons.restart_alt_rounded,
                _clearFilters,
              ),
            ],
          ),

          const SizedBox(height: 23),

          Row(
            children: [
              Container(
                width: 22,
                height: 3,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'DISCOVER EXPERIENCES',
                style: GoogleFonts.poppins(
                  fontSize: 10,
                  letterSpacing: 1.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Find your next ',
                  style: GoogleFonts.poppins(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: AppColors.primaryDark,
                  ),
                ),
                TextSpan(
                  text: 'event.',
                  style: GoogleFonts.poppins(
                    fontSize: 25,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.8,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 7),

          Text(
            'Search festivals, music, food and more.\n'
            'Your next great experience starts here.',
            style: GoogleFonts.poppins(
              fontSize: 11,
              height: 1.65,
              color: AppColors.secondaryText,
            ),
          ),

          const SizedBox(height: 19),

          _buildSearchField(),
        ],
      ),
    );
  }

  Widget _headerIcon(
    IconData icon,
    VoidCallback action,
  ) {
    return Material(
      color: AppColors.background,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: action,
        borderRadius: BorderRadius.circular(13),
        child: SizedBox(
          width: 42,
          height: 42,
          child: Icon(
            icon,
            size: 19,
            color: AppColors.primaryDark,
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // FIXED SEARCH FIELD
  // ==========================================================

  Widget _buildSearchField() {
    return Container(
      height: 55,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: TextField(
        controller: query,
        onChanged: (_) => setState(() {}),
        textInputAction: TextInputAction.search,
        style: GoogleFonts.inter(
          fontSize: 13,
          color: AppColors.primaryDark,
        ),
        decoration: InputDecoration(
          hintText: 'Search events or locations...',
          hintStyle: GoogleFonts.inter(
            fontSize: 12,
            color: AppColors.secondaryText,
          ),
          prefixIcon: const Icon(
            Icons.search_rounded,
            color: AppColors.primary,
            size: 22,
          ),
          suffixIcon: query.text.isNotEmpty
              ? IconButton(
                  onPressed: () {
                    setState(() => query.clear());
                  },
                  icon: const Icon(
                    Icons.close_rounded,
                    size: 19,
                  ),
                )
              : const Icon(
                  Icons.tune_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
          filled: true,
          fillColor: Colors.transparent,
          contentPadding: const EdgeInsets.symmetric(
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.5,
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // SECTION TITLE
  // ==========================================================

  Widget _buildSectionTitle(
    String title,
    IconData icon, {
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Row(
        children: [
          Container(
            width: 37,
            height: 37,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 19,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  // ==========================================================
  // FILTER DROPDOWNS
  // ==========================================================

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _filterDropdown(
              label: 'Location',
              icon: Icons.location_on_outlined,
              value: location,
              items: locations,
              onChanged: (value) {
                setState(() => location = value);
              },
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: _filterDropdown(
              label: 'Date Range',
              icon: Icons.calendar_month_outlined,
              value: dateRange,
              items: dateRanges,
              onChanged: (value) {
                setState(() => dateRange = value);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _filterDropdown({
    required String label,
    required IconData icon,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.fromLTRB(11, 10, 8, 10),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.primary,
            size: 19,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 4),
                DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: value,
                    isDense: true,
                    isExpanded: true,
                    borderRadius: BorderRadius.circular(12),
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 17,
                    ),
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryDark,
                    ),
                    items: items.map((item) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(
                          item,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        onChanged(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // APPLY FILTER BUTTON
  // ==========================================================

  Widget _buildApplyButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SizedBox(
        height: 48,
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: () => setState(() {}),
          icon: const Icon(
            Icons.tune_rounded,
            size: 18,
          ),
          label: Text(
            'Apply Filters',
            style: GoogleFonts.poppins(
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.primaryDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }

  // ==========================================================
  // CATEGORIES
  // ==========================================================

  Widget _buildCategories() {
    return SizedBox(
      height: 43,
      child: ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder: (_, __) =>
            const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final item = categories[index];
          final selected = category == item;

          return InkWell(
            onTap: () {
              setState(() => category = item);
            },
            borderRadius: BorderRadius.circular(13),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? AppColors.primary
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : AppColors.border,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _categoryIcon(item),
                    size: 16,
                    color: selected
                        ? AppColors.primaryDark
                        : AppColors.secondaryText,
                  ),
                  const SizedBox(width: 7),
                  Text(
                    item,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: selected
                          ? AppColors.primaryDark
                          : AppColors.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ==========================================================
  // RESULTS HEADER
  // ==========================================================

  Widget _buildResultsHeading(int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 17),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.explore_outlined,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Search Results',
                  style: GoogleFonts.poppins(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                Text(
                  '${count.toString().padLeft(2, '0')} events found matching your criteria',
                  style: GoogleFonts.inter(
                    fontSize: 10,
                    color: AppColors.secondaryText,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _clearFilters,
            child: Text(
              'Clear All',
              style: GoogleFonts.poppins(
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 24,
        vertical: 50,
      ),
      child: Column(
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(
                alpha: 0.12,
              ),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.search_off_rounded,
              color: AppColors.primary,
              size: 40,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No events found',
            style: GoogleFonts.poppins(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No approved events match your search.\n'
            'Try different keywords or filters.',
            textAlign: TextAlign.center,
            style: GoogleFonts.inter(
              fontSize: 12,
              height: 1.5,
              color: AppColors.secondaryText,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EVENT RESULT CARD
// ============================================================

class _SearchEventCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final VoidCallback onTap;

  const _SearchEventCard({
    required this.data,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title =
        data['title']?.toString() ?? 'Untitled event';
    final date = data['date']?.toString() ?? '';
    final location = data['location']?.toString() ?? '';
    final category = data['category']?.toString() ?? 'Event';
    final price = data['price']?.toString() ?? 'Free';

    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryDark.withValues(
                  alpha: 0.04,
                ),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              EventImage(
                url: data['imageUrl']?.toString(),
                width: 110,
                height: 135,
                borderRadius: BorderRadius.circular(12),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: SizedBox(
                  height: 135,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 9,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(
                            alpha: 0.12,
                          ),
                          borderRadius: BorderRadius.circular(7),
                        ),
                        child: Text(
                          category,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.poppins(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryDark,
                        ),
                      ),

                      const Spacer(),

                      _infoRow(
                        Icons.calendar_month_rounded,
                        date,
                      ),

                      const SizedBox(height: 6),

                      _infoRow(
                        Icons.location_on_outlined,
                        location,
                      ),

                      const SizedBox(height: 8),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              price,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                          Container(
                            width: 26,
                            height: 26,
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  .withValues(alpha: 0.12),
                              borderRadius:
                                  BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.arrow_forward_rounded,
                              color: AppColors.primary,
                              size: 16,
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
    );
  }

  Widget _infoRow(IconData icon, String value) {
    return Row(
      children: [
        Icon(
          icon,
          size: 13,
          color: AppColors.primary,
        ),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: GoogleFonts.inter(
              fontSize: 10,
              color: AppColors.secondaryText,
            ),
          ),
        ),
      ],
    );
  }
}