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
  String get posterStatusNotStarted => '尚未观看';

  @override
  String get posterStatusWatching => '正在观看';

  @override
  String get posterStatusCaughtUp => '已追至最新';

  @override
  String get posterStatusCompleted => '已看完';

  @override
  String get posterStatusRewatching => '正在重看';

  @override
  String get posterStatusOnHold => '暂停观看';

  @override
  String get posterStatusDropped => '已停止观看';

  @override
  String get posterFavourite => '已加入最爱';

  @override
  String get posterWatchlist => '已加入想看';

  @override
  String posterUserRating(String rating) {
    return '你的评分：$rating';
  }

  @override
  String posterCollectionCount(int count) {
    return '已加入 $count 个收藏夹';
  }

  @override
  String posterProgress(int percentage) {
    return '观看进度：$percentage%';
  }

  @override
  String posterNewEpisodeBadge(int count) {
    return '新增 $count 集';
  }

  @override
  String get posterNewContent => '新';

  @override
  String get posterNewRelease => '新上线';

  @override
  String get posterNewEpisodesAvailable => '有新集更新';

  @override
  String posterNewEpisodeCount(int count) {
    return '有 $count 集新内容可看';
  }

  @override
  String posterAddToWatchlist(String title) {
    return '将 $title 加入想看';
  }

  @override
  String posterRemoveFromWatchlist(String title) {
    return '将 $title 从想看中移除';
  }

  @override
  String posterAddToFavourites(String title) {
    return '将 $title 加入最爱';
  }

  @override
  String posterRemoveFromFavourites(String title) {
    return '将 $title 从最爱中移除';
  }

  @override
  String posterMarkAsWatched(String title) {
    return '将 $title 标记为已看';
  }

  @override
  String posterMarkAsUnwatched(String title) {
    return '将 $title 标记为未看';
  }
}
