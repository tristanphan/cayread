import 'package:cayread/book_structures.dart';
import 'package:cayread/pages/reader/book_ui_orchestrator.dart';
import 'package:cayread/pages/reader/controller_widget.dart';
import 'package:cayread/pages/reader/menu_widget.dart';
import 'package:cayread/pages/reader/renderer_widget.dart';
import 'package:flutter/material.dart';

class ReaderPage extends StatefulWidget {
  final Book book;

  const ReaderPage({super.key, required this.book});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  final BookUIOrchestrator _bookOrchestrator = BookUIOrchestrator();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        body: Stack(
          children: [
            EpubRendererWidget(bookOrchestrator: _bookOrchestrator, book: widget.book),
            ControllerWidget(bookOrchestrator: _bookOrchestrator),
            MenuWidget(bookOrchestrator: _bookOrchestrator),
          ],
        ),
      ),
    );
  }
}
