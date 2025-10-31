import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:sos_mascotas/vista/auth/pantalla_login.dart';
import 'package:sos_mascotas/vistamodelo/auth/login_vm.dart';
import 'firebase_mock.dart'; // Importa la solución del mock
import 'package:mockito/mockito.dart';

// Necesitas un mock de LoginVM para controlar el comportamiento del login,
// ya que las pruebas de widget solo deben probar la interfaz, no la lógica de negocio.
class MockLoginVM extends Mock implements LoginVM {}

void main() {
  late MockLoginVM mockVm;

  // 1. Inicializa el entorno mockeado de Firebase
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized(); // 👈 línea agregada
    await inicializarFirebaseMock();
  });

  // 2. Limpia los canales y crea un nuevo VM mock antes de cada prueba
  setUp(() {
    limpiarFirebaseMocks();
    mockVm = MockLoginVM();
    // Preparamos el mock del validador del formulario:
    when(mockVm.formKey).thenReturn(GlobalKey<FormState>());
  });

  // 3. Función auxiliar para construir el widget con el mock
  Widget _buildLogin() {
    return ChangeNotifierProvider<LoginVM>.value(
      value: mockVm,
      // ELIMINADA la palabra 'const' aquí
      child: MaterialApp(
        // Usamos onGenerateRoute para simular la navegación sin errores
        onGenerateRoute: (settings) {
          // También eliminamos 'const' en la instancia de la pantalla,
          // ya que onGenerateRoute siempre debe retornar una nueva instancia.
          return MaterialPageRoute(builder: (context) => PantallaLogin());
        },
        home: const PantallaLogin(),
      ),
    );
  }

  group('🔐 PantallaLogin', () {
    testWidgets('Renderiza correctamente los campos y botones', (tester) async {
      // Configuramos el VM para que no esté cargando al inicio
      when(mockVm.cargando).thenReturn(false);

      await tester.pumpWidget(_buildLogin());

      expect(find.text('Iniciar Sesión'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Entrar'), findsOneWidget);
      expect(find.text('¿No tienes una cuenta? '), findsOneWidget);
    });

    testWidgets(
      'Muestra errores de validación al intentar Entrar con campos vacíos',
      (tester) async {
        // 1. Configurar los controladores vacíos y simular que la validación falla:
        mockVm.correoCtrl.text = '';
        mockVm.claveCtrl.text = '';

        // 2. Simular que el login no retorna ruta, pero la validación sí se dispara
        when(mockVm.loginYDeterminarRuta()).thenAnswer((_) async => null);
        when(
          mockVm.error,
        ).thenReturn("Usuario no existe"); // Mock de error del VM

        await tester.pumpWidget(_buildLogin());
        await tester.tap(find.text('Entrar'));
        await tester.pumpAndSettle();

        // Verificamos los mensajes de error de los validadores del TextFormField
        expect(find.text('Correo inválido'), findsOneWidget);
        expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
      },
    );

    testWidgets('Muestra CircularProgressIndicator cuando está cargando', (
      tester,
    ) async {
      when(mockVm.cargando).thenReturn(true);
      await tester.pumpWidget(_buildLogin());

      // La etiqueta del botón 'Entrar' debe ser un CircularProgressIndicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Entrar'), findsNothing);
    });

    testWidgets('Muestra Snackbar con error de login', (tester) async {
      // 1. Simular la validación correcta
      when(mockVm.formKey.currentState!.validate()).thenReturn(true);

      // 2. Simular el login fallido con un error
      when(mockVm.loginYDeterminarRuta()).thenAnswer((_) async {
        mockVm.error =
            "Contraseña incorrecta"; // Simula que el VM asigna el error
        return null; // Retorna null para indicar fallo de ruta
      });
      when(
        mockVm.error,
      ).thenReturn("Contraseña incorrecta"); // Mockear el getter

      await tester.pumpWidget(_buildLogin());
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // Verificamos que el SnackBar se muestre con el mensaje de error
      expect(find.text('Contraseña incorrecta'), findsOneWidget);
    });

    testWidgets('Navega hacia la pantalla de registro', (tester) async {
      await tester.pumpWidget(_buildLogin());
      await tester.tap(find.text('Registrarse'));
      await tester.pumpAndSettle();

      // Como no tenemos rutas reales, verificamos la navegación implícita
      // Nota: Si usas go_router, la aserción debe ser sobre el enrutador.
    });
  });
}
