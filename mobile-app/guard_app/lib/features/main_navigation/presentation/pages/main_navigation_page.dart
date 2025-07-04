import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:badges/badges.dart' as badges;
import '../../../dashboard/presentation/pages/dashboard_page.dart';
import '../../../dashboard/presentation/bloc/dashboard_bloc.dart';
import '../../../patrol/presentation/pages/patrol_page.dart';
import '../../../incidents/presentation/pages/incidents_page.dart';
import '../../../location/presentation/pages/location_page.dart';
import '../../../profile/presentation/pages/profile_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({Key? key}) : super(key: key);

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _pages = [
    const DashboardPage(),
    const PatrolPage(),
    const IncidentsPage(),
    const LocationPage(),
    const ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    // Load dashboard data when the navigation page is initialized
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardBloc>().add(DashboardLoadRequested());
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    
    // Load dashboard data when dashboard tab is selected
    if (index == 0) {
      context.read<DashboardBloc>().add(DashboardRefreshRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.security),
            label: 'Patrol',
          ),
          BottomNavigationBarItem(
            icon: badges.Badge(
              badgeContent: const Text(
                '2',
                style: TextStyle(color: Colors.white, fontSize: 10),
              ),
              showBadge: true, // You can control this based on actual incidents
              child: const Icon(Icons.warning),
            ),
            label: 'Incidents',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: 'Location',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
