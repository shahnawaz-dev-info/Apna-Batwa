import '../entities/person.dart';
import '../entities/borrowed_record.dart';
import '../entities/lent_record.dart';
import '../entities/repayment.dart';

abstract class KhataRepository {
  // Persons
  Stream<List<PersonEntity>> watchAllPersons();
  Future<List<PersonEntity>> getAllPersons();
  Future<int> addPerson({required String name, String? phoneNumber, String? note});
  Future<bool> updatePerson(PersonEntity person);
  Future<int> deletePerson(int id);

  // Borrowed Records
  Stream<List<BorrowedRecordEntity>> watchAllBorrowedRecords();
  Future<List<BorrowedRecordEntity>> getAllBorrowedRecords();
  Future<int> addBorrowedRecord({
    required int personId,
    required int totalAmountCents,
    required DateTime date,
    String? note,
  });
  Future<bool> updateBorrowedRecord({
    required int id,
    required int personId,
    required int totalAmountCents,
    required DateTime date,
    String? note,
  });
  Future<int> deleteBorrowedRecord(int id);

  // Lent Records
  Stream<List<LentRecordEntity>> watchAllLentRecords();
  Future<List<LentRecordEntity>> getAllLentRecords();
  Future<int> addLentRecord({
    required int personId,
    required int totalAmountCents,
    required DateTime date,
    String? note,
  });
  Future<bool> updateLentRecord({
    required int id,
    required int personId,
    required int totalAmountCents,
    required DateTime date,
    String? note,
  });
  Future<int> deleteLentRecord(int id);

  // Repayments
  Stream<List<RepaymentEntity>> watchRepaymentsForRecord({
    required String recordType,
    required int recordId,
  });
  Future<List<RepaymentEntity>> getRepaymentsForRecord({
    required String recordType,
    required int recordId,
  });
  Future<int> addRepayment({
    required String recordType,
    required int recordId,
    required int amountCents,
    required DateTime date,
    String? note,
  });
  Future<int> deleteRepayment(int id);
}
