import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';

/// Mock principal de FirebaseAuth
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

/// ✅ Inicializa un entorno Firebase completamente simulado
Future<void> inicializarFirebaseMock() async {
  // Aseguramos que el binding esté listo (aunque ya se llama en setUpAll de los tests)
  TestWidgetsFlutterBinding.ensureInitialized();

  // 1. Simular la inicialización de Firebase Core
  // Usaremos un handler dummy para interceptar la llamada al canal nativo
  // 'plugins.flutter.io/firebase_core' que ocurre dentro de Firebase.initializeApp().
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/firebase_core'),
        (MethodCall methodCall) async {
          if (methodCall.method == 'Firebase#initializeCore') {
            // Retorna un valor simulado que indica que la app "default" está lista
            return [
              {
                'name': 'default',
                'options': {/* Opciones simuladas */},
              },
            ];
          }
          return null;
        },
      );

  // 2. Ejecutar la inicialización de Core
  try {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'fake-api-key',
        appId: '1:1234567890:web:abcdef123456',
        messagingSenderId: '1234567890',
        projectId: 'sos-mascotas-mock',
      ),
    );
  } catch (_) {
    // Ya inicializado
  }

  // 3. 🔹 Reemplaza instancias reales por mocks seguros AHORA QUE CORE ESTÁ LISTO

  // Mockear el resto de canales que los paquetes llaman para evitar MissingPluginException
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/firebase_auth'),
        (call) async => null,
      );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/cloud_firestore'),
        (call) async => null,
      );

  // Simulación de Auth y Firestore
  final mockAuth = MockFirebaseAuth();
  final fakeFirestore = FakeFirebaseFirestore();

  // Redefinir las instancias globales para usar los mocks
  when(() => FirebaseAuth.instance).thenReturn(mockAuth);
  when(() => FirebaseFirestore.instance).thenReturn(fakeFirestore);
}

/// 🔁 Limpia los canales después de cada prueba
void limpiarFirebaseMocks() {
  // NO ES NECESARIO LIMPIAR CANALES EN tearDown si usamos setMockMethodCallHandler,
  // pero mantendremos la función por seguridad.
}
