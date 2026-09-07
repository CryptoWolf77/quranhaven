import 'package:quran_library/quran_library.dart';

import '../domain/cloud_bookmark.dart';

class BookmarksBackupRepository {
  List<Map<String, Object?>> exportForCloud() => BookmarksCtrl
      .instance
      .bookmarks
      .values
      .expand((group) => group)
      .map(
        (bookmark) => CloudBookmark(
          id: bookmark.id,
          color: bookmark.colorCode,
          name: bookmark.name,
          ayahId: bookmark.ayahId,
          ayahNumber: bookmark.ayahNumber,
          page: bookmark.page,
        ).toJson(),
      )
      .toList(growable: false);

  Future<void> replace(List<CloudBookmark> bookmarks) =>
      BookmarksCtrl.instance.replaceBookmarks(
        bookmarks
            .map(
              (bookmark) => BookmarkModel(
                id: bookmark.id,
                colorCode: bookmark.color,
                name: bookmark.name,
                ayahId: bookmark.ayahId,
                ayahNumber: bookmark.ayahNumber,
                page: bookmark.page,
              ),
            )
            .toList(growable: false),
      );
}
