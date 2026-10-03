import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:campusprice_flutter/redux/app_state/state.dart';
import 'package:campusprice_flutter/redux/action/user_action.dart';
import 'package:campusprice_flutter/redux/action/device_action.dart';
import 'package:campusprice_flutter/redux/action/theme_action.dart';

void main() {
  test('school and zone selection preserve unrelated profile/device data', () {
    final initial = AppState.initialState();
    final selected = appReducer(initial, SetUserDataAction(school: '测试大学', zone: '北校区'));
    expect(selected.userModel.school, '测试大学');
    expect(selected.userModel.zone, '北校区');
    expect(selected.userModel.avatar, 'avatar_0.jpg');
    expect(selected.deviceModel.ip, '0.0.0.0');
    final avatar = appReducer(selected, SetUserDataAction(avatar: 'avatar_3.jpg'));
    expect(avatar.userModel.school, '测试大学');
    expect(avatar.userModel.zone, '北校区');
    expect(avatar.userModel.avatar, 'avatar_3.jpg');
  });

  test('device location and theme actions update the native display state', () {
    final located = appReducer(AppState.initialState(), SetDeviceDataAction(
      ip: '192.0.2.1', country: '中国', province: '江苏', city: '南京',
    ));
    expect(located.deviceModel.getAddress(), '中国-江苏-南京');
    expect(located.deviceModel.ip, '192.0.2.1');
    final themed = appReducer(located, SetThemeDataAction(brightness: Brightness.light));
    expect(themed.themeModel.getDayMode(), isTrue);
    expect(themed.deviceModel.getAddress(), '中国-江苏-南京');
    expect(identical(appReducer(themed, Object()), themed), isTrue);
  });
}
