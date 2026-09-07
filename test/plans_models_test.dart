import 'package:flutter_test/flutter_test.dart';
import 'package:quran_flutter/features/plans/domain/plans_models.dart';

void main() {
  group('KhatmahPlan', () {
    test('calculates the daily target from the remaining pages', () {
      final plan = KhatmahPlan(
        startedAt: DateTime(2026, 7, 1),
        targetDate: DateTime(2026, 7, 30),
        completedPages: 4,
      );

      expect(plan.remainingPages, 600);
      expect(plan.pagesPerDayOn(DateTime(2026, 7, 1)), 20);
      expect(plan.progress, closeTo(4 / 604, 0.0001));
    });

    test('round-trips through local JSON data', () {
      final original = KhatmahPlan(
        startedAt: DateTime(2026, 7, 1),
        targetDate: DateTime(2026, 8, 29),
        completedPages: 80,
        isPaused: true,
      );

      final restored = KhatmahPlan.fromJson(original.toJson());

      expect(restored.completedPages, 80);
      expect(restored.isPaused, isTrue);
      expect(restored.targetDate, original.targetDate);
    });
  });

  group('MemorizationPlan', () {
    test('marks the current Ayah and advances within the range', () {
      const plan = MemorizationPlan(
        id: 'test',
        surahNumber: 1,
        startAyah: 1,
        endAyah: 3,
        currentAyah: 1,
        repetitions: 5,
        rangeRepetitions: 1,
        delaySeconds: 2,
        hideAyah: false,
      );

      final updated = plan.markCurrentMemorized();

      expect(updated.memorizedAyahs, {1});
      expect(updated.currentAyah, 2);
      expect(updated.progress, closeTo(1 / 3, 0.0001));
    });

    test('persists repetition and revision settings', () {
      const original = MemorizationPlan(
        id: 'test',
        surahNumber: 2,
        startAyah: 255,
        endAyah: 257,
        currentAyah: 256,
        repetitions: 10,
        rangeRepetitions: 3,
        delaySeconds: 5,
        hideAyah: true,
        memorizedAyahs: {255},
        revisionAyahs: {256},
      );

      final restored = MemorizationPlan.fromJson(original.toJson());

      expect(restored.repetitions, 10);
      expect(restored.rangeRepetitions, 3);
      expect(restored.memorizedAyahs, {255});
      expect(restored.revisionAyahs, {256});
    });
  });
}
