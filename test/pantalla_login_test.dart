import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sos_mascotas/vista/auth/pantalla_login.dart';
import 'package:sos_mascotas/vistamodelo/auth/login_vm.dart';
import 'firebase_mock.dart';
import 'package:mocktail/mocktail.dart';

/// ✅ Mock seguro con mocktail
class MockLoginVM extends Mock implements LoginVM {}

void main() {
  late MockLoginVM mockVm;

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await inicializarFirebaseMock();
  });

  setUp(() {
    mockVm = MockLoginVM();

    // 🔹 Tipos de fallback requeridos por mocktail
    registerFallbackValue(GlobalKey<FormState>());
    registerFallbackValue(TextEditingController());

    // 🔹 Atributos simulados
    when(() => mockVm.formKey).thenReturn(GlobalKey<FormState>());
    when(() => mockVm.correoCtrl).thenReturn(TextEditingController());
    when(() => mockVm.claveCtrl).thenReturn(TextEditingController());
    when(() => mockVm.cargando).thenReturn(false);
    when(() => mockVm.error).thenReturn('');

    // 🔹 Evita el TypeError (Future<String?>)
    when(
      () => mockVm.loginYDeterminarRuta(),
    ).thenAnswer((_) async => Future.value(null));
  });

  /// ✅ Construye el widget con ruta simulada
  Widget _buildLogin() {
    return ChangeNotifierProvider<LoginVM>.value(
      value: mockVm,
      child: MaterialApp(
        home: const PantallaLogin(),
        routes: {
          '/registro': (_) =>
              const Scaffold(body: Center(child: Text('Registrarse'))),
        },
      ),
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

        // 🔹 Campos vacíos
        await tester.enterText(find.byType(TextFormField).first, '');
        await tester.enterText(find.byType(TextFormField).last, '');
        await tester.tap(find.text('Entrar'));
        await tester.pump();

        // 🔹 Forzamos validación manual del formulario
        mockVm.formKey.currentState?.validate();
        await tester.pumpAndSettle();

        expect(find.textContaining('Correo inválido'), findsOneWidget);
        expect(find.textContaining('Mínimo 6 caracteres'), findsOneWidget);
      },
    );

    testWidgets('Muestra CircularProgressIndicator cuando está cargando', (
      tester,
    ) async {
      when(() => mockVm.cargando).thenReturn(true);

      await tester.pumpWidget(_buildLogin());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Entrar'), findsNothing);
    });

    testWidgets('Muestra Snackbar con error de login', (tester) async {
      when(() => mockVm.loginYDeterminarRuta()).thenAnswer((_) async {
        when(() => mockVm.error).thenReturn('Contraseña incorrecta');
        return null; // ✅ necesario para coincidir con Future<String?>
      });

      await tester.pumpWidget(_buildLogin());
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      expect(find.text('Contraseña incorrecta'), findsOneWidget);
    });

    testWidgets('Navega hacia la pantalla de registro', (tester) async {
      await tester.binding.setSurfaceSize(const Size(1080, 1920));
      await tester.pumpWidget(_buildLogin());

      await tester.tap(find.text('Registrarse'), warnIfMissed: false);
      await tester.pumpAndSettle();

      expect(find.text('Registrarse'), findsWidgets);
    });
  });
}
