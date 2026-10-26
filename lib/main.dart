import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'core/notifications/notification_service.dart';
import 'core/theme/theme.dart';
import 'features/dashboard/dashboard_screen.dart';
import 'features/measurements/presentation/providers/glucose_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicialización del servicio de notificaciones y zonas horarias
  await NotificationService.instance.init();

  // Configuración de la barra de estado del sistema para estética Pure Dark
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.pureBlack,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    ChangeNotifierProvider(
      create: (_) => GlucoseProvider()..loadMeasurements(),
      child: const GlucoseControlApp(),
    ),
  );
}

/// Punto de entrada principal de la aplicación de Control Glucémico
class GlucoseControlApp extends StatelessWidget {
  const GlucoseControlApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Control Glucémico',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.pureDark,
      home: const DashboardScreen(),
    );
  }
}
