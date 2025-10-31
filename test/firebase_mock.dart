import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter/services.dart';

/// Mock para FirebaseFirestore
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

/// Mock para FirebaseAuth
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

/// 🔹 Inicializa Firebase falso globalmente (sin App real)
Future<void> inicializarFirebaseMock() async {
  // Asegura entorno de test
  TestWidgetsFlutterBinding.ensureInitialized();

  // Simula inicialización de Firebase
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
    // Si ya está inicializado, continúa
  }

  // Instancias falsas
  final mockAuth = MockFirebaseAuth();
  final mockFirestore = FakeFirebaseFirestore();

  // 🔹 Intercepta los métodos globales ANTES de cualquier build
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/firebase_core'),
        (call) async => null,
      );

  when(() => FirebaseAuth.instance).thenReturn(mockAuth);
  when(() => FirebaseFirestore.instance).thenReturn(mockFirestore);
}
