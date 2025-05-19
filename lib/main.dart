// lib/main.dart
import 'dart:io'; // برای Platform.isAndroid

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart'; // اگر از BlocObserver استفاده می‌کنید
import 'package:hooshino_flutter/core/router/app_router.dart';
// ignore: unused_import
import 'package:flutter_inappwebview/flutter_inappwebview.dart'; // برای تنظیمات WebView اندروید

// (اختیاری) یک BlocObserver برای مشاهده تمام تغییرات وضعیت و رویدادها
class AppBlocObserver extends BlocObserver {
  @override
  void onCreate(BlocBase bloc) {
    super.onCreate(bloc);
    debugPrint('Bloc_onCreate -- ${bloc.runtimeType}');
  }

  @override
  void onEvent(Bloc bloc, Object? event) {
    super.onEvent(bloc, event);
    debugPrint('Bloc_onEvent -- ${bloc.runtimeType}, Event: $event');
  }

  @override
  void onChange(BlocBase bloc, Change change) {
    super.onChange(bloc, change);
    debugPrint('Bloc_onChange -- ${bloc.runtimeType}, Change: $change');
  }

  @override
  void onTransition(Bloc bloc, Transition transition) {
    super.onTransition(bloc, transition);
    debugPrint('Bloc_onTransition -- ${bloc.runtimeType}, Transition: $transition');
  }

  @override
  void onError(BlocBase bloc, Object error, StackTrace stackTrace) {
    debugPrint('Bloc_onError -- ${bloc.runtimeType}, Error: $error');
    super.onError(bloc, error, stackTrace);
  }

  @override
  void onClose(BlocBase bloc) {
    super.onClose(bloc);
    debugPrint('Bloc_onClose -- ${bloc.runtimeType}');
  }
}


Future<void> main() async {
  // اطمینان از مقداردهی اولیه ویجت‌ها قبل از اجرای کد پلتفرم
  WidgetsFlutterBinding.ensureInitialized();

  // تنظیمات مربوط به WebView برای اندروید (معادل setWebContentsDebuggingEnabled)
  if (Platform.isAndroid) {
    // این خط باید قبل از اجرای اولین InAppWebView فراخوانی شود.
    // فعال کردن دیباگ WebView در اندروید (اگر در حالت دیباگ هستیم)
    // این کار به طور پیش‌فرض در حالت دیباگ برای InAppWebView فعال است.
    // برای اطمینان بیشتر یا کنترل دقیق‌تر:
    // await AndroidInAppWebViewController.setWebContentsDebuggingEnabled(true); // یا false برای غیرفعال کردن
  }

  // (اختیاری) استفاده از BlocObserver
  Bloc.observer = AppBlocObserver();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Hooshino Flutter',
      theme: ThemeData(
        primarySwatch: Colors.blue, // یا یک رنگ اصلی دیگر
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), // تم مدرن‌تر
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          elevation: 1, // سایه کم برای AppBar
          centerTitle: true,
        ),
        inputDecorationTheme: const InputDecorationTheme( // برای ظاهر بهتر TextFieldها
          border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8.0)),
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData( // برای ظاهر بهتر دکمه‌ها
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.0),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ),
      darkTheme: ThemeData.dark(useMaterial3: true).copyWith( // تم تیره (اختیاری)
         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
         appBarTheme: const AppBarTheme(
          elevation: 1,
          centerTitle: true,
        ),
      ),
      themeMode: ThemeMode.system, // استفاده از تم سیستم (روشن/تیره)
      debugShowCheckedModeBanner: false, // حذف بنر دیباگ
      routerConfig: AppRouter.router, // استفاده از GoRouter برای مسیریابی
    );
  }
}