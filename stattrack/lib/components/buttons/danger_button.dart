import 'package:flutter/material.dart';
import 'package:stattrack/styles/font_styles.dart';
import 'package:stattrack/styles/palette.dart';

class DangerButton extends StatefulWidget {
  const DangerButton({
    Key? key,
    required this.onPressed,
    required this.label,
  }) : super(key: key);

  final VoidCallback? onPressed;
  final String label;

  @override
  State<DangerButton> createState() => _DangerButtonState();
}

class _DangerButtonState extends State<DangerButton> {
  Color textColor = Colors.red[600]!;
  Color backgroundColor = Palette.main[0]!;

  void _setHoverState(bool hover) {
    if (hover) {
      setState(() {
        textColor = Palette.main[0]!;
        backgroundColor = Colors.red[600]!;
      });
    } else {
      setState(() {
        textColor = Colors.red[600]!;
        backgroundColor = Palette.main[0]!;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: widget.onPressed,
      onHover: (hover) => _setHoverState(hover),
      style: ElevatedButton.styleFrom(
        elevation: 0,
        backgroundColor: backgroundColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.all(16.0),
        side: BorderSide(
          width: 1.0,
          color: Colors.red[600]!,
        ),
      ),
      child: Text(
        widget.label,
        style: const TextStyle(
          fontWeight: FontStyles.fw600,
          fontSize: FontStyles.fs400,
        ),
      ),
    );
  }
}