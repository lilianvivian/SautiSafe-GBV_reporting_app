import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'sos_map_crossplatform.dart';

class SOSPage extends StatelessWidget {
  const SOSPage({super.key});

  Future<void> _callHelpline() async {
    const helplineNumber = '116'; // Kenya Child Helpline / GBV support
    final Uri phoneUri = Uri(scheme: 'tel', path: helplineNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  Future<void> _sendSOS() async {
    final Uri smsUri = Uri(
      scheme: 'sms',
      path: '116', // same helpline or can be changed to your NGO’s number
      queryParameters: {
        'body': 'Please help! I am in danger or need urgent GBV support.'
      },
    );
    if (await canLaunchUrl(smsUri)) {
      await launchUrl(smsUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2FB),
      appBar: AppBar(
        title: const Text("Emergency Help"),
        centerTitle: true,
        backgroundColor: const Color(0xFF7A3E9D),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_rounded,
                color: Color(0xFFD35400), size: 90),
            const SizedBox(height: 20),
            const Text(
              "If you or someone else is in danger, please reach out immediately.",
              style: TextStyle(
                color: Color(0xFF5B2C6F),
                fontSize: 18,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 50),

            //  SOS Button
            ElevatedButton.icon(
              icon: const Icon(Icons.phone, color: Colors.white),
              label: const Text(
                "Call Helpline (116)",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              onPressed: _callHelpline,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 32),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
            const SizedBox(height: 20),

            //  SMS Button
            OutlinedButton.icon(
              icon: const Icon(Icons.sms, color: Color(0xFF8E44AD)),
              label: const Text(
                "Send SOS Message",
                style: TextStyle(fontSize: 16, color: Color(0xFF8E44AD)),
              ),
              onPressed: _sendSOS,
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF8E44AD), width: 2),
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 28),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),

            const SizedBox(height: 50),

            //Navigation to the map page
            TextButton(
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) =>  SOSMapCrossPlatformPage()),
    );
  },
  child: const Text(
    "View Live SOS Alerts on Map",
    style: TextStyle(
      color: Color(0xFF8E44AD),
      fontSize: 16,
      decoration: TextDecoration.underline,
    ),
  ),
),
            const SizedBox(height: 20),

            const Text(
              "Calls and messages are confidential.\nThis line is free and available 24/7.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
