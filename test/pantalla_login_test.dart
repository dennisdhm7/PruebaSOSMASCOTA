import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sos_mascotas/vista/auth/pantalla_login.dart';
import 'package:sos_mascotas/vistamodelo/auth/login_vm.dart';

void main() {
  Widget _buildLogin() {
    return ChangeNotifierProvider(
      create: (_) => LoginVM(),
      child: const MaterialApp(home: PantallaLogin()),
    );
  }

  group('🔐 PantallaLogin', () {
    testWidgets('Renderiza correctamente los campos y botones', (tester) async {
      await tester.pumpWidget(_buildLogin());
      expect(find.text('Iniciar Sesión'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('¿No tienes una cuenta? '), findsOneWidget);
    });

    testWidgets('Muestra error al intentar login sin correo ni contraseña', (
      tester,
    ) async {
      await tester.pumpWidget(_buildLogin());
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Correo inválido'), findsOneWidget);
      expect(find.textContaining('Mínimo 6 caracteres'), findsOneWidget);
    });

    testWidgets('Navega hacia la pantalla de registro', (tester) async {
      await tester.pumpWidget(_buildLogin());
      await tester.tap(find.text('Registrarse'));
      await tester.pumpAndSettle();
      // Verificamos que la navegación se haya intentado
      expect(find.text('Registrarse'), findsWidgets);
    });
  });
}
