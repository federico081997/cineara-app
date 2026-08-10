// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get posterStatusNotStarted => 'Non iniziato';

  @override
  String get posterStatusWatching => 'In visione';

  @override
  String get posterStatusCaughtUp => 'In pari';

  @override
  String get posterStatusCompleted => 'Completato';

  @override
  String get posterStatusRewatching => 'Di nuovo in visione';

  @override
  String get posterStatusOnHold => 'In pausa';

  @override
  String get posterStatusDropped => 'Abbandonato';

  @override
  String get posterFavourite => 'Nei preferiti';

  @override
  String get posterWatchlist => 'Da vedere';

  @override
  String posterUserRating(String rating) {
    return 'La tua valutazione: $rating';
  }

  @override
  String posterCollectionCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'In $count collezioni',
      one: 'In una collezione',
    );
    return '$_temp0';
  }

  @override
  String posterProgress(int percentage) {
    return 'Avanzamento: $percentage%';
  }

  @override
  String get posterNewContent => 'NOVITÀ';

  @override
  String get posterNewRelease => 'Nuova uscita';

  @override
  String get posterNewEpisodesAvailable => 'Nuovi episodi disponibili';

  @override
  String posterNewEpisodeCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count nuovi episodi disponibili',
      one: 'Un nuovo episodio disponibile',
    );
    return '$_temp0';
  }

  @override
  String posterAddToWatchlist(String title) {
    return 'Aggiungi $title ai titoli da vedere';
  }

  @override
  String posterRemoveFromWatchlist(String title) {
    return 'Rimuovi $title dai titoli da vedere';
  }

  @override
  String posterAddToFavourites(String title) {
    return 'Aggiungi $title ai preferiti';
  }

  @override
  String posterRemoveFromFavourites(String title) {
    return 'Rimuovi $title dai preferiti';
  }

  @override
  String posterMarkAsWatched(String title) {
    return 'Segna $title come visto';
  }

  @override
  String posterMarkAsUnwatched(String title) {
    return 'Segna $title come non visto';
  }
}
