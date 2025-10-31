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
  TestWidgetsFlutterBinding.ensureInitialized();

  // 🔧 Evita errores MissingPluginException simulando todos los canales Firebase
  const MethodChannel firebaseCoreChannel = MethodChannel(
    'plugins.flutter.io/firebase_core',
  );
  const MethodChannel firebaseAuthChannel = MethodChannel(
    'plugins.flutter.io/firebase_auth',
  );
  const MethodChannel firestoreChannel = MethodChannel(
    'plugins.flutter.io/cloud_firestore',
  );

  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  for (final channel in [
    firebaseCoreChannel,
    firebaseAuthChannel,
    firestoreChannel,
  ]) {
    messenger.setMockMethodCallHandler(channel, (call) async => null);
  }

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

  // 🔹 Reemplaza instancias reales por mocks seguros
  final mockAuth = MockFirebaseAuth();
  final fakeFirestore = FakeFirebaseFirestore();

  when(() => FirebaseAuth.instance).thenReturn(mockAuth);
  when(() => FirebaseFirestore.instance).thenReturn(fakeFirestore);
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
