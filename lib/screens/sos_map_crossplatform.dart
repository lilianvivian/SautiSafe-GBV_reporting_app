import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SOSMapCrossPlatformPage extends StatefulWidget {
  const SOSMapCrossPlatformPage({super.key});

  @override
  State<SOSMapCrossPlatformPage> createState() => _SOSMapCrossPlatformPageState();
}

class _SOSMapCrossPlatformPageState extends State<SOSMapCrossPlatformPage> {
  final List<Marker> _markers = [];

  @override
  void initState() {
    super.initState();
    _listenToSOSAlerts();
  }

  void _listenToSOSAlerts() {
    FirebaseFirestore.instance.collection('sos_alerts').snapshots().listen((snapshot) {
      final markers = snapshot.docs.map((doc) {
        final data = doc.data();
        final lat = data['latitude'] as double?;
        final lng = data['longitude'] as double?;
        final timestamp = data['timestamp'] as Timestamp?;

        if (lat != null && lng != null) {
          return Marker(
            point: LatLng(lat, lng),
            width: 40.0,
            height: 40.0,
            child: GestureDetector(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('SOS Alert'),
                    content: Text(
                      timestamp != null ? 'Sent at: ${timestamp.toDate()}' : 'No timestamp',
                    ),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Close'),
                      ),
                    ],
                  ),
                );
              },
              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
            ),
          );
        }
        return null;
      }).whereType<Marker>().toList();

      setState(() {
        _markers.clear();
        _markers.addAll(markers);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live SOS Map"),
        backgroundColor: const Color(0xFF7A3E9D),
        centerTitle: true,
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _markers.isNotEmpty ? _markers.first.point : LatLng(0, 0),
          initialZoom: 13,
        ),
        children: [
          TileLayer(
            urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
            userAgentPackageName: 'com.example.gbv_app',
          ),
          MarkerLayer(
            markers: _markers,
          ),
        ],
      ),
    );
  }
}
        

