import 'package:flutter/material.dart';
import '../utils/theme.dart';

class CheckboxTile extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String text;
  final TextStyle? textStyle;

  const CheckboxTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.text,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.primary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Text(
              text,
              style: textStyle ?? Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}