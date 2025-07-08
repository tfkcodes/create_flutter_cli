String themeConfig(String projectName) => '''

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:$projectName/config/themes/app_colors.dart';
class Themes {
  final lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.light(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      background: AppColors.background,
      onBackground: Colors.black,
      surface: AppColors.slightBlue,
      onSurface: Colors.black87,
      error: Colors.red,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.slightBlue,
    primaryColor: AppColors.primary,
    dividerColor: AppColors.slightGray,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      systemOverlayStyle:
          SystemUiOverlayStyle(statusBarBrightness: Brightness.light),
    ),
    shadowColor: Colors.black.withOpacity(0.1),
    textTheme: _buildTextTheme(Brightness.light),
    timePickerTheme: _customTimePickerTheme(Brightness.light),
  );

  final darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: const ColorScheme.dark(
      brightness: Brightness.dark,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.black,
      background: AppColors.darkBackground,
      onBackground: Colors.white,
      surface: AppColors.darkBackground,
      onSurface: Colors.white70,
      error: Colors.red,
      onError: Colors.black,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    canvasColor: AppColors.darkBackground,
    primaryColor: AppColors.primary,
    dividerColor: Colors.white12,
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.darkBackground,
      foregroundColor: Colors.white,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    shadowColor: AppColors.darkShade.withOpacity(0.1),
    textTheme: _buildTextTheme(Brightness.dark),
    timePickerTheme: _customTimePickerTheme(Brightness.dark),
  );

  static TextTheme _buildTextTheme(Brightness brightness) {
    final base = brightness == Brightness.light
        ? ThemeData.light().textTheme
        : ThemeData.dark().textTheme;

    return base.copyWith(
      bodyLarge: base.bodyLarge?.copyWith(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: brightness == Brightness.light ? Colors.black : Colors.white,
      ),
      bodyMedium: base.bodyMedium?.copyWith(
        fontSize: 18,
        color: brightness == Brightness.light ? Colors.black87 : Colors.white70,
      ),
      bodySmall: base.bodySmall?.copyWith(
        fontSize: 14,
        color: brightness == Brightness.light ? Colors.black87 : Colors.white70,
      ),
    );
  }

  static TimePickerThemeData _customTimePickerTheme(Brightness brightness) {
    final isLight = brightness == Brightness.light;

    return TimePickerThemeData(
      backgroundColor: isLight ? Colors.white : AppColors.darkBackground,
      hourMinuteTextColor: isLight ? Colors.black : Colors.white,
      hourMinuteColor: AppColors.secondary.withOpacity(0.6),
      hourMinuteTextStyle:
          const TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
      dialHandColor: AppColors.secondary.withOpacity(0.6),
      dialTextStyle: const TextStyle(fontSize: 14),
      dayPeriodColor: AppColors.primary.withOpacity(0.4),
      dayPeriodShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(2),
        side: const BorderSide(color: AppColors.primary, width: 0.5),
      ),
      dialBackgroundColor: isLight ? Colors.grey[200] : Colors.grey[850],
      dayPeriodBorderSide: const BorderSide(color: Colors.grey),
      dayPeriodTextColor: WidgetStateColor.resolveWith((states) =>
          states.contains(WidgetState.selected)
              ? Colors.white
              : (isLight ? Colors.black : Colors.white70)),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      timeSelectorSeparatorColor: WidgetStateProperty.resolveWith((states) {
        return states.contains(WidgetState.selected)
            ? AppColors.primary
            : Colors.grey;
      }),
    );
  }
}

''';
