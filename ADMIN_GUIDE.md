# Admin Guide - Mauritania Educational App

## Table of Contents
1. [Firebase Console Access](#firebase-console-access)
2. [Managing Ad Slots](#managing-ad-slots)
3. [Managing Content](#managing-content)
4. [User Management](#user-management)
5. [Monitoring & Analytics](#monitoring--analytics)

---

## Firebase Console Access

### Initial Setup
1. Navigate to [Firebase Console](https://console.firebase.google.com)
2. Select your project: `mauritania-edu-app`
3. Main sections you'll use:
   - **Authentication** - View user login data
   - **Firestore Database** - Manage all content
   - **Analytics** (if enabled) - View usage statistics

---

## Managing Ad Slots

### Viewing Current Ads
1. Go to **Firestore Database**
2. Click on `ad_slots` collection
3. View all active ad configurations

### Adding a New Ad

1. Click **Add Document** in `ad_slots` collection
2. Set **Document ID**: Auto-ID or custom (e.g., `ad_home_top_2`)
3. Add fields:

```
Field Name       | Type      | Value
-----------------|-----------|----------------------------------
slotName         | string    | home_top / home_bottom / 
                 |           | lesson_top / lesson_bottom
imageUrl         | string    | https://your-cdn.com/banner.jpg
targetUrl        | string    | https://advertiser-website.com
enabled          | boolean   | true
startDate        | timestamp | (optional) Ad start date
endDate          | timestamp | (optional) Ad end date
order            | number    | 1 (display priority)
```

### Ad Slot Names
- **home_top**: Top banner on home screen
- **home_bottom**: Bottom banner on home screen
- **lesson_top**: Top banner on lesson detail screen
- **lesson_bottom**: Bottom banner on lesson detail screen

### Editing an Ad
1. Click on the ad document in Firestore
2. Click **Edit** (pencil icon)
3. Modify fields as needed
4. Click **Update**

### Disabling an Ad (Without Deleting)
1. Open the ad document
2. Change `enabled` field to `false`
3. The ad will no longer display in the app

### Best Practices
- **Image Size**: Use 800x200px images (4:1 ratio)
- **File Format**: JPG or PNG
- **CDN**: Host images on a reliable CDN or Firebase Storage
- **Testing**: Always test ads in the app before going live
- **Timing**: Use startDate/endDate for scheduled campaigns

---

## Managing Content

### Content Hierarchy
```
Year → Subject → Unit → Lesson → Lesson Content (Sections + Exercises)
```

### Adding a New Year

1. Go to `years` collection
2. Click **Add Document**
3. Set fields:

```json
{
  "id": "year_3",
  "name": {
    "ar": "السنة الثالثة",
    "fr": "Troisième année"
  },
  "order": 3,
  "isActive": true
}
```

### Adding a New Subject

1. Go to `subjects` collection
2. Click **Add Document**
3. Set fields:

```json
{
  "id": "physics_year2",
  "yearId": "year_2",
  "name": {
    "ar": "الفيزياء",
    "fr": "Physique"
  },
  "iconUrl": "https://cdn.example.com/physics-icon.png",
  "color": "#9C27B0",
  "order": 3
}
```

**Color Palette Suggestions:**
- Math: `#2196F3` (Blue)
- Science: `#4CAF50` (Green)
- Arabic: `#FF9800` (Orange)
- French: `#9C27B0` (Purple)
- History: `#795548` (Brown)
- Geography: `#00BCD4` (Cyan)

### Adding a New Lesson

1. Go to `lessons` collection
2. Add document with structure:

```json
{
  "id": "physics_lesson1",
  "unitId": "physics_unit1",
  "subjectId": "physics_year2",
  "title": {
    "ar": "مقدمة في الفيزياء",
    "fr": "Introduction à la Physique"
  },
  "summary": {
    "ar": "نظرة عامة على علم الفيزياء...",
    "fr": "Aperçu de la science physique..."
  },
  "contentLanguage": "fr",
  "order": 1
}
```

### Adding Lesson Content

1. Go to `lesson_contents` collection
2. Add document (use provided template):

```json
{
  "id": "content_physics_lesson1",
  "lessonId": "physics_lesson1",
  "sections": [
    {
      "title": "Introduction",
      "content": "# Physics Basics\n\nMarkdown content here...",
      "lockedInitially": false,
      "order": 1
    }
  ],
  "exercises": [
    {
      "id": "ex1",
      "type": "mcq",
      "question": "What is Physics?",
      "options": ["Study of matter", "Study of life", "Study of earth"],
      "correctAnswer": "0",
      "explanation": "Physics studies matter and energy."
    }
  ]
}
```

### Markdown Formatting in Content

Supported markdown syntax:
- `# Heading 1`, `## Heading 2`, `### Heading 3`
- `**bold text**`
- `*italic text*`
- `- Bullet point`
- `1. Numbered list`
- `` `code` ``
- `[Link text](https://url.com)`

### Exercise Types

**Multiple Choice (MCQ):**
```json
{
  "id": "ex1",
  "type": "mcq",
  "question": "Question text?",
  "options": ["Option A", "Option B", "Option C", "Option D"],
  "correctAnswer": "0",
  "explanation": "Correct answer is A because..."
}
```
*Note: correctAnswer is the index (0, 1, 2, 3)*

**True/False:**
```json
{
  "id": "ex2",
  "type": "true_false",
  "question": "Statement to evaluate.",
  "correctAnswer": "true",
  "explanation": "This is true because..."
}
```
*Note: correctAnswer must be "true" or "false" (lowercase string)*

---

## User Management

### Viewing Users

1. Go to **Authentication** section
2. Click **Users** tab
3. View all registered phone numbers

### Viewing User Progress

1. Go to **Firestore Database**
2. Click `user_progress` collection
3. Document ID format: `{userId}_{subjectId}`
4. View:
   - Unlocked lessons
   - Completion percentages
   - Last activity timestamps

### Resetting User Progress (If Needed)

1. Find user's progress document
2. Click document
3. Edit or delete as needed
4. ⚠️ **Warning**: This action cannot be undone

---

## Monitoring & Analytics

### Daily Checks

1. **Active Users**: Authentication → Users
2. **Lesson Completion**: Query `user_progress` collection
3. **Ad Performance**: Check targetUrl click patterns
4. **Error Logs**: Check Firebase Console → Crashlytics (if enabled)

### Key Metrics to Track

- Total registered users
- Daily active users
- Lessons completed per day
- Average time per lesson
- Subject popularity
- Ad click-through rates

### Exporting Data

1. Go to Firestore collection
2. Use Firebase CLI for bulk export:
```bash
firebase firestore:export gs://your-bucket/backup-folder
```

---

## Common Admin Tasks

### Scheduling Seasonal Content

1. Create lessons for new semester
2. Set appropriate `order` values
3. Enable gradually as curriculum progresses

### Running Promotional Campaigns

1. Create ad with specific startDate/endDate
2. Target specific ad slots
3. Monitor engagement through targetUrl

### Handling Content Errors

If users report content issues:
1. Locate lesson in Firestore
2. Edit `lesson_contents` document
3. Fix markdown or exercise data
4. Changes reflect immediately in app

### Bulk Updates

For mass updates, use Firebase CLI or admin SDK scripts.

Example Python script structure:
```python
import firebase_admin
from firebase_admin import firestore

# Initialize
firebase_admin.initialize_app()
db = firestore.client()

# Update all subjects in year_1
subjects_ref = db.collection('subjects')
query = subjects_ref.where('yearId', '==', 'year_1')

for doc in query.stream():
    doc.reference.update({'isActive': True})
```

---

## Troubleshooting

### Ad Not Displaying
- Check `enabled` field is `true`
- Verify imageUrl is accessible
- Check startDate/endDate validity
- Ensure slotName matches expected values

### Lesson Not Unlocking
- Check user_progress document exists
- Verify lesson order is correct
- Check if 24-hour rule applies
- Verify dailyUnlockCount hasn't exceeded limit

### Content Not Appearing
- Confirm lessonId in lesson_contents matches lesson document
- Check content language matches lesson.contentLanguage
- Verify no syntax errors in markdown

---

## Security Best Practices

1. **Never share Firebase credentials publicly**
2. **Use service accounts for automated scripts**
3. **Regularly review Firestore security rules**
4. **Monitor authentication logs for suspicious activity**
5. **Keep backup of all content before bulk edits**

---

## Support Contacts

- **Technical Issues**: [dev-email@example.com]
- **Content Questions**: [content-team@example.com]
- **Emergency**: [emergency-contact]

---

**Admin Guide Version**: 1.0  
**Last Updated**: 2026-01-07
