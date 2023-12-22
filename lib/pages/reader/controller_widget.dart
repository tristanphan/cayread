import 'package:cayread/pages/reader/book_ui_orchestrator.dart';
import 'package:flutter/material.dart';

class ControllerWidget extends StatefulWidget {
  final BookUIOrchestrator bookOrchestrator;

  const ControllerWidget({
    super.key,
    required this.bookOrchestrator,
  });

  @override
  State<ControllerWidget> createState() => _ControllerWidgetState();
}

class _ControllerWidgetState extends State<ControllerWidget> {
  Widget get leftPageHitBox => Positioned(
        left: 0,
        top: 0,
        bottom: 0,
        child: GestureDetector(
          onTap: () => widget.bookOrchestrator.dispatchAction(BookUIOrchestratorAction.leftPage),
          behavior: HitTestBehavior.translucent,
          child: IgnorePointer(child: Container(width: 80)),
        ),
      );

  Widget get rightPageHitBox => Positioned(
        right: 0,
        top: 0,
        bottom: 0,
        child: GestureDetector(
          onTap: () => widget.bookOrchestrator.dispatchAction(BookUIOrchestratorAction.rightPage),
          behavior: HitTestBehavior.translucent,
          child: IgnorePointer(child: Container(width: 80)),
        ),
      );

  Widget createExitButton(context) => Positioned(
        top: 12,
        right: 12,
        child: SafeArea(
          child: Material(
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
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        leftPageHitBox,
        rightPageHitBox,
        // TODO disable page switching gesture detectors during a text selection
        createExitButton(context),
      ],
    );
  }
}
