import 'dart:convert';
import 'personal_models.dart';

/// First strong script determines content direction, independently of UI locale.
bool isRtlResourceText(String text) {
  final rtl = RegExp(
    r'[\u05d0-\u05ea\u0620-\u064a\u066e-\u06d3\u0750-\u077f\u08a0-\u08c9]',
  ).firstMatch(text);
  final ltr = RegExp(
    r'[A-Za-z\u00c0-\u02af\u0370-\u058f\u0900-\u1fff]',
  ).firstMatch(text);
  return rtl != null && (ltr == null || rtl.start < ltr.start);
}

String plainResourceText(String value) {
  final stripped = value.replaceAll(RegExp(r'<[^>]*>'), ' ');
  return stripped
      .replaceAllMapped(
        RegExp(r'&(#x[0-9a-fA-F]+|#\d+|amp|lt|gt|quot|apos|nbsp);'),
        (m) {
          final key = m[1]!;
          if (key.startsWith('#')) {
            final code = int.tryParse(
              key.substring(key.startsWith('#x') ? 2 : 1),
              radix: key.startsWith('#x') ? 16 : 10,
            );
            if (code != null &&
                code > 0 &&
                code <= 0x10ffff &&
                !(code >= 0xd800 && code <= 0xdfff)) {
              return String.fromCharCode(code);
            }
            return '';
          }
          return const {
            'amp': '&',
            'lt': '<',
            'gt': '>',
            'quot': '"',
            'apos': "'",
            'nbsp': ' ',
          }[key]!;
        },
      )
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();
}

String normalizeSearch(String text) => plainResourceText(text)
    .toLowerCase()
    .replaceAll(
      RegExp(r'[\u0610-\u061a\u064b-\u065f\u0670\u06d6-\u06ed\u0640]'),
      '',
    )
    .replaceAll(RegExp('[أإآٱ]'), 'ا')
    .replaceAll('ى', 'ي')
    .replaceAll(RegExp(r'\s+'), ' ')
    .trim();

class SavedTextEntry {
  const SavedTextEntry(this.reference, this.text);
  final AyahReference reference;
  final String text;
}

List<SavedTextEntry> parseSavedBook(String source) {
  final decoded = jsonDecode(source);
  final results = <SavedTextEntry>[];
  void add(Object? surah, Object? ayah, Object? text) {
    if (surah is! int || ayah is! int || text is! String) return;
    final ref = AyahReference(surah, ayah);
    final clean = plainResourceText(text);
    if (ref.isValid && clean.isNotEmpty) {
      results.add(SavedTextEntry(ref, clean));
    }
  }

  if (decoded is List) {
    for (final row in decoded) {
      if (row is Map) add(row['sura'], row['aya'], row['text']);
    }
  } else if (decoded is Map) {
    for (final entry in decoded.entries) {
      final parts = entry.key.toString().split(':');
      if (parts.length != 2) continue;
      final row = entry.value is String ? decoded[entry.value] : entry.value;
      if (row is Map) {
        add(
          int.tryParse(parts[0]),
          int.tryParse(parts[1]),
          row['t'] ?? row['text'],
        );
      }
    }
  } else {
    throw const FormatException('Invalid saved book');
  }
  results.sort(
    (a, b) => a.reference.surah == b.reference.surah
        ? a.reference.ayah.compareTo(b.reference.ayah)
        : a.reference.surah.compareTo(b.reference.surah),
  );
  return results;
}

List<SavedTextEntry> searchSavedBook(
  List<SavedTextEntry> corpus,
  String query,
) {
  final normalized = normalizeSearch(query);
  if (normalized.length < 2) return [];
  return corpus
      .where((entry) => normalizeSearch(entry.text).contains(normalized))
      .toList();
}
