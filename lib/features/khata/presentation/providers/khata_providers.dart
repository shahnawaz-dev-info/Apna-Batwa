import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/database_provider.dart';
import '../../data/repositories/khata_repository_impl.dart';
import '../../domain/entities/borrowed_record.dart';
import '../../domain/entities/lent_record.dart';
import '../../domain/entities/person.dart';
import '../../domain/entities/repayment.dart';
import '../../domain/repositories/khata_repository.dart';
import '../../domain/usecases/khata_usecases.dart';

final khataRepositoryProvider = Provider<KhataRepository>((ref) {
  final db = ref.watch(databaseProvider);
  return KhataRepositoryImpl(db);
});

final watchAllPersonsProvider = StreamProvider<List<PersonEntity>>((ref) {
  final repo = ref.watch(khataRepositoryProvider);
  return WatchAllPersons(repo)();
});

final watchAllBorrowedRecordsProvider = StreamProvider<List<BorrowedRecordEntity>>((ref) {
  final repo = ref.watch(khataRepositoryProvider);
  return WatchAllBorrowedRecords(repo)();
});

final watchAllLentRecordsProvider = StreamProvider<List<LentRecordEntity>>((ref) {
  final repo = ref.watch(khataRepositoryProvider);
  return WatchAllLentRecords(repo)();
});

class RepaymentRecordParam {
  final String recordType;
  final int recordId;

  const RepaymentRecordParam({required this.recordType, required this.recordId});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RepaymentRecordParam &&
          runtimeType == other.runtimeType &&
          recordType == other.recordType &&
          recordId == other.recordId;

  @override
  int get hashCode => recordType.hashCode ^ recordId.hashCode;
}

final watchRepaymentsForRecordProvider =
    StreamProvider.family<List<RepaymentEntity>, RepaymentRecordParam>((ref, arg) {
  final repo = ref.watch(khataRepositoryProvider);
  return WatchRepaymentsForRecord(repo)(
    recordType: arg.recordType,
    recordId: arg.recordId,
  );
});

final totalYouOweCentsProvider = Provider<int>((ref) {
  final borrowedAsync = ref.watch(watchAllBorrowedRecordsProvider);
  return borrowedAsync.maybeWhen(
    data: (list) => list.fold<int>(0, (sum, item) => sum + item.remainingCents),
    orElse: () => 0,
  );
});

final totalOthersOweYouCentsProvider = Provider<int>((ref) {
  final lentAsync = ref.watch(watchAllLentRecordsProvider);
  return lentAsync.maybeWhen(
    data: (list) => list.fold<int>(0, (sum, item) => sum + item.remainingCents),
    orElse: () => 0,
  );
});

class KhataSummaryData {
  final int totalBorrowedCents;
  final int totalLentCents;

  KhataSummaryData({required this.totalBorrowedCents, required this.totalLentCents});

  int get netBalanceCents => totalLentCents - totalBorrowedCents;
}

final khataSummaryProvider = Provider<AsyncValue<KhataSummaryData>>((ref) {
  final borrowedAsync = ref.watch(watchAllBorrowedRecordsProvider);
  final lentAsync = ref.watch(watchAllLentRecordsProvider);

  if (borrowedAsync is AsyncLoading || lentAsync is AsyncLoading) {
    return const AsyncValue.loading();
  }

  if (borrowedAsync is AsyncError) {
    return AsyncValue.error(borrowedAsync.error!, borrowedAsync.stackTrace!);
  }

  if (lentAsync is AsyncError) {
    return AsyncValue.error(lentAsync.error!, lentAsync.stackTrace!);
  }

  final borrowedList = borrowedAsync.value ?? [];
  final lentList = lentAsync.value ?? [];

  final totalBorrowed = borrowedList.fold<int>(0, (sum, item) => sum + item.remainingCents);
  final totalLent = lentList.fold<int>(0, (sum, item) => sum + item.remainingCents);

  return AsyncValue.data(KhataSummaryData(
    totalBorrowedCents: totalBorrowed,
    totalLentCents: totalLent,
  ));
});

