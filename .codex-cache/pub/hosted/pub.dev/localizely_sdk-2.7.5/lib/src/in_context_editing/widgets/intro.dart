import 'package:flutter/material.dart';

class Intro extends StatelessWidget {
  final VoidCallback onSkip;
  final VoidCallback onProceed;

  Intro({super.key, required this.onSkip, required this.onProceed});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      margin: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Align(
            alignment: Alignment.topRight,
            child: IconButton(
              icon: Icon(Icons.close),
              iconSize: 20,
              color: Colors.black54,
              onPressed: onSkip,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Image(
              image: AssetImage(
                'packages/localizely_sdk/assets/images/localizely-logo.png',
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              'In-Context Editing',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              'Enter the token from Localizely and start translating the texts in the app',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 50),
            child: ElevatedButton(
              child: Text('Enter token'),
              onPressed: onProceed,
            ),
          ),
        ],
      ),
    );
  }
}
