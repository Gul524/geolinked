import 'package:flutter/material.dart';
import 'package:geolinked/shared/widgets/custom_bottom_navigation_bar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  static const String routeName = '/home';

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 2;

  static const List<CustomBottomNavigationItem> _items =
      <CustomBottomNavigationItem>[
        CustomBottomNavigationItem(
          icon: Icons.map_outlined,
          label: 'Map',
          activeColor: Color(0xFF12B3B6),
        ),
        CustomBottomNavigationItem(
          icon: Icons.question_answer_outlined,
          label: 'Ask History',
          activeColor: Color(0xFF7A7F88),
        ),
        CustomBottomNavigationItem(
          icon: Icons.campaign_outlined,
          label: 'Broadcasts',
          activeColor: Color(0xFF007AFF),
        ),
        CustomBottomNavigationItem(
          icon: Icons.person_outline,
          label: 'Profile',
          activeColor: Color(0xFF2F80ED),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final surface = Theme.of(context).colorScheme.surface;

    return Scaffold(
      backgroundColor: surface,
      body: IndexedStack(
        index: _currentIndex,
        children: <Widget>[
          _TabPlaceholder(title: 'Map', primary: primary, onSurface: onSurface),
          _TabPlaceholder(
            title: 'Ask History',
            primary: primary,
            onSurface: onSurface,
          ),
          _TabPlaceholder(
            title: 'Broadcasts',
            primary: primary,
            onSurface: onSurface,
          ),
          _TabPlaceholder(
            title: 'Profile',
            primary: primary,
            onSurface: onSurface,
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        items: _items,
        currentIndex: _currentIndex,
        onTap: (int index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}

class _TabPlaceholder extends StatelessWidget {
  const _TabPlaceholder({
    required this.title,
    required this.primary,
    required this.onSurface,
  });

  final String title;
  final Color primary;
  final Color onSurface;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(Icons.radio_button_checked, color: primary, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: onSurface,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
