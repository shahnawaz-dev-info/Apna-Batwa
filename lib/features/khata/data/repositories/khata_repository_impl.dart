import 'dart:async';
import 'package:drift/drift.dart';
import '../../../../data/local/app_database.dart';
import '../../domain/entities/borrowed_record.dart';
import '../../domain/entities/lent_record.dart';
import '../../domain/entities/person.dart';
import '../../domain/entities/repayment.dart';
import '../../domain/repositories/khata_repository.dart';

class KhataRepositoryImpl implements KhataRepository {
  final AppDatabase _db;

  KhataRepositoryImpl(this._db);

  DebtStatus _calculateStatus(int remainingCents, int totalAmountCents) {
    if (remainingCents < 0) {
      return DebtStatus.overpaid;
    } else if (remainingCents == 0) {
      return DebtStatus.fullyPaid;
    } else if (remainingCents >= totalAmountCents) {
      return DebtStatus.pending;
    } else {
      return DebtStatus.partiallyPaid;
    }
  }

  Stream<T> _combineStreams<A, B, T>(
    Stream<A> streamA,
    Stream<B> streamB,
    T Function(A a, B b) combiner,
  ) {
    final controller = StreamController<T>();
    A? latestA;
    B? latestB;
    bool hasA = false;
    bool hasB = false;

    StreamSubscription<A>? subA;
    StreamSubscription<B>? subB;

    void emitIfReady() {
      if (hasA && hasB && !controller.isClosed) {
        controller.add(combiner(latestA as A, latestB as B));
      }
    }

    controller.onListen = () {
      subA = streamA.listen(
        (a) {
          latestA = a;
          hasA = true;
          emitIfReady();
        },
        onError: controller.addError,
        onDone: () {
          if (hasB) controller.close();
        },
      );

      subB = streamB.listen(
        (b) {
          latestB = b;
          hasB = true;
          emitIfReady();
        },
        onError: controller.addError,
        onDone: () {
          if (hasA) controller.close();
        },
      );
    };

    controller.onCancel = () async {
      await subA?.cancel();
      await subB?.cancel();
    };

    return controller.stream;
  }

  // Persons
  @override
  Stream<List<PersonEntity>> watchAllPersons() {
    return _db.watchAllPersons().map(
          (rows) => rows
              .map(
                (r) => PersonEntity(
                  id: r.id,
                  name: r.name,
                  phoneNumber: r.phoneNumber,
                  note: r.note,
                  createdAt: r.createdAt,
                  updatedAt: r.updatedAt,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<List<PersonEntity>> getAllPersons() async {
    final rows = await _db.getAllPersons();
    return rows
        .map(
          (r) => PersonEntity(
            id: r.id,
            name: r.name,
            phoneNumber: r.phoneNumber,
            note: r.note,
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
          ),
        )
        .toList();
  }

  @override
  Future<int> addPerson({required String name, String? phoneNumber, String? note}) async {
    final now = DateTime.now();
    return await _db.insertPerson(
      PersonsCompanion.insert(
        name: name.trim(),
        phoneNumber: Value(phoneNumber?.trim()),
        note: Value(note?.trim()),
        createdAt: now,
        updatedAt: now,
      ),
    );
  }

  @override
  Future<bool> updatePerson(PersonEntity person) async {
    return await _db.updatePerson(
      PersonsCompanion(
        id: Value(person.id),
        name: Value(person.name.trim()),
        phoneNumber: Value(person.phoneNumber?.trim()),
        note: Value(person.note?.trim()),
        createdAt: Value(person.createdAt),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  @override
  Future<int> deletePerson(int id) async {
    return await _db.deletePerson(id);
  }

  // Borrowed Records
  @override
  Stream<List<BorrowedRecordEntity>> watchAllBorrowedRecords() {
    return _combineStreams(
      _db.watchAllBorrowedRecordsWithPerson(),
      _db.watchAllRepayments(),
      (rows, repayments) {
        final borrowedRepayments =
            repayments.where((r) => r.recordType == 'borrowed' && r.entryType == 'repayment');

        return rows.map((row) {
          final record = row.readTable(_db.borrowedRecords);
          final person = row.readTable(_db.persons);

          final recRepayments = borrowedRepayments.where((r) => r.recordId == record.id);
          final paidCents = recRepayments.fold<int>(0, (sum, r) => sum + r.amountCents);
          final remainingCents = record.totalAmountCents - paidCents;
          final status = _calculateStatus(remainingCents, record.totalAmountCents);

          return BorrowedRecordEntity(
            id: record.id,
            personId: person.id,
            personName: person.name,
            totalAmountCents: record.totalAmountCents,
            paidAmountCents: paidCents,
            remainingCents: remainingCents,
            status: status,
            date: record.date,
            note: record.note,
            createdAt: record.createdAt,
            updatedAt: record.updatedAt,
          );
        }).toList();
      },
    );
  }

  @override
  Future<List<BorrowedRecordEntity>> getAllBorrowedRecords() async {
    final rows = await _db.getAllBorrowedRecordsWithPerson();
    final repayments = await _db.getAllRepayments();
    final borrowedRepayments =
        repayments.where((r) => r.recordType == 'borrowed' && r.entryType == 'repayment');

    return rows.map((row) {
      final record = row.readTable(_db.borrowedRecords);
      final person = row.readTable(_db.persons);

      final recRepayments = borrowedRepayments.where((r) => r.recordId == record.id);
      final paidCents = recRepayments.fold<int>(0, (sum, r) => sum + r.amountCents);
      final remainingCents = record.totalAmountCents - paidCents;
      final status = _calculateStatus(remainingCents, record.totalAmountCents);

      return BorrowedRecordEntity(
        id: record.id,
        personId: person.id,
        personName: person.name,
        totalAmountCents: record.totalAmountCents,
        paidAmountCents: paidCents,
        remainingCents: remainingCents,
        status: status,
        date: record.date,
        note: record.note,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
      );
    }).toList();
  }

  @override
  Future<int> addBorrowedRecord({
    required int personId,
    required int totalAmountCents,
    required DateTime date,
    String? note,
  }) async {
    final now = DateTime.now();
    final existingRecords = await _db.getAllBorrowedRecordsWithPerson();
    final match =
        existingRecords.where((row) => row.readTable(_db.borrowedRecords).personId == personId);

    int targetRecordId;
    if (match.isNotEmpty) {
      final existing = match.first.readTable(_db.borrowedRecords);
      targetRecordId = existing.id;
      final newTotal = existing.totalAmountCents + totalAmountCents;

      await (_db.update(_db.borrowedRecords)..where((t) => t.id.equals(targetRecordId))).write(
        BorrowedRecordsCompanion(
          totalAmountCents: Value(newTotal),
          updatedAt: Value(now),
        ),
      );
    } else {
      targetRecordId = await _db.insertBorrowedRecord(
        BorrowedRecordsCompanion.insert(
          personId: personId,
          totalAmountCents: totalAmountCents,
          date: date,
          note: Value(note?.trim()),
          status: 'pending',
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    // Log addition entry in history
    await _db.insertRepayment(
      RepaymentsCompanion.insert(
        recordType: 'borrowed',
        recordId: targetRecordId,
        amountCents: totalAmountCents,
        entryType: const Value('addition'),
        date: date,
        note: Value(note?.trim()),
        createdAt: now,
      ),
    );

    return targetRecordId;
  }

  @override
  Future<bool> updateBorrowedRecord({
    required int id,
    required int personId,
    required int totalAmountCents,
    required DateTime date,
    String? note,
  }) async {
    final now = DateTime.now();
    return await _db.updateBorrowedRecord(
      BorrowedRecordsCompanion(
        id: Value(id),
        personId: Value(personId),
        totalAmountCents: Value(totalAmountCents),
        date: Value(date),
        note: Value(note?.trim()),
        status: const Value('pending'),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<int> deleteBorrowedRecord(int id) async {
    return await _db.deleteBorrowedRecord(id);
  }

  // Lent Records
  @override
  Stream<List<LentRecordEntity>> watchAllLentRecords() {
    return _combineStreams(
      _db.watchAllLentRecordsWithPerson(),
      _db.watchAllRepayments(),
      (rows, repayments) {
        final lentRepayments =
            repayments.where((r) => r.recordType == 'lent' && r.entryType == 'repayment');

        return rows.map((row) {
          final record = row.readTable(_db.lentRecords);
          final person = row.readTable(_db.persons);

          final recRepayments = lentRepayments.where((r) => r.recordId == record.id);
          final paidCents = recRepayments.fold<int>(0, (sum, r) => sum + r.amountCents);
          final remainingCents = record.totalAmountCents - paidCents;
          final status = _calculateStatus(remainingCents, record.totalAmountCents);

          return LentRecordEntity(
            id: record.id,
            personId: person.id,
            personName: person.name,
            totalAmountCents: record.totalAmountCents,
            paidAmountCents: paidCents,
            remainingCents: remainingCents,
            status: status,
            date: record.date,
            note: record.note,
            createdAt: record.createdAt,
            updatedAt: record.updatedAt,
          );
        }).toList();
      },
    );
  }

  @override
  Future<List<LentRecordEntity>> getAllLentRecords() async {
    final rows = await _db.getAllLentRecordsWithPerson();
    final repayments = await _db.getAllRepayments();
    final lentRepayments =
        repayments.where((r) => r.recordType == 'lent' && r.entryType == 'repayment');

    return rows.map((row) {
      final record = row.readTable(_db.lentRecords);
      final person = row.readTable(_db.persons);

      final recRepayments = lentRepayments.where((r) => r.recordId == record.id);
      final paidCents = recRepayments.fold<int>(0, (sum, r) => sum + r.amountCents);
      final remainingCents = record.totalAmountCents - paidCents;
      final status = _calculateStatus(remainingCents, record.totalAmountCents);

      return LentRecordEntity(
        id: record.id,
        personId: person.id,
        personName: person.name,
        totalAmountCents: record.totalAmountCents,
        paidAmountCents: paidCents,
        remainingCents: remainingCents,
        status: status,
        date: record.date,
        note: record.note,
        createdAt: record.createdAt,
        updatedAt: record.updatedAt,
      );
    }).toList();
  }

  @override
  Future<int> addLentRecord({
    required int personId,
    required int totalAmountCents,
    required DateTime date,
    String? note,
  }) async {
    final now = DateTime.now();
    final existingRecords = await _db.getAllLentRecordsWithPerson();
    final match =
        existingRecords.where((row) => row.readTable(_db.lentRecords).personId == personId);

    int targetRecordId;
    if (match.isNotEmpty) {
      final existing = match.first.readTable(_db.lentRecords);
      targetRecordId = existing.id;
      final newTotal = existing.totalAmountCents + totalAmountCents;

      await (_db.update(_db.lentRecords)..where((t) => t.id.equals(targetRecordId))).write(
        LentRecordsCompanion(
          totalAmountCents: Value(newTotal),
          updatedAt: Value(now),
        ),
      );
    } else {
      targetRecordId = await _db.insertLentRecord(
        LentRecordsCompanion.insert(
          personId: personId,
          totalAmountCents: totalAmountCents,
          date: date,
          note: Value(note?.trim()),
          status: 'pending',
          createdAt: now,
          updatedAt: now,
        ),
      );
    }

    // Log addition entry in history
    await _db.insertRepayment(
      RepaymentsCompanion.insert(
        recordType: 'lent',
        recordId: targetRecordId,
        amountCents: totalAmountCents,
        entryType: const Value('addition'),
        date: date,
        note: Value(note?.trim()),
        createdAt: now,
      ),
    );

    return targetRecordId;
  }

  @override
  Future<bool> updateLentRecord({
    required int id,
    required int personId,
    required int totalAmountCents,
    required DateTime date,
    String? note,
  }) async {
    final now = DateTime.now();
    return await _db.updateLentRecord(
      LentRecordsCompanion(
        id: Value(id),
        personId: Value(personId),
        totalAmountCents: Value(totalAmountCents),
        date: Value(date),
        note: Value(note?.trim()),
        status: const Value('pending'),
        updatedAt: Value(now),
      ),
    );
  }

  @override
  Future<int> deleteLentRecord(int id) async {
    return await _db.deleteLentRecord(id);
  }

  // Repayments / Transaction History
  @override
  Stream<List<RepaymentEntity>> watchRepaymentsForRecord({
    required String recordType,
    required int recordId,
  }) {
    return _db.watchRepaymentsForRecord(recordType, recordId).map(
          (rows) => rows
              .map(
                (r) => RepaymentEntity(
                  id: r.id,
                  recordType: r.recordType,
                  recordId: r.recordId,
                  amountCents: r.amountCents,
                  entryType: r.entryType,
                  date: r.date,
                  note: r.note,
                  createdAt: r.createdAt,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<List<RepaymentEntity>> getRepaymentsForRecord({
    required String recordType,
    required int recordId,
  }) async {
    final rows = await _db.getRepaymentsForRecord(recordType, recordId);
    return rows
        .map(
          (r) => RepaymentEntity(
            id: r.id,
            recordType: r.recordType,
            recordId: r.recordId,
            amountCents: r.amountCents,
            entryType: r.entryType,
            date: r.date,
            note: r.note,
            createdAt: r.createdAt,
          ),
        )
        .toList();
  }

  @override
  Future<int> addRepayment({
    required String recordType,
    required int recordId,
    required int amountCents,
    required DateTime date,
    String? note,
  }) async {
    final now = DateTime.now();
    return await _db.insertRepayment(
      RepaymentsCompanion.insert(
        recordType: recordType,
        recordId: recordId,
        amountCents: amountCents,
        entryType: const Value('repayment'),
        date: date,
        note: Value(note?.trim()),
        createdAt: now,
      ),
    );
  }

  @override
  Future<int> deleteRepayment(int id) async {
    final repayment =
        await (_db.select(_db.repayments)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (repayment != null && repayment.entryType == 'addition') {
      if (repayment.recordType == 'borrowed') {
        final rec = await (_db.select(_db.borrowedRecords)
              ..where((t) => t.id.equals(repayment.recordId)))
            .getSingleOrNull();
        if (rec != null) {
          final newTotal = rec.totalAmountCents - repayment.amountCents;
          await (_db.update(_db.borrowedRecords)..where((t) => t.id.equals(repayment.recordId)))
              .write(BorrowedRecordsCompanion(totalAmountCents: Value(newTotal < 0 ? 0 : newTotal)));
        }
      } else if (repayment.recordType == 'lent') {
        final rec = await (_db.select(_db.lentRecords)
              ..where((t) => t.id.equals(repayment.recordId)))
            .getSingleOrNull();
        if (rec != null) {
          final newTotal = rec.totalAmountCents - repayment.amountCents;
          await (_db.update(_db.lentRecords)..where((t) => t.id.equals(repayment.recordId)))
              .write(LentRecordsCompanion(totalAmountCents: Value(newTotal < 0 ? 0 : newTotal)));
        }
      }
    }
    return await _db.deleteRepayment(id);
  }
}
