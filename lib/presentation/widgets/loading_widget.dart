// lib/presentation/widgets/loading_widget.dart
import 'package:flutter/material.dart';

class LoadingWidget extends StatelessWidget {
  final double? progress; // مقدار پیشرفت از 0.0 تا 1.0

  const LoadingWidget({super.key, this.progress});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CircularProgressIndicator(
            value: progress, // اگر null باشد، نامعین می‌شود
            strokeWidth: 6.0,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
          const SizedBox(height: 24.0),
          Text(
            "در حال بارگذاری...",
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w500),
          ),
          if (progress != null) ...[ // اگر پیشرفت مشخص است، نمایش بده
            const SizedBox(height: 8.0),
            Text(
              "${(progress! * 100).toInt()}%",
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ]
        ],
      ),
    );
  }
}