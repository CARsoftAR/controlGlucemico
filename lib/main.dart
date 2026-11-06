import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'core/notifications/notification_service.dart';
import 'core/theme/theme.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/doctors/presentation/providers/doctor_provider.dart';
import 'features/measurements/presentation/providers/glucose_provider.dart';
import 'features/profile/presentation/providers/profile_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización de FFI para SQLite en Windows y Linux Desktop
  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Inicialización del servicio de notificaciones y zonas horarias
  await NotificationService.instance.init();

  // Configuración de la barra de estado del sistema para estética Light Glassmorphism
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFFF0F4F8),
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => GlucoseProvider()..loadMeasurements(),
        ),
        ChangeNotifierProvider(
          create: (_) => DoctorProvider()..loadDoctors(),
        ),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider()..loadProfile(),
        ),
      ],
      child: const GlucoseControlApp(),
    ),
  );
}

/// Punto de entrada principal de la aplicación de Control Glucémico
class GlucoseControlApp extends StatelessWidget {
  final Widget? home;
  const GlucoseControlApp({super.key, this.home});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control Glucémico',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.pureDark,
      home: home ?? const DashboardScreen(),
    );
  }
}
