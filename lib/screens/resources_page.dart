import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourcesPage extends StatelessWidget {
  const ResourcesPage({super.key});

  void _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> resources = [
      {
        "title": "National GBV Hotline (1195)",
        "desc": "Free 24-hour helpline for survivors of gender-based violence in Kenya.",
      },
      {
        "title": "LVCT Health Kenya",
        "desc": "Provides counseling, HIV testing, and GBV support services.",
        "url": "https://lvcthealth.org/",
      },
      {
        "title": "UN Women Kenya",
        "desc": "Resources and programs supporting women's safety and empowerment.",
        "url": "https://kenya.unwomen.org/",
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Resources & Support"),
        backgroundColor: const Color(0xFF7A3E9D),
      ),
      backgroundColor: const Color(0xFFF6F2FB),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: resources.length,
        itemBuilder: (context, index) {
          final resource = resources[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              title: Text(
                resource["title"]!,
                style: const TextStyle(
                  color: Color(0xFF7A3E9D),
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: Text(resource["desc"]!),
              trailing: resource.containsKey("url")
                  ? IconButton(
                      icon: const Icon(Icons.open_in_new, color: Color(0xFF7A3E9D)),
                      onPressed: () => _launchURL(resource["url"]!),
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
