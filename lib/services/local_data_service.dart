import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/models.dart';

class LocalDataService {
  static Map<String, dynamic>? _cachedData;
  
  // Load seed data from assets
  static Future<Map<String, dynamic>> loadSeedData() async {
    if (_cachedData != null) return _cachedData!;
    
    try {
      final String jsonString = await rootBundle.loadString('assets/data/seed_data.json');
      _cachedData = json.decode(jsonString);
      return _cachedData!;
    } catch (e) {
      // Fallback to hardcoded data if asset not found
      return _getHardcodedData();
    }
  }
  
  static Future<List<Year>> getYears() async {
    final data = await loadSeedData();
    final years = data['years'] as List;
    return years.map((y) => Year.fromMap(y, y['id'])).toList();
  }
  
  static Future<List<Subject>> getSubjectsByYear(String yearId) async {
    final data = await loadSeedData();
    final subjects = data['subjects'] as List;
    return subjects
        .where((s) => s['yearId'] == yearId)
        .map((s) => Subject.fromMap(s, s['id']))
        .toList();
  }
  
  static Future<List<Lesson>> getLessonsBySubject(String subjectId) async {
    final data = await loadSeedData();
    final lessons = data['lessons'] as List;
    return lessons
        .where((l) => l['subjectId'] == subjectId)
        .map((l) => Lesson.fromMap(l, l['id']))
        .toList();
  }
  
  static Future<LessonContent?> getLessonContent(String lessonId) async {
    final data = await loadSeedData();
    final contents = data['lesson_contents'] as List;
    final content = contents.firstWhere(
      (c) => c['lessonId'] == lessonId,
      orElse: () => null,
    );
    if (content == null) return null;
    return LessonContent.fromMap(content, content['id']);
  }
  
  static Future<List<AdSlot>> getAdSlots(String slotName) async {
    final data = await loadSeedData();
    final adSlots = data['ad_slots'] as List;
    return adSlots
        .where((ad) => ad['slotName'] == slotName)
        .map((ad) => AdSlot.fromMap(ad, ad['id']))
        .toList();
  }
  
  static Map<String, dynamic> _getHardcodedData() {
    return {
      "years": [
        {
          "id": "year_1",
          "name": {"ar": "السنة الأولى", "fr": "Première année"},
          "order": 1,
          "isActive": true
        },
        {
          "id": "year_2",
          "name": {"ar": "السنة الثانية", "fr": "Deuxième année"},
          "order": 2,
          "isActive": true
        }
      ],
      "subjects": [
        {
          "id": "math_year1",
          "yearId": "year_1",
          "name": {"ar": "الرياضيات", "fr": "Mathématiques"},
          "iconUrl": "",
          "color": "#2196F3",
          "order": 1
        },
        {
          "id": "arabic_year1",
          "yearId": "year_1",
          "name": {"ar": "اللغة العربية", "fr": "Langue Arabe"},
          "iconUrl": "",
          "color": "#4CAF50",
          "order": 2
        }
      ],
      "lessons": [
        {
          "id": "math_lesson1",
          "unitId": "math_unit1",
          "subjectId": "math_year1",
          "title": {"ar": "الأعداد من 1 إلى 10", "fr": "Les nombres de 1 à 10"},
          "summary": {
            "ar": "في هذا الدرس سنتعلم الأعداد من 1 إلى 10 وكيفية كتابتها.",
            "fr": "Dans cette leçon, nous apprendrons les nombres de 1 à 10."
          },
          "contentLanguage": "fr",
          "order": 1
        },
        {
          "id": "math_lesson2",
          "unitId": "math_unit1",
          "subjectId": "math_year1",
          "title": {"ar": "الجمع البسيط", "fr": "Addition simple"},
          "summary": {
            "ar": "سنتعلم كيفية جمع الأعداد الصغيرة معاً.",
            "fr": "Nous apprendrons comment additionner de petits nombres."
          },
          "contentLanguage": "fr",
          "order": 2
        },
        {
          "id": "arabic_lesson1",
          "unitId": "arabic_unit1",
          "subjectId": "arabic_year1",
          "title": {"ar": "الحروف من أ إلى ج", "fr": "Les lettres de Alif à Jim"},
          "summary": {
            "ar": "سنتعلم الحروف الثلاثة الأولى من الأبجدية العربية",
            "fr": "Nous apprendrons les trois premières lettres de l'alphabet arabe"
          },
          "contentLanguage": "ar",
          "order": 1
        }
      ],
      "lesson_contents": [
        {
          "id": "content_math_lesson1",
          "lessonId": "math_lesson1",
          "sections": [
            {
              "title": "Les nombres",
              "content": "# Les nombres de 1 à 10\n\n1, 2, 3, 4, 5, 6, 7, 8, 9, 10",
              "lockedInitially": false,
              "order": 1
            }
          ],
          "exercises": [
            {
              "id": "ex1",
              "type": "mcq",
              "question": "Combien font 3 + 2?",
              "options": ["4", "5", "6", "7"],
              "correctAnswer": "1",
              "explanation": "3 + 2 = 5"
            },
            {
              "id": "ex2",
              "type": "true_false",
              "question": "Le nombre 7 vient après 6.",
              "correctAnswer": "true",
              "explanation": "C'est vrai!"
            }
          ]
        },
        {
          "id": "content_math_lesson2",
          "lessonId": "math_lesson2",
          "sections": [
            {
              "title": "Addition",
              "content": "# Addition simple\n\n1+1=2, 2+2=4",
              "lockedInitially": false,
              "order": 1
            }
          ],
          "exercises": [
            {
              "id": "ex1",
              "type": "mcq",
              "question": "Combien font 2 + 3?",
              "options": ["4", "5", "6"],
              "correctAnswer": "1",
              "explanation": "2 + 3 = 5"
            }
          ]
        },
        {
          "id": "content_arabic_lesson1",
          "lessonId": "arabic_lesson1",
          "sections": [
            {
              "title": "الحروف",
              "content": "# الحروف العربية\n\nأ، ب، ت",
              "lockedInitially": false,
              "order": 1
            }
          ],
          "exercises": [
            {
              "id": "ex1",
              "type": "true_false",
              "question": "حرف الباء يأتي بعد حرف الألف",
              "correctAnswer": "true",
              "explanation": "صحيح!"
            }
          ]
        }
      ],
      "ad_slots": [
        {
          "id": "ad_home_top",
          "slotName": "home_top",
          "imageUrl": "https://via.placeholder.com/800x200/2196F3/FFFFFF?text=Demo+Ad+Home+Top",
          "targetUrl": "https://example.com/demo",
          "enabled": true,
          "order": 1
        },
        {
          "id": "ad_home_bottom",
          "slotName": "home_bottom",
          "imageUrl": "https://via.placeholder.com/800x200/4CAF50/FFFFFF?text=Demo+Ad+Home+Bottom",
          "targetUrl": "https://example.com/demo",
          "enabled": true,
          "order": 1
        },
        {
          "id": "ad_lesson_top",
          "slotName": "lesson_top",
          "imageUrl": "https://via.placeholder.com/800x200/FF9800/FFFFFF?text=Demo+Ad+Lesson+Top",
          "targetUrl": "https://example.com/demo",
          "enabled": true,
          "order": 1
        },
        {
          "id": "ad_lesson_bottom",
          "slotName": "lesson_bottom",
          "imageUrl": "https://via.placeholder.com/800x200/9C27B0/FFFFFF?text=Demo+Ad+Lesson+Bottom",
          "targetUrl": "https://example.com/demo",
          "enabled": true,
          "order": 1
        }
      ]
    };
  }
}
