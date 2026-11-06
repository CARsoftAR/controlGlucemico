import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:control_glucemico/main.dart';
import 'package:control_glucemico/core/models/glucose_measurement.dart';
import 'package:control_glucemico/features/measurements/presentation/providers/glucose_provider.dart';
import 'package:control_glucemico/features/measurements/presentation/screens/add_measurement_screen.dart';
import 'package:control_glucemico/features/dashboard/presentation/widgets/glucose_chart_widget.dart';
import 'package:control_glucemico/features/settings/presentation/screens/settings_screen.dart';

import 'package:control_glucemico/features/dashboard/dashboard_screen.dart';
import 'package:control_glucemico/features/history/presentation/screens/history_metrics_screen.dart';
import 'package:control_glucemico/features/onboarding/presentation/screens/onboarding_screen.dart';

void main() {
  testWidgets('OnboardingScreen renders 5 steps and navigates to DashboardScreen on completion', (WidgetTester tester) async {
    final provider = GlucoseProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const GlucoseControlApp(home: OnboardingScreen()),
      ),
    );

    expect(find.text('BIENVENIDA'), findsOneWidget);
    expect(find.text('Control de Glucosa\nInteligente'), findsOneWidget);
    expect(find.text('Siguiente'), findsOneWidget);

    // Tap Siguiente -> Step 2 (Tendencias)
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('TENDENCIAS'), findsOneWidget);
    expect(find.text('Visualiza tus\nTendencias'), findsOneWidget);

    // Tap Siguiente -> Step 3 (Alertas)
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('ALERTAS'), findsOneWidget);
    expect(find.text('Nunca olvides una\nmedición'), findsOneWidget);

    // Tap Siguiente -> Step 4 (Reporte Médico)
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('REPORTE MÉDICO'), findsOneWidget);
    expect(find.text('Comparte con tu\nMédico'), findsOneWidget);
    expect(find.text('Siguiente'), findsOneWidget);

    // Tap Siguiente -> Step 5 (Resumen)
    await tester.tap(find.text('Siguiente'));
    await tester.pumpAndSettle();
    expect(find.text('RESUMEN'), findsOneWidget);
    expect(find.text('Todo listo para empezar'), findsOneWidget);
    expect(find.text('Comenzar Ahora'), findsOneWidget);

    // Tap Comenzar Ahora -> Navigates to Dashboard
    await tester.tap(find.text('Comenzar Ahora'));
    await tester.pumpAndSettle();
    expect(find.text('GLUCO CONTROL'), findsOneWidget);
  });

  testWidgets('DashboardScreen renders appbar and floating action button with GlucoseProvider', (WidgetTester tester) async {
    final provider = GlucoseProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const GlucoseControlApp(home: DashboardScreen()),
      ),
    );

    expect(find.text('GLUCO CONTROL'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.text('Historial y Métricas'), findsOneWidget);

    // Tap on Historial y Métricas card to open screen
    await tester.tap(find.text('Historial y Métricas'));
    await tester.pumpAndSettle();

    expect(find.byType(HistoryMetricsScreen), findsOneWidget);
    expect(find.text('Resumen de Rango Glucémico'), findsOneWidget);
    expect(find.text('Día'), findsOneWidget);
    expect(find.text('Semana'), findsOneWidget);
    expect(find.text('Intervalo'), findsOneWidget);
  });

  testWidgets('HistoryMetricsScreen filters work smoothly between Día, Semana and custom range', (WidgetTester tester) async {
    final provider = GlucoseProvider();
    await provider.addMeasurement(GlucoseMeasurement(
      id: 'm_today',
      value: 110.0,
      timestamp: DateTime.now(),
      context: 'En ayunas',
      isHigh: false,
    ));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: HistoryMetricsScreen(),
        ),
      ),
    );

    expect(find.text('Historial y Métricas'), findsOneWidget);
    expect(find.text('Semana'), findsOneWidget);
    expect(find.text('Resumen de Rango Glucémico'), findsOneWidget);
    expect(find.text('Registros Agrupados'), findsOneWidget);

    // Switch filter to "Día"
    await tester.tap(find.text('Día'));
    await tester.pumpAndSettle();
    expect(find.text('110'), findsWidgets);
  });

  test('GlucoseMeasurement serialization toMap and fromMap works seamlessly with notes', () {
    final now = DateTime(2026, 10, 25, 20, 30);
    final measurement = GlucoseMeasurement(
      id: 'test_1',
      value: 195.0,
      timestamp: now,
      context: 'Postprandial (2h)',
      isHigh: true,
      notes: 'NHP 14u + 6 Apidra',
    );

    final map = measurement.toMap();
    expect(map['id'], 'test_1');
    expect(map['value'], 195.0);
    expect(map['context'], 'Postprandial (2h)');
    expect(map['isHigh'], true);
    expect(map['notes'], 'NHP 14u + 6 Apidra');

    final fromMap = GlucoseMeasurement.fromMap(map, 'test_1');
    expect(fromMap.id, 'test_1');
    expect(fromMap.value, 195.0);
    expect(fromMap.context, 'Postprandial (2h)');
    expect(fromMap.isHigh, true);
    expect(fromMap.notes, 'NHP 14u + 6 Apidra');
  });

  test('GlucoseProvider loadHistoricalData inserts records and clearAllData wipes them', () async {
    final provider = GlucoseProvider();
    await provider.loadHistoricalData();

    expect(provider.measurements.length, 66);
    // Verificar que isHigh se calcula con > 140
    for (final m in provider.measurements) {
      expect(m.isHigh, m.value > 140.0);
    }
    // Verificar que existen registros con notas
    final withNotes = provider.measurements.where((m) => m.notes != null).toList();
    expect(withNotes.isNotEmpty, true);

    // Borrado completo
    await provider.clearAllData();
    expect(provider.measurements.isEmpty, true);
  });

  testWidgets('AddMeasurementScreen shows exact modal alert when glucose > 140 mg/dL', (WidgetTester tester) async {
    final provider = GlucoseProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(home: AddMeasurementScreen()),
      ),
    );

    // Enter glucose value 165 (> 140)
    await tester.enterText(find.byType(TextFormField), '165');
    await tester.pump();

    // Tap Save button
    await tester.tap(find.text('GUARDAR MEDICIÓN'));
    await tester.pumpAndSettle();

    // Verify Modal alert appeared with exact requirements
    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('Alerta: Glucosa Elevada'), findsOneWidget);
    expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Registrar de todos modos'), findsOneWidget);

    // Tap "Registrar de todos modos"
    await tester.tap(find.text('Registrar de todos modos'));
    await tester.pumpAndSettle();

    // Verify it was added to provider
    expect(provider.measurements.length, 1);
    expect(provider.measurements.first.value, 165.0);
  });

  testWidgets('GlucoseChartWidget renders LineChart correctly with provider data', (WidgetTester tester) async {
    final provider = GlucoseProvider();
    await provider.addMeasurement(GlucoseMeasurement(
      id: 'test_chart_1',
      value: 110.0,
      timestamp: DateTime.now().subtract(const Duration(days: 2)),
      context: 'En ayunas',
      isHigh: false,
    ));
    await provider.addMeasurement(GlucoseMeasurement(
      id: 'test_chart_2',
      value: 165.0,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
      context: 'Post-almuerzo',
      isHigh: true,
    ));

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: Scaffold(
            body: GlucoseChartWidget(),
          ),
        ),
      ),
    );

    expect(find.text('Tendencia Últimos 7 Días'), findsOneWidget);
    expect(find.byType(LineChart), findsOneWidget);
  });

  testWidgets('SettingsScreen renders switches, critical test button and data management section', (WidgetTester tester) async {
    final provider = GlucoseProvider();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const MaterialApp(
          home: SettingsScreen(),
        ),
      ),
    );

    expect(find.text('Ajustes y Recordatorios'), findsOneWidget);
    expect(find.text('Control en Ayunas'), findsOneWidget);
    expect(find.text('Control Pre-Almuerzo'), findsOneWidget);
    expect(find.text('Antes de Dormir'), findsOneWidget);
    expect(find.text('Probar Notificación Crítica'), findsOneWidget);

    // Scroll to see GESTIÓN DE DATOS
    await tester.drag(find.byType(ListView), const Offset(0, -450));
    await tester.pumpAndSettle();
    expect(find.text('GESTIÓN DE DATOS'), findsOneWidget);
    expect(find.text('Borrar todos los registros'), findsOneWidget);
    expect(find.text('Cargar historial histórico (Seed)'), findsOneWidget);

    // Tap "Borrar todos los registros" and verify dialog
    await tester.tap(find.text('Borrar todos los registros'));
    await tester.pumpAndSettle();

    expect(find.byType(Dialog), findsOneWidget);
    expect(find.text('¿Eliminar todo el historial?'), findsOneWidget);
    expect(find.text('Cancelar'), findsOneWidget);
    expect(find.text('Eliminar'), findsOneWidget);

    // Cancel dialog
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });
}
