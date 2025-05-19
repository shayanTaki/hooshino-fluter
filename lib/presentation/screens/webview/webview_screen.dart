// lib/presentation/screens/webview/webview_screen.dart
import 'dart:async';
import 'dart:io'; // برای Platform.isAndroid و Platform.isIOS

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // برای SystemChrome
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // پکیج اصلی وب‌ویو
import 'package:go_router/go_router.dart'; // برای مسیریابی

import 'package:hooshino_flutter/core/constants/app_constants.dart'; // ثابت‌های برنامه
import 'package:hooshino_flutter/presentation/blocs/webview_bloc/webview_bloc.dart'; // Bloc وب‌ویو
import 'package:hooshino_flutter/presentation/widgets/loading_widget.dart'; // ویجت بارگذاری

// یک ویجت نگهدارنده برای فراهم کردن Bloc
class WebViewScreenContainer extends StatelessWidget {
  const WebViewScreenContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => WebViewBloc()..add(const LoadWebView(AppConstants.websiteUrl)),
      child: const WebViewScreen(),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  InAppWebViewController? _webViewController;
  final GlobalKey webViewKey = GlobalKey();
  PullToRefreshController? _pullToRefreshController;
  StreamSubscription<WebViewState>? _blocSubscription;

  // --- تلاش برای یک User-Agent استاندارد و عمومی‌تر برای WebView اندروید ---
  // این User-Agent عمومی‌تر است و ممکن است توسط گوگل بهتر پذیرفته شود.
  // این رشته‌ها اغلب در بحث‌های مربوط به مشکلات disallowed_useragent پیشنهاد می‌شوند.
  final String _standardWebViewUserAgent = Platform.isAndroid
      ? 'Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/91.0.4472.120 Mobile Safari/537.36'
      // برای iOS، معمولاً User-Agent پیش‌فرض WebView به اندازه کافی خوب است.
      // اما اگر نیاز بود، می‌توانید یک User-Agent سافاری موبایل را اینجا قرار دهید.
      : 'Mozilla/5.0 (iPhone; CPU iPhone OS 15_0 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/15.0 Mobile/15E148 Safari/604.1';
  // ---------------------------------------------------------------------------

  InAppWebViewSettings get _getInitialSettings => InAppWebViewSettings(
        // تنظیمات کپی شده از کد اندروید نیتیو:
        javaScriptEnabled: true,
        domStorageEnabled: true,
        databaseEnabled: true, // <<<--- اطمینان از فعال بودن
        allowFileAccess: true,
        allowContentAccess: true,
        mediaPlaybackRequiresUserGesture: false, // توجه: این می‌تواند برای ویدیوهای autoplay مشکل‌ساز باشد
        loadWithOverviewMode: true,
        useWideViewPort: true,
        supportZoom: true,
        builtInZoomControls: true,
        displayZoomControls: false,
        cacheMode: CacheMode.LOAD_DEFAULT,

        // تنظیم User-Agent
        userAgent: _standardWebViewUserAgent,

        // تنظیمات کوکی و محتوای ترکیبی
        thirdPartyCookiesEnabled: true,
        mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW, // برای اندروید

        // تنظیمات دیگر
        useShouldOverrideUrlLoading: true,
        allowsInlineMediaPlayback: true, // برای iOS
      );

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _pullToRefreshController ??= PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Theme.of(context).primaryColor,
      ),
      onRefresh: () async {
        if (_webViewController == null) return;
        if (Platform.isAndroid) {
          await _webViewController?.reload();
        } else if (Platform.isIOS) {
          final currentUrl = await _webViewController?.getUrl();
          if (currentUrl != null) {
            await _webViewController?.loadUrl(urlRequest: URLRequest(url: currentUrl));
          }
        }
      },
    );

    _blocSubscription ??= context.read<WebViewBloc>().stream.listen((state) {
        _updateSystemUI(state.showSystemUi);
      });
    _updateSystemUI(context.read<WebViewBloc>().state.showSystemUi);
  }

  void _updateSystemUI(bool show) {
    if (!mounted) return;
    if (show) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    }
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _blocSubscription?.cancel();
    _pullToRefreshController?.dispose();
    _webViewController = null;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final webViewBloc = context.watch<WebViewBloc>();

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop || !mounted) return;
        final router = GoRouter.of(context);
        final bloc = context.read<WebViewBloc>();
        final webViewCtrl = bloc.webViewController;

        bool canGoBack = false;
        if (webViewCtrl != null) {
          canGoBack = await webViewCtrl.canGoBack();
        }

        if (!mounted) return;

        if (canGoBack) {
          bloc.add(WebViewGoBack());
        } else {
          bloc.add(const WebViewToggleSystemUi(true));
          if (router.canPop()) {
             router.pop();
          }
        }
      },
      child: Scaffold(
        body: BlocConsumer<WebViewBloc, WebViewState>(
          listener: (context, state) {
            _updateSystemUI(state.showSystemUi);
            if (state.status == WebViewStatus.error && state.errorMessage != null) {
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: Colors.redAccent,
                  duration: const Duration(seconds: 5),
                ),
              );
            }
          },
          builder: (context, state) {
            if (state.status == WebViewStatus.initial && state.currentUrl.isEmpty) {
              return const LoadingWidget();
            }

            return SafeArea(
              top: state.showSystemUi,
              bottom: state.showSystemUi,
              child: Stack(
                children: [
                  Opacity(
                    opacity: state.status == WebViewStatus.error ? 0.0 : 1.0,
                    child: InAppWebView(
                      key: webViewKey,
                      initialUrlRequest: (state.currentUrl.isNotEmpty && _webViewController == null)
                          ? URLRequest(url: WebUri(state.currentUrl))
                          : null,
                      initialSettings: _getInitialSettings,
                      pullToRefreshController: _pullToRefreshController,
                      onWebViewCreated: (controller) async {
                        _webViewController = controller;
                        webViewBloc.setWebViewController(controller);

                        // پاک کردن کوکی‌ها و کش برای شروع تمیز (بسیار مهم برای تست ورود)
                        await CookieManager.instance().deleteAllCookies();
                        await InAppWebViewController.clearAllCache(includeDiskFiles: true);
                        // کوکی‌ها به طور پیش‌فرض در flutter_inappwebview پذیرفته می‌شوند.
                        // thirdPartyCookiesEnabled در _getInitialSettings=true است.

                        if (state.currentUrl.isNotEmpty) {
                            final loadedUrl = await controller.getUrl();
                            if (loadedUrl?.toString() != state.currentUrl) {
                                controller.loadUrl(urlRequest: URLRequest(url: WebUri(state.currentUrl)));
                            }
                        }
                      },
                      onLoadStart: (controller, url) {
                        debugPrint("WebView Load Start: $url"); // لاگ کردن URL
                        if (url != null) {
                          webViewBloc.add(WebViewPageStarted(url.toString()));
                        }
                      },
                      onLoadStop: (controller, url) async {
                        _pullToRefreshController?.endRefreshing();
                        debugPrint("WebView Load Stop: $url");
                        if (url != null) {
                          // در کد اندروید شما، CookieManager.flush() اینجا بود.
                          // در flutter_inappwebview، مدیریت کوکی معمولاً خودکار است.
                          // اگر مشکلات session ادامه داشت، باید بررسی شود آیا نیاز به set/get دستی کوکی‌ها است.
                          webViewBloc.add(WebViewPageFinished(url.toString()));
                        }
                      },
                      onReceivedError: (controller, request, error) {
                        _pullToRefreshController?.endRefreshing();
                        debugPrint("WebView Error: ${error.description} for URL: ${request.url}");
                        webViewBloc.add(WebViewErrorOccurred(
                          url: request.url.toString(),
                          errorCode: error.type.hashCode,
                          errorDescription: error.description,
                        ));
                      },
                      onProgressChanged: (controller, progress) {
                        webViewBloc.add(WebViewProgressChanged(progress));
                        if (progress == 100) {
                           _pullToRefreshController?.endRefreshing();
                        }
                      },
                      shouldOverrideUrlLoading: (controller, navigationAction) async {
                        final uri = navigationAction.request.url;
                        debugPrint("WebView ShouldOverrideUrlLoading: $uri");
                        // منطق خاصی برای override کردن URL ها در اینجا (اگر نیاز باشد)
                        return NavigationActionPolicy.ALLOW;
                      },
                      onConsoleMessage: (controller, consoleMessage) {
                        final levelString = consoleMessage.messageLevel.toString().split('.').last;
                        debugPrint("WebView JS Console [$levelString]: ${consoleMessage.message}");
                      },
                      onPermissionRequest: (controller, request) async {
                         debugPrint("WebView Permission request for: ${request.resources.join(", ")} from ${request.origin}");
                         return PermissionResponse(resources: request.resources, action: PermissionResponseAction.GRANT);
                      },
                      // برای اندروید، این می‌تواند به دیباگ کمک کند
                      // androidOnSafeBrowsingHit: (controller, url, threatType) async {
                      //   debugPrint("Safe Browsing Hit: $url, Threat: $threatType");
                      //   return SafeBrowsingResponse(report: true, action: SafeBrowsingResponseAction.BACK);
                      // },
                      // androidOnRenderProcessGone: (controller, detail) async {
                      //   debugPrint("Render process gone: ${detail.didCrash()}");
                      //   _webViewController?.reload(); // یا هر اقدام دیگری
                      // },
                    ),
                  ),
                  if (state.status == WebViewStatus.loading && state.progress < 100 && state.status != WebViewStatus.error)
                    LoadingWidget(progress: state.progress / 100.0),

                  if (state.status == WebViewStatus.error)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.error_outline, color: Colors.red.shade700, size: 50),
                                const SizedBox(height: 16),
                                Text(
                                  "خطا در بارگذاری صفحه",
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: Colors.red.shade700),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  state.errorMessage ?? "یک خطای ناشناخته رخ داده است.",
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton.icon(
                                  icon: const Icon(Icons.refresh),
                                  label: const Text("تلاش مجدد"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context).colorScheme.errorContainer,
                                    foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                                  ),
                                  onPressed: () {
                                    // قبل از تلاش مجدد، کش و کوکی‌ها را پاک می‌کنیم
                                    // _webViewController?.clearCache(); // منسوخ شده
                                    InAppWebViewController.clearAllCache(includeDiskFiles: true);
                                    CookieManager.instance().deleteAllCookies();
                                    webViewBloc.add(LoadWebView(state.currentUrl.isNotEmpty ? state.currentUrl : AppConstants.websiteUrl));
                                  },
                                ),
                                const SizedBox(height: 10),
                                TextButton(
                                  child: const Text("بازگشت به خانه"),
                                  onPressed: () {
                                     if (!mounted) return;
                                     final router = GoRouter.of(context);
                                     webViewBloc.add(const WebViewToggleSystemUi(true));
                                     if (router.canPop()) {
                                        router.pop();
                                     }
                                  },
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}