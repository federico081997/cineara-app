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
  String get searchPageTitle => 'بحث';

  @override
  String get searchFieldLabel => 'ابحث في Cineara';

  @override
  String get searchHint => 'ابحث في Cineara';

  @override
  String get searchClearSearch => 'مسح البحث';

  @override
  String get searchRetry => 'إعادة المحاولة';

  @override
  String get searchSeeAll => 'عرض الكل';

  @override
  String get searchRecentSearches => 'عمليات البحث الأخيرة';

  @override
  String get searchRecommended => 'مقترح';

  @override
  String get searchClearRecent => 'مسح';

  @override
  String get searchRemoveRecentSearch => 'إزالة البحث الأخير';

  @override
  String get searchSearching => 'جارٍ البحث…';

  @override
  String get searchLoadingMore => 'جارٍ تحميل المزيد…';

  @override
  String get searchLoadMore => 'تحميل المزيد';

  @override
  String get searchTryAgain => 'حاول مرة أخرى';

  @override
  String get searchNoResultsTitle => 'لا توجد نتائج';

  @override
  String get searchNoResultsMessage =>
      'جرّب عنوانًا أو شخصًا أو مجموعة أو استوديو أو كلمة مفتاحية أخرى.';

  @override
  String get searchErrorTitle => 'البحث غير متاح';

  @override
  String get searchErrorMessage => 'حدث خطأ أثناء البحث. حاول مرة أخرى.';

  @override
  String get searchStartTitle => 'ابحث عما تريد مشاهدته';

  @override
  String get searchStartMessage =>
      'ابحث في الأفلام والمسلسلات التلفزيونية والأشخاص والمجموعات والاستوديوهات والكلمات المفتاحية.';

  @override
  String get searchGrid => 'شبكة';

  @override
  String get searchList => 'قائمة';

  @override
  String get searchCategoryAll => 'الكل';

  @override
  String get searchCategoryMovies => 'أفلام';

  @override
  String get searchCategoryTvSeries => 'مسلسلات تلفزيونية';

  @override
  String get searchCategoryPeople => 'أشخاص';

  @override
  String get searchCategoryCollections => 'مجموعات';

  @override
  String get searchCategoryStudios => 'استوديوهات';

  @override
  String get searchCategoryKeywords => 'كلمات مفتاحية';

  @override
  String get searchMovieDescriptor => 'فيلم';

  @override
  String get searchTvSeriesDescriptor => 'مسلسل تلفزيوني';

  @override
  String get searchViewingProgress => 'تقدم المشاهدة';

  @override
  String get searchOpenMedia => 'فتح تفاصيل العمل';

  @override
  String get searchOpenPerson => 'فتح تفاصيل الشخص';

  @override
  String get searchOpenCollection => 'فتح تفاصيل المجموعة';

  @override
  String get searchOpenStudio => 'فتح تفاصيل الاستوديو';

  @override
  String get searchOpenKeyword => 'البحث بهذه الكلمة المفتاحية';

  @override
  String get searchFocusShortcut => 'الانتقال إلى حقل البحث';

  @override
  String get searchControlShortcutLabel => 'Ctrl K';

  @override
  String get searchMetaShortcutLabel => '⌘K';

  @override
  String get searchCategoriesLabel => 'فئات البحث';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count نتيجة',
      many: '$count نتيجة',
      few: '$count نتائج',
      two: 'نتيجتان',
      one: 'نتيجة واحدة',
      zero: 'لا توجد نتائج',
    );
    return '$_temp0';
  }

  @override
  String searchRatingOutOfTen(String rating) {
    return '$rating من 10';
  }

  @override
  String get searchStatusDock => 'حالة الوسائط الشخصية';

  @override
  String get searchFavorite => 'المفضلة';

  @override
  String get searchInCollection => 'ضمن المجموعة';

  @override
  String get searchInWatchlist => 'ضمن قائمة المشاهدة';

  @override
  String get searchPersonalRating => 'تقييمي';

  @override
  String get searchStatusWatching => 'قيد المشاهدة';

  @override
  String get searchStatusCaughtUp => 'مواكب للحلقات';

  @override
  String get searchStatusCompleted => 'مكتمل';

  @override
  String get searchStatusRewatching => 'إعادة مشاهدة';

  @override
  String get searchStatusOnHold => 'متوقف مؤقتًا';

  @override
  String get searchStatusDropped => 'تم التخلي عنه';

  @override
  String get searchDetailsUnavailable =>
      'صفحة التفاصيل لهذا النوع غير متاحة بعد.';
}
