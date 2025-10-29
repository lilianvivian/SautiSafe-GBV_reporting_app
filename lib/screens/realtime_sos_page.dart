import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

class RealTimeSOSPage extends StatefulWidget {
  const RealTimeSOSPage({super.key});

  @override
  State<RealTimeSOSPage> createState() => _RealTimeSOSPageState();
}

class _RealTimeSOSPageState extends State<RealTimeSOSPage> {
  bool _sending = false;
  String? _statusMessage;

  Future<void> _sendSOS() async {
    setState(() {
      _sending = true;
      _statusMessage = "Getting your location...";
    });

    try {
      // ✅ Ask for location permission
      LocationPermission permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _sending = false;
          _statusMessage = "Location permission denied.";
        });
        return;
      }

      // ✅ Get current position
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      // ✅ Send to Firestore
      await FirebaseFirestore.instance.collection('sos_alerts').add({
        'latitude': position.latitude,
        'longitude': position.longitude,
        'timestamp': FieldValue.serverTimestamp(),
      });

      setState(() {
        _sending = false;
        _statusMessage = "SOS alert sent successfully 🚨";
      });
    } catch (e) {
      setState(() {
        _sending = false;
        _statusMessage = "Error: $e";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A3E9D),
        title: const Text("Real-Time SOS Alert"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.emergency_share, color: Color(0xFFE74C3C), size: 80),
            const SizedBox(height: 20),
            const Text(
              "Tap the button below to send a live SOS alert.\nYour location will be shared securely.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Color(0xFF5B2C6F)),
            ),
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: _sending ? null : _sendSOS,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE74C3C),
                padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 36),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: _sending
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                      "Send SOS Alert",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
            ),
            const SizedBox(height: 30),

            if (_statusMessage != null)
              Text(
                _statusMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Color(0xFF7A3E9D)),
              ),
          ],
        ),
      ),
    );
  }
}
