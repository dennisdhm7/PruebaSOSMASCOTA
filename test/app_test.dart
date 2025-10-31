import 'package:flutter_test/flutter_test.dart';
import 'package:sos_mascotas/app.dart';

void main() {
  group('Pruebas básicas de inicialización', () {
    testWidgets('La app se inicializa correctamente', (tester) async {
      await tester.pumpWidget(const MyApp());
      expect(find.text('SOS Mascota'), findsOneWidget);
    });
  });
}
