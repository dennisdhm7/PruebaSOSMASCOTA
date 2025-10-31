import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sos_mascotas/vista/usuario/pantalla_perfil.dart';

void main() {
  Widget _buildPerfil() {
    return const MaterialApp(home: PantallaPerfil());
  }

  group('👤 PantallaPerfil', () {
    testWidgets('Muestra indicador de carga inicial', (tester) async {
      await tester.pumpWidget(_buildPerfil());
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Contiene AppBar y BottomNavigationBar', (tester) async {
      await tester.pumpWidget(_buildPerfil());
      await tester.pump(const Duration(seconds: 2));

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('Renderiza secciones de información y seguridad', (
      tester,
    ) async {
      await tester.pumpWidget(_buildPerfil());
      await tester.pumpAndSettle(const Duration(seconds: 1));

      expect(find.textContaining('Información Personal'), findsWidgets);
      expect(find.textContaining('Seguridad'), findsWidgets);
    });
  });
}
