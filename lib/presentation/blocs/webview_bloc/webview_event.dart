

// lib/presentation/blocs/webview_bloc/webview_event.dart
part of 'webview_bloc.dart'; // برای اینکه بتواند به Bloc دسترسی داشته باشد



abstract class WebViewEvent extends Equatable {
  const WebViewEvent();

  @override
  List<Object?> get props => [];
}

// رویداد برای شروع بارگذاری WebView
class LoadWebView extends WebViewEvent {
  final String url;
  const LoadWebView(this.url);

  @override
  List<Object?> get props => [url];
}

// رویداد برای زمانی که بارگذاری صفحه شروع می‌شود
class WebViewPageStarted extends WebViewEvent {
  final String url;
  const WebViewPageStarted(this.url);

  @override
  List<Object?> get props => [url];
}

// رویداد برای زمانی که بارگذاری صفحه تمام می‌شود
class WebViewPageFinished extends WebViewEvent {
  final String url;
  const WebViewPageFinished(this.url);

  @override
  List<Object?> get props => [url];
}

// رویداد برای زمانی که خطایی در بارگذاری رخ می‌دهد
class WebViewErrorOccurred extends WebViewEvent {
  final String url;
  final int errorCode;
  final String errorDescription;

  const WebViewErrorOccurred({
    required this.url,
    required this.errorCode,
    required this.errorDescription,
  });

  @override
  List<Object?> get props => [url, errorCode, errorDescription];
}

// رویداد برای به‌روزرسانی پیشرفت بارگذاری
class WebViewProgressChanged extends WebViewEvent {
  final int progress;
  const WebViewProgressChanged(this.progress);

  @override
  List<Object?> get props => [progress];
}

// رویداد برای درخواست رفتن به صفحه قبل در WebView
class WebViewGoBack extends WebViewEvent {}

// رویداد برای کنترل نمایش/عدم نمایش نوار ابزار سیستم
class WebViewToggleSystemUi extends WebViewEvent {
  final bool show;
  const WebViewToggleSystemUi(this.show);

  @override
  List<Object?> get props => [show];
}
