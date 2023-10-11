import 'dart:io';

import 'package:flutter/material.dart';

class ModalBottomSheetHeader {
  final Text title;
  final Text? subtitle;

  /// One of [image] and [icon] must be set
  /// [image] will be chosen over [icon]
  final File? image;
  final Icon? icon;

  ModalBottomSheetHeader({
    required this.title,
    this.subtitle,
    this.image,
    this.icon,
  }) : assert(image != null || icon != null);
}

class ModalBottomSheetAction {
  final Icon icon;
  final Text text;
  final void Function() onPressed;
  final bool isDestructiveAction;

  ModalBottomSheetAction({
    required this.icon,
    required this.text,
    required this.onPressed,
    this.isDestructiveAction = false,
  });
}
