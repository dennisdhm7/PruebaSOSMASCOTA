import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';

/// Mocks principales
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

/// Inicializa un entorno Firebase simulado para las pruebas
Future<void> inicializarFirebaseMock() async {
  TestWidgetsFlutterBinding.ensureInitialized();

  // ✅ Evita errores de "MissingPluginException" simulando el canal de Firebase Core
  const MethodChannel firebaseCoreChannel = MethodChannel(
    'plugins.flutter.io/firebase_core',
  );
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(firebaseCoreChannel, (methodCall) async {
        return null; // Ignora llamadas nativas
      });

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
    // Si ya está inicializado, no hacemos nada
  }

  // Mockea FirebaseAuth y Firestore para evitar llamadas reales
  final mockAuth = MockFirebaseAuth();
  final fakeFirestore = FakeFirebaseFirestore();

  when(() => FirebaseAuth.instance).thenReturn(mockAuth);
  when(() => FirebaseFirestore.instance).thenReturn(fakeFirestore);
}

/// Limpia los canales después de cada prueba
void limpiarFirebaseMocks() {
  for (final channelName in [
    'plugins.flutter.io/firebase_core',
    'plugins.flutter.io/firebase_auth',
    'plugins.flutter.io/cloud_firestore',
  ]) {
    final channel = MethodChannel(channelName);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  }
}
