import 'package:flutter/material.dart';

class ReconnectingFailedAlertAlert extends StatelessWidget {
  const ReconnectingFailedAlertAlert({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final maxAvailableWidth = screenWidth; // 90% عرض صفحه
    final maxAvailableHeight = screenHeight;
    final boardSize = (maxAvailableWidth < maxAvailableHeight
        ? maxAvailableWidth
        : maxAvailableHeight * 0.86);
    return Column(
      children: [
        Icon(
          Icons.signal_wifi_connected_no_internet_4_outlined,
          weight: boardSize * 0.3,
        ),
        Text("زمان اتصال به پایان رسید"),
        ElevatedButton(onPressed: (){}, child: Icon(Icons.home))
      ],
    );
  }
}
