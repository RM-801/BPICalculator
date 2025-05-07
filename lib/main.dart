import 'package:flutter/material.dart';
import 'pages/song_search_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BPI Calculator',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: SongSearchPage(),
    );
  }
}