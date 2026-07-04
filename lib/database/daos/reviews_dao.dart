import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/reviews_table.dart';

part 'reviews_dao.g.dart';

@DriftAccessor(tables: [ReviewsTable])
class ReviewsDao extends DatabaseAccessor<AppDatabase> with _$ReviewsDaoMixin {
  ReviewsDao(super.db);

  Future<List<ReviewsTableData>> getByTarget(
      String targetType, String targetId) =>
      (select(reviewsTable)
            ..where((t) =>
                t.targetType.equals(targetType) &
                t.targetId.equals(targetId))
            ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
          .get();

  Future<void> insertReview(ReviewsTableCompanion review) async {
    await into(reviewsTable).insertOnConflictUpdate(review);
  }

  Future<void> deleteById(String id) async {
    (delete(reviewsTable)..where((t) => t.id.equals(id))).go();
  }
}
