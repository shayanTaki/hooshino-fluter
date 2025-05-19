// lib/presentation/blocs/webview_bloc/webview_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // برای استفاده از کنترلر وب‌ویو

part 'webview_event.dart';
part 'webview_state.dart';

class WebViewBloc extends Bloc<WebViewEvent, WebViewState> {
  InAppWebViewController? webViewController; // کنترلر برای تعامل با WebView

  WebViewBloc() : super(const WebViewState()) {
    on<LoadWebView>(_onLoadWebView);
    on<WebViewPageStarted>(_onWebViewPageStarted);
    on<WebViewPageFinished>(_onWebViewPageFinished);
    on<WebViewErrorOccurred>(_onWebViewErrorOccurred);
    on<WebViewProgressChanged>(_onWebViewProgressChanged);
    on<WebViewGoBack>(_onWebViewGoBack);
    on<WebViewToggleSystemUi>(_onWebViewToggleSystemUi);
  }

  void _onLoadWebView(LoadWebView event, Emitter<WebViewState> emit) {
    emit(state.copyWith(
      status: WebViewStatus.loading,
      currentUrl: event.url,
      progress: 0,
      clearErrorMessage: true,
      showSystemUi: false, // هنگام شروع بارگذاری، UI سیستم را مخفی کن
    ));
    // دستور بارگذاری URL واقعی در WebViewScreen انجام خواهد شد
    // چون به webViewController نیاز داریم که در آنجا ساخته می‌شود.
  }

  void _onWebViewPageStarted(WebViewPageStarted event, Emitter<WebViewState> emit) {
    emit(state.copyWith(
      status: WebViewStatus.loading,
      currentUrl: event.url,
      progress: 0, // یا مقدار اولیه پیشرفت اگر از WebView می‌آید
      clearErrorMessage: true,
      showSystemUi: false, // در حین بارگذاری صفحه هم مخفی بماند
    ));
  }

  void _onWebViewPageFinished(WebViewPageFinished event, Emitter<WebViewState> emit) async {
    final canGoBack = await webViewController?.canGoBack() ?? false;
    emit(state.copyWith(
      status: WebViewStatus.loaded,
      currentUrl: event.url,
      progress: 100,
      canGoBack: canGoBack,
      showSystemUi: false, // پس از بارگذاری کامل، همچنان مخفی بماند
    ));
  }

  void _onWebViewErrorOccurred(WebViewErrorOccurred event, Emitter<WebViewState> emit) {
    emit(state.copyWith(
      status: WebViewStatus.error,
      currentUrl: event.url,
      errorMessage: "خطا (${event.errorCode}): ${event.errorDescription}",
      showSystemUi: true, // در صورت خطا، UI سیستم را نمایش بده
    ));
  }

  void _onWebViewProgressChanged(WebViewProgressChanged event, Emitter<WebViewState> emit) {
    if (state.status == WebViewStatus.loading) {
      emit(state.copyWith(progress: event.progress));
    }
  }

  Future<void> _onWebViewGoBack(WebViewGoBack event, Emitter<WebViewState> emit) async {
    if (await webViewController?.canGoBack() ?? false) {
      emit(state.copyWith(status: WebViewStatus.navigatingBack));
      await webViewController?.goBack();
      // وضعیت canGoBack پس از onPageFinished به‌روزرسانی خواهد شد
    }
    // اگر نتواند به عقب برود، وضعیت فعلی را حفظ می‌کنیم.
    // خروج از برنامه در WebViewScreen مدیریت می‌شود.
  }

  void _onWebViewToggleSystemUi(WebViewToggleSystemUi event, Emitter<WebViewState> emit) {
    emit(state.copyWith(showSystemUi: event.show));
  }

  // متدی برای نگه‌داشتن رفرنس کنترلر
  void setWebViewController(InAppWebViewController controller) {
    webViewController = controller;
  }

  // برای بررسی وضعیت canGoBack پس از ناوبری‌ها
  Future<void> updateCanGoBack() async {
    if (webViewController != null) {
      final canGoBack = await webViewController!.canGoBack();
      if (state.canGoBack != canGoBack) {
         // یک رویداد جدید برای این کار اضافه می‌کنیم یا مستقیم emit می‌کنیم اگر منطق پیچیده‌ای ندارد
         // برای سادگی، اینجا مستقیماً emit نمی‌کنیم تا جریان رویدادها حفظ شود.
         // بهتر است یک رویداد مانند UpdateNavigationState اضافه شود.
         // فعلا، این در onPageFinished انجام می‌شود.
      }
    }
  }
}