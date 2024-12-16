import 'package:flutter/material.dart';

class AnalysisPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Analysis'),
      ),
      body: Center(
        child: Text(
          'Analysis Page',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
