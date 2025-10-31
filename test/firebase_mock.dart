import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';

/// Mock principal de FirebaseAuth
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

/// ✅ Inicializa un entorno Firebase completamente simulado (estable en CI)
Future<void> inicializarFirebaseMock() async {
  final binding = TestWidgetsFlutterBinding.ensureInitialized();

  // 🔧 Simula los canales nativos de Firebase
  const MethodChannel firebaseCoreChannel = MethodChannel(
    'plugins.flutter.io/firebase_core',
  );
  const MethodChannel firebaseAuthChannel = MethodChannel(
    'plugins.flutter.io/firebase_auth',
  );
  const MethodChannel firestoreChannel = MethodChannel(
    'plugins.flutter.io/cloud_firestore',
  );

  final messenger = binding.defaultBinaryMessenger;

  // No usar "await" porque retorna void en Flutter 3.30+
  messenger.setMockMethodCallHandler(firebaseCoreChannel, (call) async => null);
  messenger.setMockMethodCallHandler(firebaseAuthChannel, (call) async => null);
  messenger.setMockMethodCallHandler(firestoreChannel, (call) async => null);

  // 🔹 Asegura que Firebase.initializeApp() se ejecute correctamente
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
    // Ya estaba inicializado
  }

  // 🔹 Espera breve para asegurar inicialización completa en GitHub Actions
  await Future.delayed(const Duration(milliseconds: 300));

  // 🔹 Crea mocks
  final mockAuth = MockFirebaseAuth();
  final fakeFirestore = FakeFirebaseFirestore();

  // 🔹 Protege con try/catch por si Firebase aún no está listo
  try {
    when(() => FirebaseAuth.instance).thenReturn(mockAuth);
  } catch (_) {
    // Evita fallar en caso de inicialización concurrente
  }

  try {
    when(() => FirebaseFirestore.instance).thenReturn(fakeFirestore);
  } catch (_) {}
}

/// 🔁 Limpia los canales después de cada prueba
void limpiarFirebaseMocks() {
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  for (final name in [
    'plugins.flutter.io/firebase_core',
    'plugins.flutter.io/firebase_auth',
    'plugins.flutter.io/cloud_firestore',
  ]) {
    messenger.setMockMethodCallHandler(MethodChannel(name), null);
  }
}
