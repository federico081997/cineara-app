// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Chinese (`zh`).
class AppLocalizationsZh extends AppLocalizations {
  AppLocalizationsZh([String locale = 'zh']) : super(locale);

  @override
  String get appTitle => 'Cineara';

  @override
  String get routeErrorTitle => '页面无法打开';

  @override
  String get routeErrorMessage => '无法打开此页面，请返回首页后重试。';

  @override
  String get routeErrorGoHome => '返回首页';

  @override
  String get navigationHome => '首页';

  @override
  String get navigationDiscover => '发现';

  @override
  String get navigationLibrary => '资料库';

  @override
  String get navigationProfile => '我的';

  @override
  String get topBarSearch => '搜索';

  @override
  String get topBarNotifications => '通知';

  @override
  String get topBarOpenProfileMenu => '打开个人资料菜单';
}
