import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  State<AdminPage> createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // No longer need _reports, as StreamBuilder handles it
  // List<Map<String, dynamic>> _reports = [];

  Stream<List<Map<String, dynamic>>> _reportsStream() {
    return _firestore.collection('reports').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id; // Keep doc ID for actions
            return data;
          }).toList(),
        );
  }

  String _getAdminName() {
    final user = _auth.currentUser;
    if (user?.email == null) return "Admin 🌼";
    String namePart = user!.email!.split('@')[0].replaceAll(RegExp(r'[0-9]'), '');
    if (namePart.isEmpty) return "Admin 🌼";
    namePart = namePart[0].toUpperCase() + namePart.substring(1);
    return "$namePart 🌼";
  }

  Future<void> _markResolved(String docId) async {
    await _firestore.collection('reports').doc(docId).update({'resolved': true});
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report marked as resolved ✅')),
      );
    }
  }

  // --- FIXED: This function no longer crashes on invalid emails ---
  String _maskEmail(String email) {
    final parts = email.split('@');
    // Check if there are at least 2 parts (name and domain)
    if (parts.length != 2) {
      // Not a valid email, just mask what we have
      if (email.length <= 3) return "***";
      return "${email.substring(0, 4)}***";
    }
    
    final name = parts[0];
    final domain = parts[1];
    
    if (name.length <= 3) return "***@$domain";
    return "${name.substring(0, 4)}***@$domain";
  }

  @override
  Widget build(BuildContext context) {
    final adminName = _getAdminName();

    return Scaffold(
      // --- REMOVED: AppBar to fix duplication ---
      // appBar: AppBar(
      //   title: Text("Welcome, $adminName"),
      //   backgroundColor: const Color(0xFF7A3E9D),
      //   centerTitle: true,
      // ),
      backgroundColor: const Color(0xFFF6F2FB),
      // --- UPDATED: Added SafeArea and Column to place text ---
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- ADDED: Welcome text here instead of AppBar ---
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                "Welcome, $adminName",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF5B2C6F),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                "Here are the most recent reports.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                ),
              ),
            ),
            // --- ADDED: Expanded to make StreamBuilder fill space ---
            Expanded(
              child: StreamBuilder<List<Map<String, dynamic>>>(
                stream: _reportsStream(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: Color(0xFF7A3E9D)),
                    );
                  }

                  // Handle errors, e.g., permissions
                  if (snapshot.hasError) {
                    return Center(
                      child: Text("Error: ${snapshot.error}", textAlign: TextAlign.center,),
                    );
                  }

                  final reports = snapshot.data ?? [];

                  if (reports.isEmpty) {
                    return const Center(
                      child: Text("No reports available."),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];
                      final resolved = report['resolved'] ?? false;
                      // --- FIXED: Read evidence URLs safely ---
                      final evidenceUrls = report['evidenceUrls'] as List? ?? [];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        color: resolved ? Colors.green[50] : Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ListTile(
                          leading: Icon(
                            Icons.report,
                            color: resolved ? Colors.green : Colors.redAccent,
                          ),
                          // --- FIXED: Use 'location' field ---
                          title: Text(
                            report['location'] ?? 'No Location',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              // --- FIXED: Use 'incident' field ---
                              Text(
                                report['incident'] ?? 'No description',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              if (report['userEmail'] != null)
                                Text(
                                  "Reporter: ${_maskEmail(report['userEmail'])}",
                                  style: const TextStyle(
                                      fontSize: 12, color: Colors.black54),
                                ),
                              // --- ADDED: Show evidence count ---
                              if (evidenceUrls.isNotEmpty)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    "Evidence: ${evidenceUrls.length} file(s)",
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.blue,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                            ],
                          ),
                          trailing: resolved
                              ? const Icon(Icons.check_circle, color: Colors.green)
                              : TextButton(
                                  onPressed: () => _markResolved(report['id']),
                                  child: const Text("Mark Resolved"),
                                ),
                          onTap: () {
                            // You can add a dialog here to show more details
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
