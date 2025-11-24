import 'package:flutter/material.dart';

class DisclaimerPage extends StatefulWidget {
  const DisclaimerPage({super.key});

  @override
  State<DisclaimerPage> createState() => _DisclaimerPageState();
}

class _DisclaimerPageState extends State<DisclaimerPage> {
  bool _isAgreed = false;

  void _onAgree() {
    if (_isAgreed) {
      // Pop the page and return 'true' to signal agreement
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F2FB), // Your app's background color
      appBar: AppBar(
        backgroundColor: const Color(0xFF7A3E9D), // Your app's primary color
        title: const Text("Important Disclaimer"),
        centerTitle: true,
        // Automatically adds a back button, which is fine
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Main Content Area (Scrollable)
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Center(
                        child: Icon(
                          Icons.shield_rounded,
                          size: 60,
                          color: Color(0xFF7A3E9D),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Please Read Carefully",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF5B2C6F),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      _buildDisclaimerPoint(
                        Icons.report,
                        "This is a Reporting Tool:",
                        "SautiSafe is designed to help you report incidents anonymously. The data is collected to help support services and authorities understand the scope of GBV.",
                      ),
                      const SizedBox(height: 16),
                      _buildDisclaimerPoint(
                        Icons.emergency_outlined,
                        "Not an Emergency Service:",
                        "This app is NOT a replacement for emergency services. If you are in immediate danger, please contact your local police or emergency hotline.",
                      ),
                      const SizedBox(height: 16),
                      _buildDisclaimerPoint(
                        Icons.visibility_off,
                        "Anonymity & Data:",
                        "We do not require personal information to submit a report. However, no digital platform is 100% anonymous. Please be mindful of the details you share in reports and evidence.",
                      ),
                    ],
                  ),
                ),
              ),

              // 2. Agreement Checkbox
              const SizedBox(height: 24),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _isAgreed,
                    onChanged: (bool? value) {
                      setState(() {
                        _isAgreed = value ?? false;
                      });
                    },
                    activeColor: const Color(0xFF7A3E9D),
                  ),
                  const Expanded(
                    child: Text(
                      "I have read and understood the disclaimer.",
                      style: TextStyle(
                        fontSize: 16,
                        color: Color(0xFF5B2C6F),
                      ),
                    ),
                  ),
                ],
              ),

              // 3. Continue Button
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isAgreed ? _onAgree : null, // Button is disabled until checkbox is ticked
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8E44AD),
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  disabledBackgroundColor: Colors.grey[300],
                ),
                child: const Text(
                  "Agree & Continue",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for styling the disclaimer points
  Widget _buildDisclaimerPoint(IconData icon, String title, String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF7A3E9D), size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF5B2C6F),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          text,
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
