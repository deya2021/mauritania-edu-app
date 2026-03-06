import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/search_models.dart';
import 'dart:convert';

/// Service for smart search functionality
class SearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SharedPreferences _prefs;
  
  SearchService(this._prefs);
  
  // Keys for local storage
  static const String _recentSearchesKey = 'recent_searches';
  static const int _maxRecentSearches = 10;
  
  /// Search across lessons, subjects, and units
  Future<List<SearchResult>> search({
    required String query,
    required String userId,
    SearchFilter? filter,
    String language = 'ar',
  }) async {
    if (query.trim().isEmpty) return [];
    
    try {
      final results = <SearchResult>[];
      
      // Save to recent searches
      await _saveRecentSearch(query);
      
      // Log search for analytics
      await _logSearch(query, userId);
      
      // Search lessons
      if (filter?.types == null || 
          filter!.types!.contains(SearchResultType.lesson)) {
        final lessonResults = await _searchLessons(query, language, filter);
        results.addAll(lessonResults);
      }
      
      // Search subjects
      if (filter?.types == null || 
          filter!.types!.contains(SearchResultType.subject)) {
        final subjectResults = await _searchSubjects(query, language, filter);
        results.addAll(subjectResults);
      }
      
      // Search units
      if (filter?.types == null || 
          filter!.types!.contains(SearchResultType.unit)) {
        final unitResults = await _searchUnits(query, language, filter);
        results.addAll(unitResults);
      }
      
      // Sort by relevance score
      results.sort((a, b) => b.relevanceScore.compareTo(a.relevanceScore));
      
      return results;
    } catch (e) {
      print('❌ Error searching: $e');
      return [];
    }
  }
  
  /// Search lessons
  Future<List<SearchResult>> _searchLessons(
    String query,
    String language,
    SearchFilter? filter,
  ) async {
    try {
      final searchTerms = query.toLowerCase().split(' ');
      final results = <SearchResult>[];
      
      // Build query
      Query lessonsQuery = _firestore.collection('lessons');
      
      // Apply filters
      if (filter?.subjectIds != null && filter!.subjectIds!.isNotEmpty) {
        // Firestore doesn't support 'in' with more than 10 items
        // So we'll fetch and filter locally
      }
      
      final snapshot = await lessonsQuery.get();
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        final titleAr = (data['title_ar'] ?? '').toString().toLowerCase();
        final titleFr = (data['title_fr'] ?? '').toString().toLowerCase();
        final summaryAr = (data['summary_ar'] ?? '').toString().toLowerCase();
        final summaryFr = (data['summary_fr'] ?? '').toString().toLowerCase();
        
        // Calculate relevance score
        double score = 0.0;
        
        for (var term in searchTerms) {
          if (titleAr.contains(term) || titleFr.contains(term)) {
            score += 2.0; // Title match = higher score
          }
          if (summaryAr.contains(term) || summaryFr.contains(term)) {
            score += 1.0; // Summary match = lower score
          }
        }
        
        if (score > 0) {
          results.add(SearchResult(
            id: doc.id,
            type: SearchResultType.lesson,
            title: language == 'ar' ? data['title_ar'] : data['title_fr'],
            titleAr: data['title_ar'] ?? '',
            titleFr: data['title_fr'] ?? '',
            description: language == 'ar' ? data['summary_ar'] : data['summary_fr'],
            descriptionAr: data['summary_ar'] ?? '',
            descriptionFr: data['summary_fr'] ?? '',
            relevanceScore: score,
            metadata: {
              'lesson_id': doc.id,
              'unit_id': data['unit_id'],
              'order': data['order'],
            },
          ));
        }
      }
      
      return results;
    } catch (e) {
      print('❌ Error searching lessons: $e');
      return [];
    }
  }
  
  /// Search subjects
  Future<List<SearchResult>> _searchSubjects(
    String query,
    String language,
    SearchFilter? filter,
  ) async {
    try {
      final searchTerms = query.toLowerCase().split(' ');
      final results = <SearchResult>[];
      
      Query subjectsQuery = _firestore.collection('subjects');
      
      if (filter?.yearIds != null && filter!.yearIds!.isNotEmpty) {
        subjectsQuery = subjectsQuery.where('year_id', whereIn: filter.yearIds);
      }
      
      final snapshot = await subjectsQuery.get();
      
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        
        final nameAr = (data['name_ar'] ?? '').toString().toLowerCase();
        final nameFr = (data['name_fr'] ?? '').toString().toLowerCase();
        final descAr = (data['description_ar'] ?? '').toString().toLowerCase();
        final descFr = (data['description_fr'] ?? '').toString().toLowerCase();
        
        double score = 0.0;
        
        for (var term in searchTerms) {
          if (nameAr.contains(term) || nameFr.contains(term)) {
            score += 3.0; // Subject name match = highest score
          }
          if (descAr.contains(term) || descFr.contains(term)) {
            score += 1.0;
          }
        }
        
        if (score > 0) {
          results.add(SearchResult(
            id: doc.id,
            type: SearchResultType.subject,
            title: language == 'ar' ? data['name_ar'] : data['name_fr'],
            titleAr: data['name_ar'] ?? '',
            titleFr: data['name_fr'] ?? '',
            description: language == 'ar' 
              ? (data['description_ar'] ?? '') 
              : (data['description_fr'] ?? ''),
            descriptionAr: data['description_ar'] ?? '',
            descriptionFr: data['description_fr'] ?? '',
            relevanceScore: score,
            metadata: {
              'subject_id': doc.id,
              'year_id': data['year_id'],
              'icon': data['icon'],
            },
          ));
        }
      }
      
      return results;
    } catch (e) {
      print('❌ Error searching subjects: $e');
      return [];
    }
  }
  
  /// Search units
  Future<List<SearchResult>> _searchUnits(
    String query,
    String language,
    SearchFilter? filter,
  ) async {
    try {
      final searchTerms = query.toLowerCase().split(' ');
      final results = <SearchResult>[];
      
      final snapshot = await _firestore.collection('units').get();
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        final titleAr = (data['title_ar'] ?? '').toString().toLowerCase();
        final titleFr = (data['title_fr'] ?? '').toString().toLowerCase();
        final descAr = (data['description_ar'] ?? '').toString().toLowerCase();
        final descFr = (data['description_fr'] ?? '').toString().toLowerCase();
        
        double score = 0.0;
        
        for (var term in searchTerms) {
          if (titleAr.contains(term) || titleFr.contains(term)) {
            score += 2.5;
          }
          if (descAr.contains(term) || descFr.contains(term)) {
            score += 1.0;
          }
        }
        
        if (score > 0) {
          results.add(SearchResult(
            id: doc.id,
            type: SearchResultType.unit,
            title: language == 'ar' ? data['title_ar'] : data['title_fr'],
            titleAr: data['title_ar'] ?? '',
            titleFr: data['title_fr'] ?? '',
            description: language == 'ar' 
              ? (data['description_ar'] ?? '') 
              : (data['description_fr'] ?? ''),
            descriptionAr: data['description_ar'] ?? '',
            descriptionFr: data['description_fr'] ?? '',
            relevanceScore: score,
            metadata: {
              'unit_id': doc.id,
              'subject_id': data['subject_id'],
              'order': data['order'],
            },
          ));
        }
      }
      
      return results;
    } catch (e) {
      print('❌ Error searching units: $e');
      return [];
    }
  }
  
  /// Get search suggestions
  Future<List<String>> getSuggestions(String query) async {
    if (query.trim().isEmpty) return [];
    
    try {
      final suggestions = <String>[];
      final lowerQuery = query.toLowerCase();
      
      // Get recent searches that match
      final recentSearches = await getRecentSearches();
      for (var search in recentSearches) {
        if (search.query.toLowerCase().contains(lowerQuery)) {
          suggestions.add(search.query);
        }
      }
      
      // Get popular searches (from Firestore)
      // TODO: Implement popular searches tracking
      
      return suggestions.take(5).toList();
    } catch (e) {
      print('❌ Error getting suggestions: $e');
      return [];
    }
  }
  
  /// Save recent search
  Future<void> _saveRecentSearch(String query) async {
    try {
      final recentSearches = await getRecentSearches();
      
      // Remove if already exists
      recentSearches.removeWhere((s) => s.query == query);
      
      // Add to beginning
      recentSearches.insert(0, RecentSearch(
        query: query,
        timestamp: DateTime.now(),
      ));
      
      // Keep only max items
      if (recentSearches.length > _maxRecentSearches) {
        recentSearches.removeRange(_maxRecentSearches, recentSearches.length);
      }
      
      // Save to local storage
      final jsonList = recentSearches.map((s) => s.toMap()).toList();
      await _prefs.setString(_recentSearchesKey, json.encode(jsonList));
    } catch (e) {
      print('❌ Error saving recent search: $e');
    }
  }
  
  /// Get recent searches
  Future<List<RecentSearch>> getRecentSearches() async {
    try {
      final jsonString = _prefs.getString(_recentSearchesKey);
      if (jsonString == null) return [];
      
      final jsonList = json.decode(jsonString) as List;
      return jsonList
        .map((item) => RecentSearch.fromMap(item))
        .toList();
    } catch (e) {
      print('❌ Error getting recent searches: $e');
      return [];
    }
  }
  
  /// Clear recent searches
  Future<void> clearRecentSearches() async {
    try {
      await _prefs.remove(_recentSearchesKey);
    } catch (e) {
      print('❌ Error clearing recent searches: $e');
    }
  }
  
  /// Log search for analytics
  Future<void> _logSearch(String query, String userId) async {
    try {
      await _firestore.collection('search_logs').add({
        'query': query,
        'user_id': userId,
        'timestamp': Timestamp.now(),
      });
      
      // Update popular searches
      final docRef = _firestore
        .collection('popular_searches')
        .doc(query.toLowerCase());
      
      final doc = await docRef.get();
      
      if (doc.exists) {
        await docRef.update({
          'search_count': FieldValue.increment(1),
          'last_searched': Timestamp.now(),
        });
      } else {
        await docRef.set({
          'query': query,
          'search_count': 1,
          'last_searched': Timestamp.now(),
        });
      }
    } catch (e) {
      print('❌ Error logging search: $e');
    }
  }
  
  /// Get popular searches
  Future<List<PopularSearch>> getPopularSearches({int limit = 10}) async {
    try {
      final snapshot = await _firestore
        .collection('popular_searches')
        .orderBy('search_count', descending: true)
        .limit(limit)
        .get();
      
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return PopularSearch(
          query: data['query'] ?? '',
          searchCount: data['search_count'] ?? 0,
          lastSearched: (data['last_searched'] as Timestamp).toDate(),
        );
      }).toList();
    } catch (e) {
      print('❌ Error getting popular searches: $e');
      return [];
    }
  }
}
