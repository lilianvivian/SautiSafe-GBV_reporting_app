import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'welcome_page.dart';
import 'realtime_sos_page.dart';
import 'sos_page.dart';
import 'resources_page.dart';
import 'admin_page.dart';
import 'report_page.dart';
import 'sos_map_crossplatform.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance; // ✅ Added instance
  int _currentIndex = 0;

  
  List<Widget> _pages = [];
  List<BottomNavigationBarItem> _navItems = [];

  bool _isLoadingRole = true;
  bool _isAdmin = false;

  // --- NEW: Call the role check when the page first loads ---
  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  // --- NEW: Function to check the user's role in Firestore ---
  Future<void> _checkUserRole() async {
    final user = _auth.currentUser;
    if (user == null) {
      // If user is somehow null, stop loading and show basic tabs
      setState(() => _isLoadingRole = false);
      return;
    }

    bool isAdmin = false;
    try {
      // 1. Get the user's role document from the 'users' collection
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      // 2. Check if the 'role' field is 'admin'
      if (doc.exists && doc.data()?['role'] == 'admin') {
        isAdmin = true;
      }
    } catch (e) {
      // Log any errors (like permission denied if rules are wrong)
      print("Error checking user role: $e");
    }

    setState(() {
      _isAdmin = isAdmin;
      _pages = [
        const _HomeMainScreen(),
        const ReportCasePage(),
        const ResourcesPage(),
        
      ];
      _navItems = [
        const BottomNavigationBarItem(
          icon: Icon(Icons.home_rounded),
          label: "Home",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.report_problem_rounded),
          label: "Report",
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.info_rounded),
          label: "Resources",
        ),
      ];
      if (_isAdmin) {
          _pages.add(const AdminPage());
        _navItems.add(
          const BottomNavigationBarItem(
            icon: Icon(Icons.admin_panel_settings_rounded),
            label: "Admin",
          ),
        );
      }
      _isLoadingRole = false; // Done loading role

    });
  }

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  // 🩵 Extract a user-friendly name from the email
  String _getUserName() {
    final user = _auth.currentUser;
    if (user == null || user.email == null) return "User 🌼";

    final email = user.email!;
    String namePart = email.split('@')[0].replaceAll(RegExp(r'[0-9]'), '');
    if (namePart.isEmpty) return "User 🌼";

    namePart = namePart[0].toUpperCase() + namePart.substring(1);
    return "$namePart 🌼";
  }

  // 🚪 Logout logic with confirmation dialog
  Future<void> _logout(BuildContext context) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF7A3E9D),
            ),
            child: const Text("Logout"),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await _auth.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomePage()),
        (route) => false,
      );

      // ✅ Feedback after logout
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("You've logged out safely. Take care 💜"),
          backgroundColor: Color(0xFF7A3E9D),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

   @override
  Widget build(BuildContext context) {
    // --- NEW: Show a loading screen while we check the user's role ---
    if (_isLoadingRole) {
      return Scaffold(
        backgroundColor: const Color(0xFFF6F2FB),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF7A3E9D)),
        ),
      );
    }



    final userName = _getUserName();

    return Scaffold(
      backgroundColor: const Color(0xFFF6F2FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A3E9D),
        title: Text(
          "Welcome back, $userName",
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        elevation: 4,

        // ✅ Logout button
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded, color: Colors.white),
            tooltip: "Logout",
            onPressed: () => _logout(context),
          ),
        ],
      ),

      // 🧭 Main Body
       body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      

      // 🌈 Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF7A3E9D),
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        items: _navItems,
      ),
    );
  }
}
       

class _HomeMainScreen extends StatelessWidget {
  const _HomeMainScreen();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            const Icon(Icons.shield_rounded, color: Color(0xFF7A3E9D), size: 90),
            const SizedBox(height: 16),
            const Text(
              "SautiSafe",
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B2C6F),
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              "Speak Up, Stay Safe.",
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF7A3E9D),
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 50),

            Expanded(
              child: ListView(
                children: [
                  _buildMainButton(
                    context,
                    title: "Emergency Help",
                    icon: Icons.phone_in_talk_rounded,
                    color: const Color(0xFF9B59B6),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const RealTimeSOSPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildMainButton(
                    context,
                    title: "SOS Map",
                    icon: Icons.map_rounded,
                    color: const Color(0xFFB784E1),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SOSMapCrossPlatformPage()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  _buildMainButton(
                    context,
                    title: "SOS Page",
                    icon: Icons.sos_rounded,
                    color: const Color(0xFF8E44AD),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const SOSPage()),
                      );
                    },
                  ),
                ],
              ),
            ),

            const Text(
              "Your voice matters 💜",
              style: TextStyle(
                color: Color(0xFF7A3E9D),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 26, color: Colors.white),
      label: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        elevation: 6,
        shadowColor: Colors.black38,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
