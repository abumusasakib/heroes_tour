import 'package:flutter/material.dart';

class ApiSettingsScreen extends StatefulWidget {
  final String currentUrl;
  const ApiSettingsScreen({super.key, required this.currentUrl});

  @override
  ApiSettingsScreenState createState() => ApiSettingsScreenState();
}

class ApiSettingsScreenState extends State<ApiSettingsScreen> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentUrl);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("API Settings")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _controller,
              decoration: const InputDecoration(labelText: "API Base URL"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, _controller.text);
              },
              child: const Text("Save"),
            )
          ],
        ),
      ),
    );
  }
}