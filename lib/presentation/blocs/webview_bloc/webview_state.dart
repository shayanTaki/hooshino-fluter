// lib/presentation/blocs/webview_bloc/webview_state.dart
part of 'webview_bloc.dart';

enum WebViewStatus { initial, loading, loaded, error, navigatingBack }

class WebViewState extends Equatable {
  final WebViewStatus status;
  final String currentUrl; // URL فعلی که در حال بارگذاری یا بارگذاری شده است
  final int progress; // درصد پیشرفت بارگذاری (0-100)
  final String? errorMessage; // پیام خطا در صورت وقوع
  final bool canGoBack; // آیا WebView می‌تواند به صفحه قبل برود
  final bool showSystemUi; // برای کنترل نمایش نوارهای سیستم

  const WebViewState({
    this.status = WebViewStatus.initial,
    this.currentUrl = '',
    this.progress = 0,
    this.errorMessage,
    this.canGoBack = false,
    this.showSystemUi = true, // به طور پیش‌فرض نوارهای سیستم نمایش داده می‌شوند
  });

  WebViewState copyWith({
    WebViewStatus? status,
    String? currentUrl,
    int? progress,
    String? errorMessage,
    bool? canGoBack,
    bool? clearErrorMessage, // برای پاک کردن پیام خطا
    bool? showSystemUi,
  }) {
    return WebViewState(
      status: status ?? this.status,
      currentUrl: currentUrl ?? this.currentUrl,
      progress: progress ?? this.progress,
      errorMessage: clearErrorMessage == true ? null : errorMessage ?? this.errorMessage,
      canGoBack: canGoBack ?? this.canGoBack,
      showSystemUi: showSystemUi ?? this.showSystemUi,
    );
  }

  @override
  List<Object?> get props => [status, currentUrl, progress, errorMessage, canGoBack, showSystemUi];
}