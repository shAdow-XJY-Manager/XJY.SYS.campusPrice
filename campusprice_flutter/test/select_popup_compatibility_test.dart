import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campusprice_flutter/component/SelectPopup.dart';

Widget selector(List<String> keys, ValueChanged<String> selected, {bool loading = false}) =>
    MaterialApp(home: Scaffold(body: Center(child: SelectPopup(
      keys: keys, clickCallback: selected, refreshing: loading,
    ))));

void main() {
  testWidgets('default and user selection retain the original callback contract', (tester) async {
    final selected = <String>[];
    await tester.pumpWidget(selector(['杭州', '南京'], selected.add));
    expect(selected, ['杭州']);
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('南京').last);
    await tester.pumpAndSettle();
    expect(selected.last, '南京');
    expect(find.text('南京'), findsOneWidget);
    await tester.pumpWidget(selector(['南京', '杭州'], selected.add));
    await tester.pumpAndSettle();
    expect(selected, ['杭州', '南京']);
    expect(find.text('南京'), findsOneWidget);
  });
  testWidgets('in-place asynchronous school refresh clears stale values then defaults to the new list', (tester) async {
    final keys = ['旧学校'];
    final selected = <String>[];
    await tester.pumpWidget(selector(keys, selected.add));
    keys.clear();
    await tester.pumpWidget(selector(keys, selected.add, loading: true));
    await tester.pumpAndSettle();
    expect(selected.last, '');
    expect(tester.widget<PopupMenuButton<String>>(find.byType(PopupMenuButton<String>)).enabled, isFalse);
    keys.addAll(['新学校', '另一所学校']);
    await tester.pumpWidget(selector(keys, selected.add));
    await tester.pumpAndSettle();
    expect(selected.last, '新学校');
    expect(find.text('新学校'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  testWidgets('empty choices remain disabled and duplicate values fit a narrow dialog', (tester) async {
    tester.view.physicalSize = const Size(320, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final selected = <String>[];
    await tester.pumpWidget(selector([], selected.add));
    expect(selected, ['']);
    expect(tester.widget<PopupMenuButton<String>>(find.byType(PopupMenuButton<String>)).enabled, isFalse);
    await tester.pumpWidget(MaterialApp(home: Scaffold(body: AlertDialog(content: SelectPopup(
      keys: ['大学城校区', '大学城校区', '五山校区'], clickCallback: selected.add,
    )))));
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('五山校区').last);
    await tester.pumpAndSettle();
    expect(selected.last, '五山校区');
    expect(tester.takeException(), isNull);
  });
}
