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
          gradient: const LinearGradient(
            colors: [Color(0xFF4A2A18), Color(0xFF2A160C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          shape: BoxShape.circle,
          border: Border.all(
            color: const Color(0xFFD4AF37).withValues(alpha: 0.8),
            width: 1.5,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black38,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Icon(
          Icons.settings,
          color: Color(0xFFD4AF37),
          size: 18,
        ),
      ),
    );
  }
}