import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hackathon_project/main.dart';

void main() {
  testWidgets('LanSIAP opens with the caregiver welcome screen', (
    tester,
  ) async {
    await tester.pumpWidget(const LanSiapApp());

    expect(find.byType(MaterialApp), findsOneWidget);
    expect(find.text('Keluarga tenang, lansia tersayang.'), findsOneWidget);
  });
}
