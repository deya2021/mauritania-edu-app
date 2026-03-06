/// Search result model
class SearchResult {
  final String id;
  final SearchResultType type;
  final String title;
  final String titleAr;
  final String titleFr;
  final String description;
  final String descriptionAr;
  final String descriptionFr;
  final String? subjectName;
  final String? unitName;
  final double relevanceScore;
  final Map<String, dynamic> metadata;
  
  SearchResult({
    required this.id,
    required this.type,
    required this.title,
    required this.titleAr,
    required this.titleFr,
    required this.description,
    required this.descriptionAr,
    required this.descriptionFr,
    this.subjectName,
    this.unitName,
    this.relevanceScore = 1.0,
    this.metadata = const {},
  });
  
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type.toString(),
      'title': title,
      'title_ar': titleAr,
      'title_fr': titleFr,
      'description': description,
      'description_ar': descriptionAr,
      'description_fr': descriptionFr,
      'subject_name': subjectName,
      'unit_name': unitName,
      'relevance_score': relevanceScore,
      'metadata': metadata,
    };
  }
  
  factory SearchResult.fromMap(Map<String, dynamic> map) {
    return SearchResult(
      id: map['id'] ?? '',
      type: SearchResultType.values.firstWhere(
        (e) => e.toString() == map['type'],
        orElse: () => SearchResultType.lesson,
      ),
      title: map['title'] ?? '',
      titleAr: map['title_ar'] ?? '',
      titleFr: map['title_fr'] ?? '',
      description: map['description'] ?? '',
      descriptionAr: map['description_ar'] ?? '',
      descriptionFr: map['description_fr'] ?? '',
      subjectName: map['subject_name'],
      unitName: map['unit_name'],
      relevanceScore: (map['relevance_score'] ?? 1.0).toDouble(),
      metadata: map['metadata'] ?? {},
    );
  }
}

enum SearchResultType {
  lesson,     // درس
  subject,    // مادة
  unit,       // وحدة
  exercise,   // تمرين
}

/// Search filter options
class SearchFilter {
  final List<String>? subjectIds;
  final List<String>? yearIds;
  final List<SearchResultType>? types;
  final bool onlyUnlocked;
  final bool onlyCompleted;
  
  SearchFilter({
    this.subjectIds,
    this.yearIds,
    this.types,
    this.onlyUnlocked = false,
    this.onlyCompleted = false,
  });
}

/// Recent search item
class RecentSearch {
  final String query;
  final DateTime timestamp;
  
  RecentSearch({
    required this.query,
    required this.timestamp,
  });
  
  Map<String, dynamic> toMap() {
    return {
      'query': query,
      'timestamp': timestamp.toIso8601String(),
    };
  }
  
  factory RecentSearch.fromMap(Map<String, dynamic> map) {
    return RecentSearch(
      query: map['query'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
    );
  }
}

/// Popular search item
class PopularSearch {
  final String query;
  final int searchCount;
  final DateTime lastSearched;
  
  PopularSearch({
    required this.query,
    required this.searchCount,
    required this.lastSearched,
  });
}
