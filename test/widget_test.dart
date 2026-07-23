import 'package:flutter_test/flutter_test.dart';
import 'package:kaleido_lab/main.dart';

void main() {
  testWidgets('app boots', (tester) async {
    await tester.pumpWidget(const KaleidoLabApp());
    expect(find.text('Kaleido Lab'), findsOneWidget);
  });
}
