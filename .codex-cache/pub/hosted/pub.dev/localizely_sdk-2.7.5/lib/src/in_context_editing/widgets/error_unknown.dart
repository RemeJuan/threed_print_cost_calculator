import 'package:flutter/material.dart';

class ErrorUnknown extends StatelessWidget {
  final VoidCallback onBack;

  ErrorUnknown({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      margin: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 36, color: Colors.red),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              'Unknown error occurred',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: TextButton(child: Text('Go back'), onPressed: onBack),
          ),
        ],
      ),
    );
  }
}
