import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Needed for exiting the app

class CamouflagePage extends StatelessWidget {
  const CamouflagePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This widget is the core of the security.
    // It hijacks the phone's "back" button.
    return WillPopScope(
      onWillPop: () async {
        // Instead of going back, this command exits the app completely.
        SystemNavigator.pop();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Weather Forecast'),
          backgroundColor: Colors.blueAccent,
          automaticallyImplyLeading: false, // Hides the back arrow
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wb_sunny_rounded,
                size: 100,
                color: Colors.orange,
              ),
              SizedBox(height: 20),
              Text(
                'Nairobi',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              Text(
                '24°C - Sunny',
                style: TextStyle(fontSize: 20),
              ),
              Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  'Forecast: Clear skies for the next 48 hours.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}