String appButtons(String projectName) => '''
import 'package:flutter/material.dart';
import 'package:$projectName/config/themes/app_colors.dart'; 

enum ButtonState { idle, loading, success, error }

class AppButton extends StatelessWidget {
  final String label;
  final ButtonState state;
  final VoidCallback onPressed;
  final bool isOutlined;
  final IconData? icon;
  final bool fullWidth;

  const AppButton({
    super.key,
    required this.label,
    required this.onPressed,
    required this.state,
    this.isOutlined = false,
    this.icon,
    this.fullWidth = true,
  });

  Widget _buildChild() {
    switch (state) {
      case ButtonState.loading:
        return const SizedBox(
          height: 20,
          width: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        );
      case ButtonState.success:
        return const Icon(Icons.check_circle, color: Colors.white, size: 20);
      case ButtonState.error:
        return const Icon(Icons.error, color: Colors.white, size: 20);
      case ButtonState.idle:
      default:
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) Icon(icon, size: 18),
            if (icon != null) const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = isOutlined
        ? OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          )
        : ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          );

    final isDisabled = state == ButtonState.loading ||
        state == ButtonState.success ||
        state == ButtonState.error;

    final button = isOutlined
        ? OutlinedButton(
            onPressed: isDisabled ? null : onPressed,
            style: style,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildChild(),
            ),
          )
        : ElevatedButton(
            onPressed: isDisabled ? null : onPressed,
            style: style,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: _buildChild(),
            ),
          );

    return fullWidth ? SizedBox(width: double.infinity, child: button) : button;
  }
}


''';
