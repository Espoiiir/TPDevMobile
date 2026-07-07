import 'package:flutter_test/flutter_test.dart';
import 'package:tp_final_mobile/main.dart';

void main() {
  testWidgets('affiche la navigation principale', (tester) async {
    await tester.pumpWidget(const RaiderIoApp());

    expect(find.text('Guildes'), findsWidgets);
    expect(find.text('Recherche'), findsWidgets);
  });
}
