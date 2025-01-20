import 'package:flutter/material.dart';

class languagePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Language'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Text(
            'Select Your Language',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          _buildLanguageOption(context, 'English'),
          _buildLanguageOption(context, 'Spanish'),
          _buildLanguageOption(context, 'French'),
          _buildLanguageOption(context, 'German'),
          _buildLanguageOption(context, 'Chinese'),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, String language) {
    return ListTile(
      leading: Icon(Icons.language, color: Colors.blue),
      title: Text(language),
      onTap: () {
        // Handle language selection here
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$language selected')),
        );
      },
    );
  }
}
