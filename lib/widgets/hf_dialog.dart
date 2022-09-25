import 'package:flutter/cupertino.dart';

void showAlertDialog(BuildContext context, String dialogText, onPressedPositive,
    positiveText, onPressedNegative, negativeText) {
  showCupertinoModalPopup<void>(
    context: context,
    builder: (BuildContext context) => CupertinoAlertDialog(
      title: const Text('Alert'),
      content: Text(dialogText),
      actions: [
        CupertinoDialogAction(
          isDefaultAction: true,
          onPressed: onPressedPositive,
          child: Text(positiveText),
        ),
        CupertinoDialogAction(
          isDestructiveAction: true,
          onPressed: onPressedNegative,
          child: Text(negativeText),
        ),
      ],
    ),
  );
}
