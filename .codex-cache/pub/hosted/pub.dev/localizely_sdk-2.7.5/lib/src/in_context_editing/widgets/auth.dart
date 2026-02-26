import 'package:flutter/material.dart';

class Auth extends StatefulWidget {
  final void Function(String) onSubmit;

  Auth({super.key, required this.onSubmit});

  @override
  State<Auth> createState() => _AuthState();
}

class _AuthState extends State<Auth> {
  final _tokenController = TextEditingController();

  void _handleConnectClick() {
    widget.onSubmit(_tokenController.text);
  }

  @override
  void dispose() {
    _tokenController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      margin: EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Text(
              'Enter the token from Localizely',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Container(
            margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Token',
              ),
              controller: _tokenController,
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 20),
            child: ElevatedButton(
              child: Text('Connect'),
              onPressed: _handleConnectClick,
            ),
          ),
        ],
      ),
    );
  }
}
