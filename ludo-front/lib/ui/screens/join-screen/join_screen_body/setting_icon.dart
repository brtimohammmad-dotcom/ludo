import 'package:flutter/material.dart';
import 'package:ludo/ui/utils/alerts/setting_alert.dart';
import 'package:ludo/ui/utils/alerts/show_animated_dialog.dart';

class SettingIcon extends StatelessWidget {
  const SettingIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        showAnimatedDialog(context: context, child: SettingsAlert());

      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 38,
        width: 38,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors:

            [
              const Color(0xFF1E293B),
              const Color(0xFF0F172A),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color:
            const Color(0xFF334155),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color:
              Colors.black26,
              blurRadius:  4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Icon(
          Icons.settings,
          color:  Colors.grey.shade400,
          size: 18,
        ),
      ),
    );
  }
}
