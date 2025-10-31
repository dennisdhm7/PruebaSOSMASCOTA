import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sos_mascotas/vista/auth/pantalla_login.dart';
import 'package:sos_mascotas/vistamodelo/auth/login_vm.dart';
import 'firebase_mock.dart';
import 'package:mockito/mockito.dart';

/// ✅ Mock de LoginVM usando Mockito clásico
class MockLoginVM extends Mock implements LoginVM {}

void main() {
  late MockLoginVM mockVm;

  // 1️⃣ Inicializa Firebase simulado
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await inicializarFirebaseMock();
  });

  // 2️⃣ Crea nuevo mock antes de cada test
  setUp(() {
    mockVm = MockLoginVM();

    // Simulamos los atributos principales
    when(mockVm.formKey).thenReturn(GlobalKey<FormState>());
    when(mockVm.correoCtrl).thenReturn(TextEditingController());
    when(mockVm.claveCtrl).thenReturn(TextEditingController());
    when(mockVm.cargando).thenReturn(false);
    when(mockVm.error).thenReturn('');
  });

  // 3️⃣ Función auxiliar para construir el widget con el mock
  Widget _buildLogin() {
    return ChangeNotifierProvider<LoginVM>.value(
      value: mockVm,
      child: MaterialApp(home: PantallaLogin()),
    );
  }

  group('🔐 PantallaLogin', () {
    testWidgets('Renderiza correctamente los campos y botones', (tester) async {
      await tester.pumpWidget(_buildLogin());

      expect(find.text('Iniciar Sesión'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.textContaining('¿No tienes una cuenta?'), findsOneWidget);
    });

    testWidgets(
      'Muestra errores de validación al intentar Entrar con campos vacíos',
      (tester) async {
        await tester.pumpWidget(_buildLogin());

        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        expect(find.textContaining('Correo inválido'), findsOneWidget);
        expect(find.textContaining('Mínimo 6 caracteres'), findsOneWidget);
      },
    );

    testWidgets('Muestra CircularProgressIndicator cuando está cargando', (
      tester,
    ) async {
      when(mockVm.cargando).thenReturn(true);

      await tester.pumpWidget(_buildLogin());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Entrar'), findsNothing);
    });

    testWidgets('Muestra Snackbar con error de login', (tester) async {
      // Simulamos formulario válido
      final formKey = GlobalKey<FormState>();
      when(mockVm.formKey).thenReturn(formKey);

      // Simulamos validación correcta
      when(mockVm.formKey.currentState?.validate()).thenReturn(true);

      // Simulamos intento de login fallido
      when(mockVm.loginYDeterminarRuta()).thenAnswer((_) async {
        when(mockVm.error).thenReturn('Contraseña incorrecta');
        return null;
      });

      await tester.pumpWidget(_buildLogin());
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Contraseña incorrecta'), findsOneWidget);
    });

    testWidgets('Navega hacia la pantalla de registro', (tester) async {
      await tester.pumpWidget(_buildLogin());
      await tester.tap(find.text('Registrarse'));
      await tester.pumpAndSettle();

      expect(find.text('Registrarse'), findsWidgets);
    });
  });
}
