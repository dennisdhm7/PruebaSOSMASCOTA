import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sos_mascotas/vista/usuario/pantalla_inicio.dart';
import 'package:sos_mascotas/vistamodelo/notificacion/notificacion_vm.dart';
import 'firebase_mock.dart';

void main() {
  setUpAll(() async {
    await inicializarFirebaseMock();
  });

  tearDown(() {
    limpiarFirebaseMocks();
  });

  Widget _buildInicio() {
    return ChangeNotifierProvider(
      create: (_) => NotificacionVM(),
      child: const MaterialApp(home: PantallaInicio()),
    );
  }

  group('🏠 PantallaInicio', () {
    testWidgets('Renderiza correctamente los títulos y botones principales', (
      tester,
    ) async {
      await tester.pumpWidget(_buildInicio());
      await tester.pumpAndSettle();

      expect(find.text('Acciones Rápidas'), findsOneWidget);
      expect(find.text('Menú Principal'), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('Interactúa con el BottomNavigationBar', (tester) async {
      await tester.pumpWidget(_buildInicio());
      await tester.pumpAndSettle();

      final bar = find.byType(BottomNavigationBar);
      expect(bar, findsOneWidget);

      await tester.tap(find.text('Perfil'));
      await tester.pumpAndSettle();
      expect(find.text('Perfil'), findsWidgets);
    });

    testWidgets('Renderiza tarjetas de acción rápidas', (tester) async {
      await tester.pumpWidget(_buildInicio());
      await tester.pumpAndSettle();

      expect(find.text('Reportar Mascota'), findsWidgets);
      expect(find.text('Registrar Avistamiento'), findsWidgets);
    });
  });
}
