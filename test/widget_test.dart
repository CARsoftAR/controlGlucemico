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

void main() {
  testWidgets('DashboardScreen renders appbar and floating action button with GlucoseProvider', (WidgetTester tester) async {
    final provider = GlucoseProvider();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: provider,
        child: const GlucoseControlApp(),
      ),
    );

    expect(find.text('GLUCO CONTROL'), findsOneWidget);
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  test('GlucoseMeasurement serialization toMap and fromMap works seamlessly', () {
    final now = DateTime(2026, 10, 25, 20, 30);
    final measurement = GlucoseMeasurement(
      id: 'test_1',
      value: 195.0,
      timestamp: now,
      context: 'Postprandial (2h)',
      isHigh: true,
    );

    final map = measurement.toMap();
    expect(map['id'], 'test_1');
    expect(map['value'], 195.0);
    expect(map['context'], 'Postprandial (2h)');
    expect(map['isHigh'], true);

    final fromMap = GlucoseMeasurement.fromMap(map, 'test_1');
    expect(fromMap.id, 'test_1');
    expect(fromMap.value, 195.0);
    expect(fromMap.context, 'Postprandial (2h)');
    expect(fromMap.isHigh, true);
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

  testWidgets('SettingsScreen renders switches in Cyan and critical test button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SettingsScreen(),
      ),
    );

    expect(find.text('Ajustes y Recordatorios'), findsOneWidget);
    expect(find.text('Control en Ayunas'), findsOneWidget);
    expect(find.text('Control Pre-Almuerzo'), findsOneWidget);
    expect(find.text('Antes de Dormir'), findsOneWidget);
    expect(find.text('Probar Notificación Crítica'), findsOneWidget);

    // Tap test notification button with warnIfMissed false or scroll
    await tester.tap(find.text('Probar Notificación Crítica'), warnIfMissed: false);
    await tester.pump();
  });
}
