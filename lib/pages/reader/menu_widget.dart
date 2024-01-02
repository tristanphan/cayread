import 'package:cayread/pages/reader/book_ui_orchestrator.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class MenuWidget extends StatefulWidget {
  final BookUIOrchestrator bookOrchestrator;

  const MenuWidget({
    super.key,
    required this.bookOrchestrator,
  });

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  static const double textMargin = 25;
  static const double buttonMargin = 20;
  static const int transitionDuration = 300;

  Widget createExitButton(context) => Material(
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: Navigator.of(context).pop,
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.grey.withOpacity(0.25),
            ),
            child: Icon(
              Icons.close_rounded,
              size: 24,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ),
      );

  Widget createMoreButton(context) => Material(
        child: InkWell(
          customBorder: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          onTap: () {
            // TODO show more options
          },
          child: Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: Colors.grey.withOpacity(0.25),
            ),
            child: Icon(
              Icons.expand_less,
              size: 24,
              color: Colors.black.withOpacity(0.5),
            ),
          ),
        ),
      );

  Widget createPositionText(int current, int total, {required bool extended}) {
    if (!extended) {
      return IgnorePointer(
        key: ValueKey(extended),
        child: Text("${(current / total * 100).toStringAsFixed(0)}%"),
      );
    }

    return Row(
      key: ValueKey(extended),
      children: [
        const Padding(padding: EdgeInsets.only(left: 24)), // padding (8) + icon size (16)
        IgnorePointer(child: Text("$current / $total")),
        const Padding(padding: EdgeInsets.only(left: 8)),
        Opacity(
          opacity: 0.5,
          child: InkWell(
            child: const Icon(
              Icons.info,
              size: 16,
            ),
            onTap: () {
              // TODO show information about the location system
            },
          ),
        ),
      ],
    );
  }

  Widget createTitleText(String title) => IgnorePointer(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(padding: EdgeInsets.only(left: 56)),
            Flexible(
              child: Text(
                title,
                overflow: TextOverflow.ellipsis,
                softWrap: false,
              ),
            ),
            const Padding(padding: EdgeInsets.only(left: 56)),
          ],
        ),
      );

  @override
  void initState() {
    super.initState();
    for (BookUIOrchestratorStateAction action in [
      BookUIOrchestratorStateAction.updateLocationNumber,
      BookUIOrchestratorStateAction.setPageCount,
      BookUIOrchestratorStateAction.setTitle,
      BookUIOrchestratorStateAction.setMenuVisibility,
    ]) {
      widget.bookOrchestrator.registerStateListener(action, (_) => setState(() => {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    final int current = widget.bookOrchestrator.retrieveState(BookUIOrchestratorStateAction.updateLocationNumber);
    final int total = widget.bookOrchestrator.retrieveState(BookUIOrchestratorStateAction.setPageCount);
    final String title = widget.bookOrchestrator.retrieveState(BookUIOrchestratorStateAction.setTitle);

    final bool menuVisible = widget.bookOrchestrator.retrieveState(BookUIOrchestratorStateAction.setMenuVisibility);

    final TextStyle textStyle = GoogleFonts.montserrat(
      fontWeight: FontWeight.w600,
      color: Colors.black.withOpacity(0.4),
    );

    return DefaultTextStyle(
      style: textStyle,
      child: SafeArea(
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned(
              top: textMargin,
              left: 0,
              right: 0,
              child: createTitleText(title),
            ),
            Positioned(
              bottom: textMargin,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: transitionDuration),
                child: createPositionText(current, total, extended: menuVisible),
              ),
            ),
            Positioned(
              top: buttonMargin,
              right: buttonMargin,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: transitionDuration),
                child: menuVisible ? createExitButton(context) : null,
              ),
            ),
            Positioned(
              bottom: buttonMargin,
              right: buttonMargin,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: transitionDuration),
                child: menuVisible ? createMoreButton(context) : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
