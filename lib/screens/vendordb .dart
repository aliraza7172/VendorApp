import 'package:flutter/material.dart';
import 'package:vendor/screens/home.dart';
import 'package:vendor/screens/products.dart';
import 'package:vendor/screens/profile.dart';

import 'todayOrderHistory.dart';

class VendorDashboard extends StatefulWidget {
  const VendorDashboard({super.key});

  @override
  _VendorDashboardState createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  int currentIndex = 0;

  final List<Widget> pages = [
    const Order_detail(),
    InventoryScreen(),
    todayOrderHistory(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: pages[currentIndex],
      ),
      bottomNavigationBar: NavigationBar(
        // backgroundColor: Colors.teal,
        selectedIndex: currentIndex,
        onDestinationSelected: (int newIndex) {
          setState(() {
            currentIndex = newIndex;
          });
        },
        destinations: const [
          NavigationDestination(
            selectedIcon: Icon(
              Icons.home_filled,
            ),
            icon: Icon(Icons.home_outlined),
            label: "Orders",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.add_circle),
            icon: Icon(Icons.add_circle_outline),
            label: "Add Products",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.history_sharp),
            icon: Icon(Icons.history_outlined),
            label: "History",
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.person_2_sharp),
            icon: Icon(Icons.person_outlined),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
