import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/controller/game-controller/game_controller.dart';
import 'package:ludo/controller/global-loading/global_loading_provider.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';

class WelcomeGiftDialog extends ConsumerWidget {
  final double boardSize;

  const WelcomeGiftDialog({super.key, required this.boardSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLoading = ref.watch(globalLoadingProvider).contains('welcome_gift');
    final double base = boardSize * 0.85;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: base,
        padding: EdgeInsets.all(base * 0.05),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF4A2A18), Color(0xFF2A160C)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFFFFD700), width: 1.8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black54,
              blurRadius: 15,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // آیکون شبکه / اینترنت
            Container(
              padding: EdgeInsets.all(base * 0.04),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E120B),
                border: Border.all(color: const Color(0xFFFFD700), width: 1.5),
              ),
              child: Icon(
                Icons.wifi_tethering_rounded,
                size: base * 0.12,
                color: const Color(0xFFFFD700),
              ),
            ),
            SizedBox(height: base * 0.03),

            // عنوان
            Text(
              context.tr('Welcome Gift!'),
              style: TextStyle(
                color: const Color(0xFFFFF8DC),
                fontSize: base * 0.055,
                fontWeight: FontWeight.w900,
              ),
            ),
            SizedBox(height: base * 0.02),

            // کارت نشان‌دهنده مقدار ۱ گیگ
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: base * 0.04,
                horizontal: base * 0.03,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFF1E120B),
                borderRadius: BorderRadius.circular(base * 0.03),
                border: Border.all(color: const Color(0xFF5C3613), width: 1.2),
              ),
              child: Column(
                children: [
                  Text(
                    '1 GB',
                    style: TextStyle(
                      color: const Color(0xFFFFD700),
                      fontSize: base * 0.08,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: base * 0.01),
                  Text(
                    context.tr('Free High-Speed Traffic'),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: const Color(0xFFD4AF37),
                      fontSize: base * 0.032,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: base * 0.03),

            // توضیحات کوتاه
            Text(
              context.tr('Enjoy 1GB free VPN traffic as a welcome gift.'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: const Color(0xFFFFF8DC).withValues(alpha: 0.8),
                fontSize: base * 0.03,
              ),
            ),
            SizedBox(height: base * 0.05),

            // دکمه دریافت هدیه
            GestureDetector(
              onTap: !isLoading
                  ? () {
                      ref
                          .read(globalLoadingProvider.notifier)
                          .start('welcome_gift');

                      ref
                          .read(gameControllerProvider.notifier)
                          .claimWelcomeGift();
                    }
                  : null,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: base * 0.035),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5A2B), Color(0xFF6F431A)],
                  ),
                  borderRadius: BorderRadius.circular(base * 0.035),
                  border: Border.all(
                    color: const Color(0xFFFFD700),
                    width: 1.5,
                  ),
                ),
                child: Center(
                  child: isLoading
                      ? SizedBox(
                          width: base * 0.05,
                          height: base * 0.05,
                          child: const CircularProgressIndicator(
                            color: Color(0xFFFFD700),
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          context.tr('Claim 1GB Free'),
                          style: TextStyle(
                            color: const Color(0xFFFFF8DC),
                            fontSize: base * 0.04,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ),
            SizedBox(height: base * 0.02),

            // دکمه انصراف یا بستن
            TextButton(
              onPressed: isLoading ? null : () => Navigator.pop(context),
              child: Text(
                context.tr('Maybe Later'),
                style: TextStyle(
                  color: !isLoading
                      ? const Color(0xFFD4AF37)
                      : const Color(0xFFD4AF37).withValues(alpha: 0.2),
                  fontSize: base * 0.032,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
