import '../../plans/data/plans_repository.dart';
import '../domain/cloud_restore_snapshot.dart';
import '../domain/reading_preferences.dart';
import 'bookmarks_backup_repository.dart';

class CloudRestoreService {
  CloudRestoreService({
    required this.plans,
    BookmarksBackupRepository? bookmarks,
  }) : bookmarks = bookmarks ?? BookmarksBackupRepository();

  final PlansRepository plans;
  final BookmarksBackupRepository bookmarks;

  Future<void> restore({
    required Map<String, Object?> data,
    required ReadingPreferences currentPreferences,
    required int Function(int surah) ayahsInSurah,
    int Function(int ayahId)? pageForAyah,
    required Future<void> Function(ReadingPreferences) onPreferencesRestored,
    required void Function(int? page) onProgressRestored,
  }) async {
    // No disk write or callback can happen until every included field is valid.
    final snapshot = CloudRestoreSnapshot.parse(
      data,
      currentPreferences: currentPreferences,
      ayahsInSurah: ayahsInSurah,
      pageForAyah: pageForAyah,
    );
    final restoredBookmarks = snapshot.bookmarks;
    if (restoredBookmarks != null) await bookmarks.replace(restoredBookmarks);
    if (snapshot.hasKhatmah) {
      final plan = snapshot.khatmah;
      if (plan == null) {
        await plans.deleteKhatmah();
      } else {
        await plans.saveKhatmah(plan);
      }
    }
    final memorization = snapshot.memorization;
    if (memorization != null) await plans.saveMemorizationPlans(memorization);
    final preferences = snapshot.preferences;
    if (preferences != null) await onPreferencesRestored(preferences);
    onProgressRestored(snapshot.page);
  }
}
