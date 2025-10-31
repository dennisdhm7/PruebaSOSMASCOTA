import 'package:flutter_test/flutter_test.dart';
import 'package:sos_mascotas/app.dart';

void main() {
  testWidgets('Carga la aplicación principal correctamente', (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.textContaining('SOS Mascota'), findsWidgets);
  });
}
