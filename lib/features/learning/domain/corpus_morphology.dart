import '../../personal/domain/personal_models.dart';

const corpusAsset = 'assets/learning/quranic-corpus-morphology-0.4.txt';
const corpusLicenseAsset = 'assets/learning/COPYING-GPL-3.0.txt';
const corpusSha256 =
    'a1d12923815341face765083805d2148ed2d9f5cc3f7d6665219d887675d8c46';
const corpusByteCount = 6309503;
const corpusSegmentCount = 128219;
const corpusWordCount = 77429;

/// Exact reversible extended mapping documented by JQuranTree. Unrecognized
/// characters remain unchanged, so unknown source notation is never invented.
const extendedBuckwalter = <String, String>{
  "'": '\u0621',
  '>': '\u0623',
  '&': '\u0624',
  '<': '\u0625',
  '}': '\u0626',
  'A': '\u0627',
  'b': '\u0628',
  'p': '\u0629',
  't': '\u062a',
  'v': '\u062b',
  'j': '\u062c',
  'H': '\u062d',
  'x': '\u062e',
  'd': '\u062f',
  '*': '\u0630',
  'r': '\u0631',
  'z': '\u0632',
  's': '\u0633',
  r'$': '\u0634',
  'S': '\u0635',
  'D': '\u0636',
  'T': '\u0637',
  'Z': '\u0638',
  'E': '\u0639',
  'g': '\u063a',
  '_': '\u0640',
  'f': '\u0641',
  'q': '\u0642',
  'k': '\u0643',
  'l': '\u0644',
  'm': '\u0645',
  'n': '\u0646',
  'h': '\u0647',
  'w': '\u0648',
  'Y': '\u0649',
  'y': '\u064a',
  'F': '\u064b',
  'N': '\u064c',
  'K': '\u064d',
  'a': '\u064e',
  'u': '\u064f',
  'i': '\u0650',
  '~': '\u0651',
  'o': '\u0652',
  '^': '\u0653',
  '#': '\u0654',
  '`': '\u0670',
  '{': '\u0671',
  ':': '\u06dc',
  '@': '\u06df',
  '"': '\u06e0',
  '[': '\u06e2',
  ';': '\u06e3',
  ',': '\u06e5',
  '.': '\u06e6',
  '!': '\u06e8',
  '-': '\u06ea',
  '+': '\u06eb',
  '%': '\u06ec',
  ']': '\u06ed',
};
String decodeCorpusForm(String form) =>
    form.split('').map((c) => extendedBuckwalter[c] ?? c).join();
String encodeCorpusForm(String form) {
  final reverse = extendedBuckwalter.map((a, b) => MapEntry(b, a));
  return form.split('').map((c) => reverse[c] ?? c).join();
}

class CorpusSegment {
  const CorpusSegment({
    required this.reference,
    required this.wordNumber,
    required this.segmentNumber,
    required this.form,
    required this.tag,
    required this.features,
  });
  final AyahReference reference;
  final int wordNumber, segmentNumber;
  final String form, tag, features;
  String get arabic => decodeCorpusForm(form);
  List<String> get codes => features.split('|');
  String? feature(String prefix) => codes
      .where((f) => f.startsWith('$prefix:'))
      .firstOrNull
      ?.substring(prefix.length + 1);
  String? get root => feature('ROOT');
  String? get lemma => feature('LEM');
  static final _location = RegExp(
    r'^\(([1-9]\d*):([1-9]\d*):([1-9]\d*):([1-9]\d*)\)$',
  );
  factory CorpusSegment.parse(String raw) {
    final columns = raw.split('\t');
    if (columns.length != 4) throw const FormatException('Invalid Corpus row');
    final match = _location.firstMatch(columns[0]);
    if (match == null) throw const FormatException('Invalid Corpus location');
    final s = int.parse(match[1]!),
        a = int.parse(match[2]!),
        w = int.parse(match[3]!),
        seg = int.parse(match[4]!);
    final ref = AyahReference(s, a);
    if (!ref.isValid ||
        w > 1000 ||
        seg > 20 ||
        (columns[1].isEmpty &&
            !(columns[2] == 'PRON' && columns[3] == 'SUFFIX|PRON:1S')) ||
        columns[1].length > 200 ||
        !RegExp(r'^[A-Z]{1,10}$').hasMatch(columns[2]) ||
        columns[3].isEmpty ||
        columns[3].length > 500 ||
        columns[3].split('|').length > 40) {
      throw const FormatException('Invalid Corpus segment');
    }
    return CorpusSegment(
      reference: ref,
      wordNumber: w,
      segmentNumber: seg,
      form: columns[1],
      tag: columns[2],
      features: columns[3],
    );
  }
}

class CorpusWord {
  const CorpusWord(this.number, this.segments);
  final int number;
  final List<CorpusSegment> segments;
  String get form => segments.map((s) => s.form).join();
  String get arabic => decodeCorpusForm(form);
}

class _CorpusSlice {
  const _CorpusSlice(this.start, this.end);
  final int start, end;
}

/// Keeps the original TSV in memory plus 6,236 short range records. Only the
/// requested Ayah's segment objects are retained/rendered, not 128,219 cards.
class CorpusIndex {
  const CorpusIndex._(
    this._raw,
    this._verses,
    this.notices,
    this.segmentCount,
    this.wordCount,
  );
  final String _raw, notices;
  final Map<String, _CorpusSlice> _verses;
  final int segmentCount, wordCount;
  int get ayahCount => _verses.length;
  factory CorpusIndex.parse(String raw, {bool requireComplete = true}) {
    if (raw.length > 7 * 1024 * 1024) {
      throw const FormatException('Corpus exceeds bound');
    }
    final verses = <String, _CorpusSlice>{};
    var offset = 0,
        firstData = -1,
        verseStart = 0,
        lastSurah = 0,
        lastAyah = 0,
        lastWord = 0,
        lastSegment = 0,
        segments = 0,
        words = 0;
    bool header = false;
    while (offset < raw.length) {
      final newline = raw.indexOf('\n', offset),
          end = newline < 0 ? raw.length : newline;
      final line = raw.substring(offset, end).replaceFirst(RegExp(r'\r$'), '');
      final next = newline < 0 ? raw.length : newline + 1;
      if (line.isEmpty || line.startsWith('#')) {
        offset = next;
        continue;
      }
      if (line == 'LOCATION\tFORM\tTAG\tFEATURES') {
        if (header || firstData >= 0) {
          throw const FormatException('Duplicate Corpus header');
        }
        header = true;
        offset = next;
        continue;
      }
      if (!header) throw const FormatException('Missing Corpus header');
      final row = CorpusSegment.parse(line);
      final ref = row.reference;
      if (ref.surah != lastSurah || ref.ayah != lastAyah) {
        if (row.wordNumber != 1 || row.segmentNumber != 1) {
          throw const FormatException('Corpus word/segment gap');
        }
        if (lastSurah > 0) {
          verses['$lastSurah:$lastAyah'] = _CorpusSlice(verseStart, offset);
          if (requireComplete) {
            final nextSurah = lastAyah == hafsAyahCounts[lastSurah - 1]
                ? lastSurah + 1
                : lastSurah;
            final nextAyah = nextSurah == lastSurah ? lastAyah + 1 : 1;
            if (ref.surah != nextSurah || ref.ayah != nextAyah) {
              throw const FormatException('Corpus verse gap');
            }
          }
        } else if (requireComplete && ref.key != '1:1') {
          throw const FormatException('Missing first Ayah');
        }
        if (verses.containsKey(ref.key)) {
          throw const FormatException('Duplicate Corpus Ayah');
        }
        verseStart = offset;
        lastSurah = ref.surah;
        lastAyah = ref.ayah;
        lastWord = 0;
        lastSegment = 0;
      }
      if (row.wordNumber == lastWord) {
        if (row.segmentNumber != lastSegment + 1) {
          throw const FormatException('Duplicate or missing segment');
        }
      } else {
        if (row.wordNumber != lastWord + 1 || row.segmentNumber != 1) {
          throw const FormatException('Corpus word gap');
        }
        words++;
      }
      firstData = firstData < 0 ? offset : firstData;
      lastWord = row.wordNumber;
      lastSegment = row.segmentNumber;
      segments++;
      offset = next;
    }
    if (firstData < 0 || segments == 0) {
      throw const FormatException('Empty Corpus');
    }
    verses['$lastSurah:$lastAyah'] = _CorpusSlice(verseStart, raw.length);
    if (requireComplete &&
        (verses.length != 6236 ||
            lastSurah != 114 ||
            lastAyah != 6 ||
            words != corpusWordCount ||
            segments != corpusSegmentCount)) {
      throw const FormatException('Incomplete Corpus');
    }
    final headerEnd = raw.indexOf('LOCATION\tFORM\tTAG\tFEATURES');
    return CorpusIndex._(
      raw,
      Map.unmodifiable(verses),
      raw.substring(0, headerEnd).trimRight(),
      segments,
      words,
    );
  }
  List<CorpusWord> wordsFor(AyahReference ref) {
    final slice = _verses[ref.key];
    if (slice == null) throw const FormatException('Ayah absent from Corpus');
    final rows = _raw
        .substring(slice.start, slice.end)
        .split('\n')
        .map((r) => r.replaceFirst(RegExp(r'\r$'), ''))
        .where((r) => r.isNotEmpty && !r.startsWith('#'))
        .map(CorpusSegment.parse);
    final words = <CorpusWord>[];
    for (final row in rows) {
      if (words.isEmpty || words.last.number != row.wordNumber) {
        words.add(CorpusWord(row.wordNumber, []));
      }
      words.last.segments.add(row);
    }
    return words;
  }
}
