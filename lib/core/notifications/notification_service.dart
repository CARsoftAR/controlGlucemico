import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Callback de segundo plano para procesar respuestas a notificaciones con pantalla apagada
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) async {
  WidgetsFlutterBinding.ensureInitialized();
  debugPrint("GLUCOSE_NOTIFICATION_BACKGROUND: ${notificationResponse.payload}");
}

/// Servicio de Notificaciones y Alarmas basado en la arquitectura de WerkFlow
/// Configurado con Full Screen Intent, canales nativos de máxima prioridad y sincronización exacta de TimeZone
class NotificationService {
  NotificationService._internal();

  /// Singleton oficial del servicio
  static final NotificationService instance = NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  // IDs de los canales de alta prioridad
  static const String criticalChannelId = 'glucose_critical_channel_v2';
  static const String remindersChannelId = 'glucose_reminders_channel_v2';

  /// Inicialización completa: timezones locales dinámicos, permisos y canales de alta prioridad
  Future<void> init() async {
    if (_isInitialized) return;

    try {
      // 1. Inicializar base de datos de zonas horarias
      tz.initializeTimeZones();

      // 2. Obtener y configurar la zona horaria real del dispositivo (Mecánica clave de WerkFlow)
      try {
        final timezoneInfo = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(timezoneInfo.toString()));
      } catch (e) {
        debugPrint("TIMEZONE_LOCAL_SYNC_ERROR: $e");
      }

      // 3. Configuración para Android
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // 4. Configuración para iOS / Darwin
      const DarwinInitializationSettings iosSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const InitializationSettings initSettings = InitializationSettings(
        android: androidSettings,
        iOS: iosSettings,
      );

      // 5. Inicializar plugin con handler en segundo plano
      await _notificationsPlugin.initialize(
        settings: initSettings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          // Foreground response
        },
        onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
      );

      // 6. Creación explícita de canales nativos de notificación con nivel MAX e Intent de pantalla completa
      final androidPlatform = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidPlatform != null) {
        // Canal de Alerta Crítica (Hiperglucemia)
        const AndroidNotificationChannel criticalChannel = AndroidNotificationChannel(
          criticalChannelId,
          'Alertas Críticas de Glucosa',
          description: 'Alarmas urgentes e inmediatas cuando la glucosa supera el umbral de seguridad',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        );

        // Canal de Recordatorios Diarios
        const AndroidNotificationChannel remindersChannel = AndroidNotificationChannel(
          remindersChannelId,
          'Recordatorios Diarios de Glucosa',
          description: 'Alarmas automáticas para recordar tomas de glucemia diarias',
          importance: Importance.max,
          playSound: true,
          enableVibration: true,
          enableLights: true,
        );

        await androidPlatform.createNotificationChannel(criticalChannel);
        await androidPlatform.createNotificationChannel(remindersChannel);

        // Solicitar permisos en tiempo de ejecución para Android 13+ (POST_NOTIFICATIONS y SCHEDULE_EXACT_ALARM)
        await androidPlatform.requestNotificationsPermission();
        await androidPlatform.requestExactAlarmsPermission();
      }

      _isInitialized = true;
    } catch (e) {
      debugPrint("NOTIFICATION_INIT_ERROR: $e");
    }
  }

  /// Dispara una notificación inmediata de emergencia médica con Full Screen Intent
  Future<void> showHighGlucoseAlert(double value) async {
    if (!_isInitialized) await init();

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      criticalChannelId,
      'Alertas Críticas de Glucosa',
      channelDescription: 'Notificaciones inmediatas cuando la glucosa supera el umbral crítico',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true, // Despierta el sistema y enciende la pantalla
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      color: Color(0xFFFF007F), // Magenta de alerta
      enableVibration: true,
      playSound: true,
      ticker: '¡Alerta de Glucosa Crítica!',
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
        title: '⚠️ ALERTA: Nivel de glucosa crítico detectado',
        body: 'Tu registro actual es de ${value.toStringAsFixed(0)} mg/dL. Supera el rango seguro (>180 mg/dL). Revisa tu protocolo de insulina.',
        notificationDetails: details,
      );
    } catch (e) {
      debugPrint("SHOW_ALERT_ERROR: $e");
    }
  }

  /// Programa alarmas recurrentes diarias para recordar mediciones (despierta al dispositivo con exactAllowWhileIdle)
  Future<void> scheduleDailyReminder(
    int hour,
    int minute,
    String mealContext, {
    int id = 1,
  }) async {
    if (!_isInitialized) await init();

    final tz.TZDateTime scheduledDate = _nextInstanceOfTime(hour, minute);

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      remindersChannelId,
      'Recordatorios Diarios de Glucosa',
      channelDescription: 'Alarmas automáticas para recordar tomas de glucemia',
      importance: Importance.max,
      priority: Priority.max,
      fullScreenIntent: true, // Crucial para despertar la pantalla en modo Doze o bloqueada
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      color: Color(0xFF00F0FF), // Cyan primario
      playSound: true,
      enableVibration: true,
      ticker: 'Recordatorio de Glucosa',
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
    } catch (e) {
      debugPrint("SCHEDULE_REMINDER_ERROR: $e");
    }
  }

  /// Calcula la próxima ocurrencia horaria en base a la zona horaria local real sincronizada
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }

  /// Cancela un recordatorio específico por ID
  Future<void> cancelReminder(int id) async {
    try {
      await _notificationsPlugin.cancel(id: id);
    } catch (e) {
      debugPrint("CANCEL_REMINDER_ERROR: $e");
    }
  }

  /// Cancela todos los recordatorios activos
  Future<void> cancelAll() async {
    try {
      await _notificationsPlugin.cancelAll();
    } catch (e) {
      debugPrint("CANCEL_ALL_ERROR: $e");
    }
  }
}
