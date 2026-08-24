import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../data/search_repository.dart';
import 'global_search_page.dart';
import 'search_content_view.dart';
import 'search_controller.dart';

/// Application-level Search page connected to Cineara's backend.
class SearchFeaturePage extends StatefulWidget {
  const SearchFeaturePage({
    required this.apiBaseUri,
    required this.labels,
    required this.placeholder,
    required this.backSemanticLabel,
    required this.clearSemanticLabel,
    required this.onResultPressed,
    super.key,
    this.initialQuery = '',
    this.minimumQueryLength = 2,
  });

  /// Base backend URI including `/api/v1/`.
  ///
  /// Emulator development example:
  ///
  /// http://10.0.2.2:8000/api/v1/
  final Uri apiBaseUri;

  final SearchContentLabels labels;

  final String placeholder;
  final String backSemanticLabel;
  final String clearSemanticLabel;

  final ValueChanged<CinearaSearchResult> onResultPressed;

  final String initialQuery;

  final int minimumQueryLength;

  @override
  State<SearchFeaturePage> createState() => _SearchFeaturePageState();
}

class _SearchFeaturePageState extends State<SearchFeaturePage> {
  late final http.Client _httpClient;

  late final SearchRepository _repository;

  late final CinearaSearchController _controller;

  @override
  void initState() {
    super.initState();

    _httpClient = http.Client();

    _repository = SearchRepository(
      client: _httpClient,
      baseUri: widget.apiBaseUri,
    );

    _controller = CinearaSearchController(
      repository: _repository,
      minimumQueryLength: widget.minimumQueryLength,
    );

    if (widget.initialQuery.trim().isNotEmpty) {
      _controller.onQueryChanged(widget.initialQuery);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _httpClient.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CinearaGlobalSearchPage(
      placeholder: widget.placeholder,
      backSemanticLabel: widget.backSemanticLabel,
      clearSemanticLabel: widget.clearSemanticLabel,
      initialQuery: widget.initialQuery,
      onQueryChanged: _controller.onQueryChanged,
      onSubmitted: _controller.submit,
      contentBuilder: (BuildContext context, String query) {
        return ListenableBuilder(
          listenable: _controller,
          builder: (BuildContext context, Widget? child) {
            final bool hasSearchableQuery =
                query.trim().length >= widget.minimumQueryLength;

            return SearchContentView(
              // Until minimumQueryLength is reached, SearchContentView stays
              // in its idle state rather than showing "No results".
              query: hasSearchableQuery ? query : '',
              labels: widget.labels,

              results: _controller.results,

              selectedFilter: _controller.filter,

              isLoading: _controller.isLoading,

              errorMessage: _controller.errorMessage,

              onFilterChanged: _controller.setFilter,

              onResultPressed: widget.onResultPressed,

              onRetry: _controller.retry,
            );
          },
        );
      },
    );
  }
}
