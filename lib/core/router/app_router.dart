// lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hooshino_flutter/presentation/screens/home/home_screen.dart';
import 'package:hooshino_flutter/presentation/screens/webview/webview_screen.dart';

class AppRouter {
  static const String homeRoute = '/';
  static const String webviewRoute = '/webview';

  static final GoRouter router = GoRouter(
    initialLocation: homeRoute,
    debugLogDiagnostics: true, // در حالت توسعه برای مشاهده لاگ‌ها مفید است
    routes: <RouteBase>[
      GoRoute(
        path: homeRoute,
        name: homeRoute, // نام مسیر برای ناوبری با نام
        builder: (BuildContext context, GoRouterState state) {
          return const HomeScreen();
        },
      ),
      GoRoute(
        path: webviewRoute,
        name: webviewRoute,
        builder: (BuildContext context, GoRouterState state) {
          // اگر پارامتری برای URL داشتیم، می‌توانستیم از state.extra یا state.pathParameters بگیریم
          return const WebViewScreenContainer(); // از یک Container برای BlocProvider استفاده می‌کنیم
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold( // صفحه خطای پیش‌فرض برای مسیرهای نامعتبر
      appBar: AppBar(title: const Text('خطا')),
      body: Center(
        child: Text('صفحه مورد نظر یافت نشد: ${state.error?.message}'),
      ),
    ),
  );
}