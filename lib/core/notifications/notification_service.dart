import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Servicio aislado de Notificaciones Locales y Alarmas Recurrentes
class NotificationService {
  NotificationService._internal();

  /// Singleton oficial del servicio
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  /// Inicialización para Android e iOS con zonas horarias
  Future<void> init() async {
    if (_isInitialized) return;

    // 1. Inicialización requerida de zonas horarias
    tz.initializeTimeZones();

    // 2. Configuración Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. Configuración iOS / Darwin
    const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    try {
      await _notificationsPlugin.initialize(settings: initSettings);

      // Solicitar permisos en tiempo de ejecución para Android 13+
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlatform != null) {
        await androidPlatform.requestNotificationsPermission();
        await androidPlatform.requestExactAlarmsPermission();
      }
    } catch (_) {
      // Manejo tolerante a fallos en entornos de pruebas
    }

    _isInitialized = true;
  }

  /// Dispara una notificación inmediata de emergencia médica
  Future<void> showHighGlucoseAlert(double value) async {
    if (!_isInitialized) await init();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'high_glucose_critical_channel',
      'Alertas Críticas de Glucosa',
      channelDescription: 'Notificaciones inmediatas cuando la glucosa supera el umbral crítico',
      importance: Importance.max,
      priority: Priority.high,
      color: Color(0xFFFF007F), // Magenta de alerta
      enableVibration: true,
      playSound: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.critical,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.show(
        id: 999,
        title: 'Alerta: Nivel de glucosa crítico detectado',
        body: 'Tu registro actual es de ${value.toStringAsFixed(0)} mg/dL. Supera el rango seguro (>180 mg/dL). Revisa tu protocolo de insulina.',
        notificationDetails: details,
      );
    } catch (_) {}
  }

  /// Programa alarmas recurrentes diarias para recordar mediciones
  Future<void> scheduleDailyReminder(
    int hour,
    int minute,
    String mealContext, {
    int id = 1,
  }) async {
    if (!_isInitialized) await init();

    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'daily_glucose_reminders_channel',
      'Recordatorios Diarios de Glucosa',
      channelDescription: 'Alarmas automáticas para recordar tomas de glucemia',
      importance: Importance.high,
      priority: Priority.high,
      color: Color(0xFF00F0FF), // Cyan primario
      playSound: true,
      enableVibration: true,
    );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    try {
      await _notificationsPlugin.zonedSchedule(
        id: id,
        title: 'Hora de tu control de glucosa',
        body: 'Momento programado: $mealContext. Recuerda realizar tu medición.',
        scheduledDate: scheduledDate,
        notificationDetails: details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {}
  }

  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Cancela un recordatorio específico
  Future<void> cancelReminder(int id) async {
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (_) {}
  }

  /// Cancela todos los recordatorios activos
  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (_) {}
  }
}
