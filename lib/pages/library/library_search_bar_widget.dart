import 'package:flutter/material.dart';

class LibrarySearchBarWidget extends StatefulWidget {
  const LibrarySearchBarWidget({super.key});

  @override
  State<LibrarySearchBarWidget> createState() => _LibrarySearchBarWidgetState();
}

class _LibrarySearchBarWidgetState extends State<LibrarySearchBarWidget> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 12.0),
      child: Card(
        elevation: 1.5,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: _cardRadius),
        child: const Text("Search Bar"),
      ),
    );
  }

  final BorderRadius _cardRadius = BorderRadius.circular(10);
}
