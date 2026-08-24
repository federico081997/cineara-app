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

  @override
  String get posterStatusNotStarted => 'لم تبدأ المشاهدة';

  @override
  String get posterStatusWatching => 'قيد المشاهدة';

  @override
  String get posterStatusCaughtUp => 'مواكب لأحدث الحلقات';

  @override
  String get posterStatusCompleted => 'تمت المشاهدة';

  @override
  String get posterStatusRewatching => 'إعادة المشاهدة';

  @override
  String get posterStatusOnHold => 'موقوف مؤقتًا';

  @override
  String get posterStatusDropped => 'توقفت عن مشاهدته';

  @override
  String get posterFavourite => 'مفضّل';

  @override
  String get posterWatchlist => 'في قائمة المشاهدة';

  @override
  String posterUserRating(String rating) {
    return 'تقييمك: $rating';
  }

  @override
  String posterCollectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'ضمن $count مجموعة',
      many: 'ضمن $count مجموعة',
      few: 'ضمن $count مجموعات',
      two: 'ضمن مجموعتين',
      one: 'ضمن مجموعة واحدة',
      zero: 'ليس ضمن أي مجموعة',
    );
    return '$_temp0';
  }

  @override
  String posterProgress(int percentage) {
    return 'شاهدت $percentage٪';
  }

  @override
  String posterNewEpisodeBadge(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count حلقة جديدة',
      many: '$count حلقة جديدة',
      few: '$count حلقات جديدة',
      two: 'حلقتان جديدتان',
      one: 'جديد',
      zero: 'جديد',
    );
    return '$_temp0';
  }

  @override
  String get posterNewContent => 'جديد';

  @override
  String get posterNewRelease => 'إصدار جديد';

  @override
  String get posterNewEpisodesAvailable => 'تتوفر حلقات جديدة';

  @override
  String posterNewEpisodeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'تتوفر $count حلقة جديدة',
      many: 'تتوفر $count حلقة جديدة',
      few: 'تتوفر $count حلقات جديدة',
      two: 'تتوفر حلقتان جديدتان',
      one: 'تتوفر حلقة جديدة',
      zero: 'لا توجد حلقات جديدة',
    );
    return '$_temp0';
  }

  @override
  String posterAddToWatchlist(String title) {
    return 'أضف $title إلى قائمة المشاهدة';
  }

  @override
  String posterRemoveFromWatchlist(String title) {
    return 'أزل $title من قائمة المشاهدة';
  }

  @override
  String posterAddToFavourites(String title) {
    return 'أضف $title إلى المفضلة';
  }

  @override
  String posterRemoveFromFavourites(String title) {
    return 'أزل $title من المفضلة';
  }

  @override
  String posterMarkAsWatched(String title) {
    return 'ضع علامة على $title بأنه تمت مشاهدته';
  }

  @override
  String posterMarkAsUnwatched(String title) {
    return 'ضع علامة على $title بأنه غير مشاهد';
  }
}
