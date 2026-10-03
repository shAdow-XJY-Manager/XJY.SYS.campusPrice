import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campusprice_flutter/component/InfomationListItem.dart';
import 'package:campusprice_flutter/component/ExpandedRow.dart';

void main() {
  testWidgets('native campus information row renders updated school and configured icon/layout', (tester) async {
    Widget view(String title) => MaterialApp(home: Scaffold(body: ExpandedRow(
      sizeRatio: 1, childRatio: 2,
      child: InfomationListItem(title: title, icon: Icons.school),
    )));
    await tester.pumpWidget(view('北京测试大学 · 东校区'));
    expect(find.text('北京测试大学 · 东校区'), findsOneWidget);
    expect(find.byIcon(Icons.school), findsOneWidget);
    final row = find.descendant(of: find.byType(ExpandedRow), matching: find.byType(Row)).first;
    final children = tester.widget<Row>(row).children.cast<Expanded>();
    expect(children.map((e) => e.flex), [1, 2, 1]);
    await tester.pumpWidget(view('上海测试大学 · 西校区'));
    expect(find.text('北京测试大学 · 东校区'), findsNothing);
    expect(find.text('上海测试大学 · 西校区'), findsOneWidget);
  });
}
