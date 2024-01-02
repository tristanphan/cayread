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
  static const double pageTurnHitBoxWidth = 80;

  Widget createLeftPageHitBox() => Positioned(
        left: 0,
        top: 0,
        bottom: 0,
        child: GestureDetector(
          onTap: () => widget.bookOrchestrator.dispatchAction(BookUIOrchestratorAction.leftPage),
          behavior: HitTestBehavior.translucent,
          child: IgnorePointer(child: Container(width: pageTurnHitBoxWidth)),
        ),
      );

  Widget createRightPageHitBox() => Positioned(
        right: 0,
        top: 0,
        bottom: 0,
        child: GestureDetector(
          onTap: () => widget.bookOrchestrator.dispatchAction(BookUIOrchestratorAction.rightPage),
          behavior: HitTestBehavior.translucent,
          child: IgnorePointer(child: Container(width: pageTurnHitBoxWidth)),
        ),
      );

  Widget createToggleMenuHitBox() => Positioned(
        right: pageTurnHitBoxWidth,
        left: pageTurnHitBoxWidth,
        top: 0,
        bottom: 0,
        child: GestureDetector(
          onTap: () => widget.bookOrchestrator.dispatchStateAction(BookUIOrchestratorStateAction.setMenuVisibility,
              !widget.bookOrchestrator.retrieveState(BookUIOrchestratorStateAction.setMenuVisibility)),
          onLongPress: null,
          behavior: HitTestBehavior.translucent,
          child: IgnorePointer(child: Container(width: pageTurnHitBoxWidth)),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        createLeftPageHitBox(),
        createRightPageHitBox(),
        createToggleMenuHitBox(),
        // TODO disable page switching gesture detectors during a text selection
      ],
    );
  }
}
