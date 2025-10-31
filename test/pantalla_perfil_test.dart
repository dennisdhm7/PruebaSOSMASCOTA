import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sos_mascotas/vista/usuario/pantalla_perfil.dart';
import 'firebase_mock.dart';

void main() {
  setUpAll(() async {
    await inicializarFirebaseMock();
  });
  tearDown(() {
    for (final channelName in [
      'plugins.flutter.io/firebase_core',
      'plugins.flutter.io/firebase_auth',
      'plugins.flutter.io/cloud_firestore',
    ]) {
      final channel = MethodChannel(channelName);
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, null);
    }
  });

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
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byType(BottomNavigationBar), findsOneWidget);
    });

    testWidgets('Renderiza secciones de información y seguridad', (
      tester,
    ) async {
      await tester.pumpWidget(_buildPerfil());
      await tester.pumpAndSettle();

      expect(find.textContaining('Información'), findsWidgets);
      expect(find.textContaining('Seguridad'), findsWidgets);
    });
  });
}
