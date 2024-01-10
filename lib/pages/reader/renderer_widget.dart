import 'dart:io';

import 'package:cayread/book_structures.dart';
import 'package:cayread/file_structure/file_provider.dart';
import 'package:cayread/injection/injection.dart';
import 'package:cayread/logging/logger.dart';
import 'package:cayread/pages/reader/book_ui_orchestrator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class EpubRendererWidget extends StatefulWidget {
  final BookUIOrchestrator bookOrchestrator;
  final Book book;

  const EpubRendererWidget({
    super.key,
    required this.bookOrchestrator,
    required this.book,
  });

  @override
  State<EpubRendererWidget> createState() => _EpubRendererWidgetState();
}

class _EpubRendererWidgetState extends State<EpubRendererWidget> {
  // Dependencies
  final Logger log = Logger.forType(_EpubRendererWidgetState);
  final FileProvider fileProvider = serviceLocator();

  InAppWebViewController? _inAppWebViewController;
  late final Future<Uri> urlFuture;

  @override
  void initState() {
    super.initState();
    urlFuture = fileProvider
        .getBookEntrypointFile(
          widget.book.uuid,
          widget.book.type,
        )
        .then((File file) => file.uri);
    widget.bookOrchestrator.dispatchStateAction(
      BookUIOrchestratorStateAction.setTitle,
      widget.book.title,
    );
    widget.bookOrchestrator.dispatchStateAction(
      BookUIOrchestratorStateAction.setPageCount,
      widget.book.length,
    );
    widget.bookOrchestrator.dispatchStateAction(
      BookUIOrchestratorStateAction.updateLocationNumber,
      widget.book.current,
    );
  }

  void onCreated(InAppWebViewController controller) {
    _inAppWebViewController = controller;
    widget.bookOrchestrator.registerListener(BookUIOrchestratorAction.leftPage, leftPage);
    widget.bookOrchestrator.registerListener(BookUIOrchestratorAction.rightPage, rightPage);
  }

  Future<void> leftPage() async {
    dynamic answer = await _inAppWebViewController?.evaluateJavascript(source: leftPageJavascript);
    _finishPageTurn(answer);
  }

  Future<void> rightPage() async {
    dynamic answer = await _inAppWebViewController?.evaluateJavascript(source: rightPageJavascript);
    _finishPageTurn(answer);
  }

  void _finishPageTurn(dynamic answer) {
    assert(answer is int || (answer is double && (answer == answer.roundToDouble())),
        "Returned location number is not integer-like");
    int location = (answer is int) ? answer : answer.toInt();

    switch (location) {
      case -1:
        log.info("Reached left boundary");
      case -2:
        log.info("Reached right boundary");
      default:
        log.info("Moved to location $location");
        widget.bookOrchestrator.dispatchStateAction(BookUIOrchestratorStateAction.updateLocationNumber, location);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: urlFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: Text("Loading..."));
        }
        Uri url = snapshot.data!;
        return SafeArea(
          child: InAppWebView(
            initialUrlRequest: URLRequest(url: url),
            onWebViewCreated: onCreated,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    widget.bookOrchestrator.deregisterListener(BookUIOrchestratorAction.leftPage, leftPage);
    widget.bookOrchestrator.deregisterListener(BookUIOrchestratorAction.rightPage, rightPage);
    super.dispose();
  }

  static const rightPageJavascript = "window.ereader.page.incrementBy(1)";
  static const leftPageJavascript = "window.ereader.page.incrementBy(-1)";
}
