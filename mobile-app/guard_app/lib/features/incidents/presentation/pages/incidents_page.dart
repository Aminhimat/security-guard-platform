import 'package:flutter/material.dart';

class IncidentsPage extends StatelessWidget {
  const IncidentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Incidents'),
        automaticallyImplyLeading: false,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.warning,
              size: 64,
              color: Colors.orange,
            ),
            SizedBox(height: 16),
            Text(
              'Incidents Module',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text('Coming soon...'),
          ],
        ),
      ),
    );
  }
}
