// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Cineara';

  @override
  String get routeErrorTitle => 'Pagina non disponibile';

  @override
  String get routeErrorMessage =>
      'Non è stato possibile aprire questa pagina. Torna alla Home e riprova.';

  @override
  String get routeErrorGoHome => 'Torna alla Home';

  @override
  String get navigationHome => 'Home';

  @override
  String get navigationDiscover => 'Scopri';

  @override
  String get navigationLibrary => 'Libreria';

  @override
  String get navigationProfile => 'Profilo';

  @override
  String get topBarSearch => 'Cerca';

  @override
  String get topBarNotifications => 'Notifiche';

  @override
  String get topBarOpenProfileMenu => 'Apri il menu del profilo';

  @override
  String get searchPageTitle => 'Cerca';

  @override
  String get searchFieldLabel => 'Cerca su Cineara';

  @override
  String get searchHint => 'Cerca su Cineara';

  @override
  String get searchClearSearch => 'Cancella la ricerca';

  @override
  String get searchRetry => 'Riprova';

  @override
  String get searchSeeAll => 'Vedi tutto';

  @override
  String get searchRecentSearches => 'Ricerche recenti';

  @override
  String get searchRecommended => 'Consigliati';

  @override
  String get searchClearRecent => 'Cancella';

  @override
  String get searchRemoveRecentSearch => 'Rimuovi ricerca recente';

  @override
  String get searchSearching => 'Ricerca in corso…';

  @override
  String get searchLoadingMore => 'Caricamento di altri risultati…';

  @override
  String get searchLoadMore => 'Carica altro';

  @override
  String get searchTryAgain => 'Riprova';

  @override
  String get searchNoResultsTitle => 'Nessun risultato';

  @override
  String get searchNoResultsMessage =>
      'Prova con un altro titolo, persona, collezione, studio o parola chiave.';

  @override
  String get searchErrorTitle => 'Ricerca non disponibile';

  @override
  String get searchErrorMessage =>
      'Si è verificato un problema durante la ricerca. Riprova.';

  @override
  String get searchStartTitle => 'Trova qualcosa da guardare';

  @override
  String get searchStartMessage =>
      'Cerca tra film, serie TV, persone, collezioni, studi e parole chiave.';

  @override
  String get searchGrid => 'Griglia';

  @override
  String get searchList => 'Elenco';

  @override
  String get searchCategoryAll => 'Tutto';

  @override
  String get searchCategoryMovies => 'Film';

  @override
  String get searchCategoryTvSeries => 'Serie TV';

  @override
  String get searchCategoryPeople => 'Persone';

  @override
  String get searchCategoryCollections => 'Collezioni';

  @override
  String get searchCategoryStudios => 'Studi';

  @override
  String get searchCategoryKeywords => 'Parole chiave';

  @override
  String get searchMovieDescriptor => 'Film';

  @override
  String get searchTvSeriesDescriptor => 'Serie TV';

  @override
  String get searchViewingProgress => 'Avanzamento visione';

  @override
  String get searchOpenMedia => 'Apri i dettagli del titolo';

  @override
  String get searchOpenPerson => 'Apri i dettagli della persona';

  @override
  String get searchOpenCollection => 'Apri i dettagli della collezione';

  @override
  String get searchOpenStudio => 'Apri i dettagli dello studio';

  @override
  String get searchOpenKeyword => 'Cerca questa parola chiave';

  @override
  String get searchFocusShortcut => 'Attiva il campo di ricerca';

  @override
  String get searchControlShortcutLabel => 'Ctrl K';

  @override
  String get searchMetaShortcutLabel => '⌘K';

  @override
  String get searchCategoriesLabel => 'Categorie di ricerca';

  @override
  String searchResultCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count risultati',
      one: '1 risultato',
      zero: 'Nessun risultato',
    );
    return '$_temp0';
  }

  @override
  String searchRatingOutOfTen(String rating) {
    return '$rating su 10';
  }

  @override
  String get searchStatusDock => 'Stato personale del titolo';

  @override
  String get searchFavorite => 'Preferito';

  @override
  String get searchInCollection => 'Nella collezione';

  @override
  String get searchInWatchlist => 'Nella lista da guardare';

  @override
  String get searchPersonalRating => 'Valutazione personale';

  @override
  String get searchStatusWatching => 'In visione';

  @override
  String get searchStatusCaughtUp => 'In pari';

  @override
  String get searchStatusCompleted => 'Completato';

  @override
  String get searchStatusRewatching => 'In revisione';

  @override
  String get searchStatusOnHold => 'In pausa';

  @override
  String get searchStatusDropped => 'Abbandonato';

  @override
  String get searchDetailsUnavailable =>
      'La pagina dei dettagli per questo tipo non è ancora disponibile.';
}
