import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isOutlined;
  final Color backgroundColor;
  final Color textColor;
  final double height;
  final double borderRadius;

  const CustomButton.primary({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppTheme.vantaWhite,
    this.textColor = AppTheme.vantaTextDark,
    this.height = 56.0,
    this.borderRadius = 28.0,
  }) : isOutlined = false;

  const CustomButton.blue({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppTheme.vantaBlue,
    this.textColor = AppTheme.vantaTextLight,
    this.height = 56.0,
    this.borderRadius = 28.0,
  }) : isOutlined = false;

  const CustomButton.outlined({
    super.key,
    required this.text,
    required this.onPressed,
    this.backgroundColor = AppTheme.vantaWhite,
    this.textColor = AppTheme.vantaWhite,
    this.height = 56.0,
    this.borderRadius = 28.0,
  }) : isOutlined = true;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: isOutlined
          ? OutlinedButton(
              onPressed: onPressed,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: backgroundColor, width: 1.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                ),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: backgroundColor,
                foregroundColor: textColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(borderRadius),
                ),
              ),
              child: Text(
                text,
                style: TextStyle(
                  color: textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.3,
                ),
              ),
            ),
    );
  }
}
