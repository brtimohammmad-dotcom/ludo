import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';
import 'package:ludo/services/app-localization/language_provider.dart';
import 'package:ludo/services/audio_service.dart';

class SettingsAlert extends ConsumerWidget {
  const SettingsAlert({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double base = (screenWidth * 0.85).clamp(280.0, 450.0);

    final isEnglish = ref.watch(languageProvider).languageCode == 'en';
    final bool isSoundOn = !ref.watch(audioServiceProvider);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
        child: Container(
          width: base,
          padding: EdgeInsets.all(base * 0.06),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(base * 0.06),
            border: Border.all(
              color: Colors.amber.withValues(alpha: 0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // عنوان دیالوگ
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.settings_rounded,
                    color: Colors.amberAccent,
                    size: base * 0.07,
                  ),
                  SizedBox(width: base * 0.025),
                  Text(
                    context.tr('Settings'),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: base * 0.055,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              SizedBox(height: base * 0.06),

              // سوییچ ۱: تغییر زبان
              _buildSettingTile(
                base: base,
                icon: Icons.language_rounded,
                title: context.tr('Language'),
                subtitle: isEnglish ? 'English' : 'فارسی',
                child: _buildCustomToggle(
                  base: base,
                  value: isEnglish,
                  leftText: 'FA',
                  rightText: 'EN',
                  onChanged: (val) {
                    HapticFeedback.lightImpact();
                    ref.read(languageProvider.notifier).toggleLanguage();
                  },
                ),
              ),
              SizedBox(height: base * 0.035),

              // سوییچ ۲: صدا
              _buildSettingTile(
                base: base,
                icon: isSoundOn
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                title: context.tr('Sound Effects'),
                subtitle: isSoundOn ? context.tr('On') : context.tr('Off'),
                child: _buildCustomToggle(
                  base: base,
                  value: isSoundOn,
                  activeColor: const Color(0xFF10B981),
                  onChanged: (val) {
                    HapticFeedback.lightImpact();
                    ref.read(audioServiceProvider.notifier).toggleMute();
                  },
                ),
              ),
              SizedBox(height: base * 0.06),

              // دکمه تایید
              GestureDetector(
                onTap: () => Navigator.of(context).pop(),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: base * 0.035),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.amber.shade600, Colors.orange.shade700],
                    ),
                    borderRadius: BorderRadius.circular(base * 0.03),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      context.tr('OK'),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: base * 0.04,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required double base,
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: base * 0.04,
        vertical: base * 0.03,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A).withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(base * 0.04),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(base * 0.025),
            decoration: BoxDecoration(
              color: Colors.amber.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.amberAccent, size: base * 0.05),
          ),
          SizedBox(width: base * 0.03),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: base * 0.038,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: base * 0.005),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.white54,
                    fontSize: base * 0.03,
                  ),
                ),
              ],
            ),
          ),
          child,
        ],
      ),
    );
  }

  // 🛠️ ویجت اصلاح‌شده سوییچ با هایلایت شناور کپسولی
  Widget _buildCustomToggle({
    required double base,
    required bool value,
    required ValueChanged<bool> onChanged,
    Color? activeColor,
    String? leftText,
    String? rightText,
  }) {
    final double toggleWidth = base * 0.22;
    final double toggleHeight = base * 0.085;

    final bool isSoundToggle = activeColor != null;
    final Color defaultActiveBg = const Color(0xFFF59E0B); // طلایی مدرن

    return Directionality(
      textDirection: TextDirection.ltr,
      child: GestureDetector(
        onTap: () => onChanged(!value),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
          width: toggleWidth,
          height: toggleHeight,
          padding: EdgeInsets.all(base * 0.006),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(toggleHeight / 2),
            color: const Color(0xFF0F172A),
            border: Border.all(
              color: isSoundToggle && value
                  ? activeColor.withValues(alpha: 0.6)
                  : Colors.amberAccent.withValues(alpha: 0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.4),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              // 1️⃣ دکمه/کپسول هایلایت متحرک (پس‌زمینه گزینه فعال)
              AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                alignment:
                value ? Alignment.centerRight : Alignment.centerLeft,
                child: FractionallySizedBox(
                  widthFactor: 0.5,
                  heightFactor: 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(toggleHeight / 2),
                      gradient: LinearGradient(
                        colors: isSoundToggle
                            ? (value
                            ? [activeColor, activeColor.withValues(alpha: 0.8)]
                            : [
                          Colors.white.withValues(alpha: 0.15),
                          Colors.white.withValues(alpha: 0.05)
                        ])
                            : [
                          defaultActiveBg,
                          defaultActiveBg.withValues(alpha: 0.85),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isSoundToggle && value
                              ? activeColor
                              : defaultActiveBg)
                              .withValues(alpha: 0.4),
                          blurRadius: 6,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // 2️⃣ متون/آیکون‌های لایه رو (برای اینکه کپسول بیاد زیرشون و کاملاً خوانا بشن)
              Row(
                children: [
                  // سمت چپ (FA یا آیکون قطع صدا)
                  Expanded(
                    child: Center(
                      child: leftText != null
                          ? AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          color: !value
                              ? const Color(0xFF0F172A) // مشکی سرمه‌ای شیک روی کپسول طلایی
                              : Colors.white.withValues(alpha: 0.4),
                          fontSize: base * 0.028,
                          fontWeight: FontWeight.w900,
                        ),
                        child: Text(leftText),
                      )
                          : Icon(
                        Icons.close_rounded,
                        size: base * 0.035,
                        color: !value
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                  // سمت راست (EN یا آیکون وصل صدا)
                  Expanded(
                    child: Center(
                      child: rightText != null
                          ? AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          color: value
                              ? const Color(0xFF0F172A) // مشکی سرمه‌ای شیک روی کپسول طلایی
                              : Colors.white.withValues(alpha: 0.4),
                          fontSize: base * 0.028,
                          fontWeight: FontWeight.w900,
                        ),
                        child: Text(rightText),
                      )
                          : Icon(
                        Icons.check_rounded,
                        size: base * 0.035,
                        color: value
                            ? Colors.white
                            : Colors.white.withValues(alpha: 0.3),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}