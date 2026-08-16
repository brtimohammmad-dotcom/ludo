import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ludo/services/app-localization/app_localizations_service.dart';

class WelcomeGiftSuccessDialog extends ConsumerStatefulWidget {
  final double boardSize;
  final String configUrl; // لینک کانفیگ vless/vmess/etc.

  const WelcomeGiftSuccessDialog({
    super.key,
    required this.boardSize,
    required this.configUrl,
  });

  @override
  ConsumerState<WelcomeGiftSuccessDialog> createState() =>
      _WelcomeGiftSuccessDialogState();
}

class _WelcomeGiftSuccessDialogState
    extends ConsumerState<WelcomeGiftSuccessDialog> {
  late ConfettiController _confettiController;
  bool _isCopied = false;

  @override
  void initState() {
    super.initState();
    // شروع انیمیشن کاغذ پران
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: widget.configUrl));
    setState(() {
      _isCopied = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isCopied = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final double base = widget.boardSize * 0.85;

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Dialog(
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
              border: Border.all(
                color: const Color(0xFFFFD700),
                width: 1.8,
              ),
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
                // آیکون تبریک / هدیه باز شده
                Container(
                  padding: EdgeInsets.all(base * 0.04),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1E120B),
                    border: Border.all(
                      color: const Color(0xFFFFD700),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    Icons.card_giftcard_rounded,
                    size: base * 0.12,
                    color: const Color(0xFFFFD700),
                  ),
                ),
                SizedBox(height: base * 0.03),

                // عنوان موفقیت
                Text(
                  context.tr('Congratulations!'),
                  style: TextStyle(
                    color: const Color(0xFFFFF8DC),
                    fontSize: base * 0.055,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                SizedBox(height: base * 0.015),

                // توضیحات
                Text(
                  context.tr('Your 1GB free config is ready!'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: const Color(0xFFD4AF37),
                    fontSize: base * 0.032,
                  ),
                ),
                SizedBox(height: base * 0.04),

                // باکس نمایش کپی کانفیگ
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(
                    horizontal: base * 0.03,
                    vertical: base * 0.025,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E120B),
                    borderRadius: BorderRadius.circular(base * 0.03),
                    border: Border.all(
                      color: const Color(0xFF5C3613),
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.configUrl,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: base * 0.03,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ),
                      SizedBox(width: base * 0.02),
                      GestureDetector(
                        onTap: _copyToClipboard,
                        child: Container(
                          padding: EdgeInsets.all(base * 0.02),
                          decoration: BoxDecoration(
                            color: const Color(0xFF381F12),
                            borderRadius: BorderRadius.circular(base * 0.02),
                            border: Border.all(
                              color: const Color(0xFFFFD700),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            _isCopied ? Icons.check : Icons.copy_rounded,
                            color: const Color(0xFFFFD700),
                            size: base * 0.045,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: base * 0.05),

                // دکمه کپی کانفیگ (اصلی)
                GestureDetector(
                  onTap: _copyToClipboard,
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: base * 0.035),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFF8B5A2B),
                          Color(0xFF6F431A),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(base * 0.035),
                      border: Border.all(
                        color: const Color(0xFFFFD700),
                        width: 1.5,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _isCopied
                            ? context.tr('Copied!')
                            : context.tr('Copy Config'),
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

                // دکمه بستن
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    context.tr('Close'),
                    style: TextStyle(
                      color: const Color(0xFFD4AF37),
                      fontSize: base * 0.035,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // افکت Confetti در بالای دیالوگ
        ConfettiWidget(
          confettiController: _confettiController,
          blastDirectionality: BlastDirectionality.explosive,
          shouldLoop: false,
          colors: const [
            Color(0xFFFFD700),
            Color(0xFFFFF8DC),
            Color(0xFF8B5A2B),
            Colors.orange,
            Colors.amber,
          ],
        ),
      ],
    );
  }
}