import 'package:cayread/common_widgets/modal_bottom_sheet/modal_bottom_sheet_structures.dart';
import 'package:flutter/material.dart';

class ModalBottomSheet extends StatelessWidget {
  final ModalBottomSheetHeader header;
  final List<ModalBottomSheetAction> actions;

  const ModalBottomSheet({
    super.key,
    required this.header,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    List<Widget> widgets = [];
    widgets.add(_Header(header));
    widgets.addAll(actions.map((ModalBottomSheetAction action) => _ActionItem(action)));
    widgets.add(const Padding(padding: EdgeInsets.only(bottom: 16.0)));

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: widgets,
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final ModalBottomSheetHeader header;

  const _Header(this.header);

  @override
  Widget build(BuildContext context) {
    Color dividerColor = Theme.of(context).dividerColor;

    return InkWell(
      onTap: () {},
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(28.0),
        topRight: Radius.circular(28.0),
      ),
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: dividerColor, width: 0.25),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 16.0),
        child: Row(
          children: [
            const Padding(padding: EdgeInsets.only(right: 16.0)),
            _HeaderImageOrIcon(header: header),
            const Padding(padding: EdgeInsets.only(right: 12.0)),
            _HeaderText(header: header),
            IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 32),
            ),
            const Padding(padding: EdgeInsets.only(right: 8.0)),
          ],
        ),
      ),
    );
  }
}

class _HeaderImageOrIcon extends StatelessWidget {
  final ModalBottomSheetHeader header;

  const _HeaderImageOrIcon({required this.header});

  @override
  Widget build(BuildContext context) {
    // This should not be accessed (and therefore instantiated) until we know header.image is not null
    late Widget imageWidget = Image.file(
      header.image!,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => header.icon ?? const Icon(Icons.menu),
    );
    Widget chosenImageOrIcon = (header.image == null) ? header.icon! : imageWidget;

    return ClipRRect(
      borderRadius: BorderRadius.circular(8.0),
      child: SizedBox(
        width: 40,
        child: AspectRatio(
          aspectRatio: 10 / 16,
          child: chosenImageOrIcon,
        ),
      ),
    );
  }
}

class _HeaderText extends StatelessWidget {
  final ModalBottomSheetHeader header;

  const _HeaderText({required this.header});

  @override
  Widget build(BuildContext context) {
    TextTheme textTheme = Theme.of(context).textTheme;

    TextStyle? subtitleStyle = textTheme.bodyMedium?.copyWith(color: textTheme.bodyMedium?.color?.withOpacity(0.5));
    TextStyle? titleStyle = textTheme.bodyLarge?.copyWith(overflow: TextOverflow.ellipsis);

    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DefaultTextStyle.merge(
            style: titleStyle,
            maxLines: 1,
            child: header.title,
          ),
          if (header.subtitle != null)
            DefaultTextStyle.merge(
              style: subtitleStyle,
              child: header.subtitle!,
            ),
        ],
      ),
    );
  }
}

class _ActionItem extends StatelessWidget {
  final ModalBottomSheetAction action;

  const _ActionItem(this.action);

  @override
  Widget build(BuildContext context) {
    Color errorColor = Theme.of(context).colorScheme.error;
    TextTheme textTheme = Theme.of(context).textTheme;

    IconThemeData iconTheme = IconTheme.of(context).copyWith(
      color: action.isDestructiveAction ? errorColor : null,
    );
    TextStyle? labelStyle = textTheme.bodyLarge?.copyWith(
      color: action.isDestructiveAction ? errorColor : null,
    );

    return InkWell(
      onTap: action.onPressed,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconTheme.merge(
              data: iconTheme,
              child: action.icon,
            ),
            const Padding(padding: EdgeInsets.only(right: 16.0)),
            DefaultTextStyle.merge(
              style: labelStyle,
              child: action.text,
            ),
          ],
        ),
      ),
    );
  }
}
