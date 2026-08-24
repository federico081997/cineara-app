// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Cineara';

  @override
  String get routeErrorTitle => 'الصفحة غير متاحة';

  @override
  String get routeErrorMessage =>
      'تعذر فتح هذه الصفحة. عُد إلى الصفحة الرئيسية وحاول مرة أخرى.';

  @override
  String get routeErrorGoHome => 'العودة إلى الرئيسية';

  @override
  String get navigationHome => 'الرئيسية';

  @override
  String get navigationDiscover => 'استكشاف';

  @override
  String get navigationLibrary => 'مكتبتي';

  @override
  String get navigationProfile => 'حسابي';

  @override
  String get topBarSearch => 'بحث';

  @override
  String get topBarNotifications => 'الإشعارات';

  @override
  String get topBarOpenProfileMenu => 'فتح قائمة الملف الشخصي';
}
