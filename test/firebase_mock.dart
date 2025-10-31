import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';

/// 🔹 Inicializa un entorno Firebase simulado para las pruebas
Future<void> inicializarFirebaseMock() async {
  TestWidgetsFlutterBinding.ensureInitialized();

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
    // Si ya está inicializado, no hace nada
  }

  // Simula instancias globales
  MockFirebaseAuth();
  FakeFirebaseFirestore();
}
