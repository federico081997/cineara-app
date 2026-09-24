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

  @override
  String get searchPageTitle => '搜索';

  @override
  String get searchFieldLabel => '搜索 Cineara';

  @override
  String get searchHint => '搜索 Cineara';

  @override
  String get searchClearSearch => '清除搜索';

  @override
  String get searchRetry => '重试';

  @override
  String get searchSeeAll => '查看全部';

  @override
  String get searchRecentSearches => '最近搜索';

  @override
  String get searchRecommended => '推荐';

  @override
  String get searchClearRecent => '清除';

  @override
  String get searchRemoveRecentSearch => '移除最近搜索';

  @override
  String get searchSearching => '正在搜索…';

  @override
  String get searchLoadingMore => '正在加载更多…';

  @override
  String get searchLoadMore => '加载更多';

  @override
  String get searchTryAgain => '再试一次';

  @override
  String get searchNoResultsTitle => '没有结果';

  @override
  String get searchNoResultsMessage => '请尝试其他标题、人物、系列、工作室或关键词。';

  @override
  String get searchErrorTitle => '搜索暂不可用';

  @override
  String get searchErrorMessage => '搜索时出现问题，请重试。';

  @override
  String get searchStartTitle => '找点想看的内容';

  @override
  String get searchStartMessage => '搜索电影、剧集、人物、系列、工作室和关键词。';

  @override
  String get searchGrid => '网格';

  @override
  String get searchList => '列表';

  @override
  String get searchCategoryAll => '全部';

  @override
  String get searchCategoryMovies => '电影';

  @override
  String get searchCategoryTvSeries => '剧集';

  @override
  String get searchCategoryPeople => '人物';

  @override
  String get searchCategoryCollections => '系列';

  @override
  String get searchCategoryStudios => '工作室';

  @override
  String get searchCategoryKeywords => '关键词';

  @override
  String get searchMovieDescriptor => '电影';

  @override
  String get searchTvSeriesDescriptor => '剧集';

  @override
  String get searchViewingProgress => '观看进度';

  @override
  String get searchOpenMedia => '打开影视详情';

  @override
  String get searchOpenPerson => '打开人物详情';

  @override
  String get searchOpenCollection => '打开系列详情';

  @override
  String get searchOpenStudio => '打开工作室详情';

  @override
  String get searchOpenKeyword => '搜索此关键词';

  @override
  String get searchFocusShortcut => '聚焦搜索框';

  @override
  String get searchControlShortcutLabel => 'Ctrl K';

  @override
  String get searchMetaShortcutLabel => '⌘K';

  @override
  String get searchCategoriesLabel => '搜索类别';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count 个结果',
    );
    return '$_temp0';
  }

  @override
  String searchRatingOutOfTen(String rating) {
    return '$rating / 10';
  }

  @override
  String get searchStatusDock => '个人媒体状态';

  @override
  String get searchFavorite => '收藏';

  @override
  String get searchInCollection => '已加入收藏集';

  @override
  String get searchInWatchlist => '已加入想看';

  @override
  String get searchPersonalRating => '我的评分';

  @override
  String get searchStatusWatching => '正在观看';

  @override
  String get searchStatusCaughtUp => '已追到最新';

  @override
  String get searchStatusCompleted => '已看完';

  @override
  String get searchStatusRewatching => '重看中';

  @override
  String get searchStatusOnHold => '暂停观看';

  @override
  String get searchStatusDropped => '已弃';

  @override
  String get searchDetailsUnavailable => '此类型的详情页暂不可用。';
}
