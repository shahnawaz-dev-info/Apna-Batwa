import '../entities/person.dart';
import '../entities/borrowed_record.dart';
import '../entities/lent_record.dart';
import '../entities/repayment.dart';
import '../repositories/khata_repository.dart';

class WatchAllPersons {
  final KhataRepository _repository;
  WatchAllPersons(this._repository);
  Stream<List<PersonEntity>> call() => _repository.watchAllPersons();
}

class AddPerson {
  final KhataRepository _repository;
  AddPerson(this._repository);
  Future<int> call({required String name, String? note}) =>
      _repository.addPerson(name: name, note: note);
}

class UpdatePerson {
  final KhataRepository _repository;
  UpdatePerson(this._repository);
  Future<bool> call(PersonEntity person) => _repository.updatePerson(person);
}

class DeletePerson {
  final KhataRepository _repository;
  DeletePerson(this._repository);
  Future<int> call(int id) => _repository.deletePerson(id);
}

class WatchAllBorrowedRecords {
  final KhataRepository _repository;
  WatchAllBorrowedRecords(this._repository);
  Stream<List<BorrowedRecordEntity>> call() => _repository.watchAllBorrowedRecords();
}

class AddBorrowedRecord {
  final KhataRepository _repository;
  AddBorrowedRecord(this._repository);
  Future<int> call({
    required int personId,
    required int totalAmountCents,
    required DateTime date,
    String? note,
  }) =>
      _repository.addBorrowedRecord(
        personId: personId,
        totalAmountCents: totalAmountCents,
        date: date,
        note: note,
      );
}

class UpdateBorrowedRecord {
  final KhataRepository _repository;
  UpdateBorrowedRecord(this._repository);
  Future<bool> call({
    required int id,
    required int personId,
    required int totalAmountCents,
    required DateTime date,
    String? note,
  }) =>
      _repository.updateBorrowedRecord(
        id: id,
        personId: personId,
        totalAmountCents: totalAmountCents,
        date: date,
        note: note,
      );
}

class DeleteBorrowedRecord {
  final KhataRepository _repository;
  DeleteBorrowedRecord(this._repository);
  Future<int> call(int id) => _repository.deleteBorrowedRecord(id);
}

class WatchAllLentRecords {
  final KhataRepository _repository;
  WatchAllLentRecords(this._repository);
  Stream<List<LentRecordEntity>> call() => _repository.watchAllLentRecords();
}

class AddLentRecord {
  final KhataRepository _repository;
  AddLentRecord(this._repository);
  Future<int> call({
    required int personId,
    required int totalAmountCents,
    required DateTime date,
    String? note,
  }) =>
      _repository.addLentRecord(
        personId: personId,
        totalAmountCents: totalAmountCents,
        date: date,
        note: note,
      );
}

class UpdateLentRecord {
  final KhataRepository _repository;
  UpdateLentRecord(this._repository);
  Future<bool> call({
    required int id,
    required int personId,
    required int totalAmountCents,
    required DateTime date,
    String? note,
  }) =>
      _repository.updateLentRecord(
        id: id,
        personId: personId,
        totalAmountCents: totalAmountCents,
        date: date,
        note: note,
      );
}

class DeleteLentRecord {
  final KhataRepository _repository;
  DeleteLentRecord(this._repository);
  Future<int> call(int id) => _repository.deleteLentRecord(id);
}

class WatchRepaymentsForRecord {
  final KhataRepository _repository;
  WatchRepaymentsForRecord(this._repository);
  Stream<List<RepaymentEntity>> call({
    required String recordType,
    required int recordId,
  }) =>
      _repository.watchRepaymentsForRecord(
        recordType: recordType,
        recordId: recordId,
      );
}

class AddRepayment {
  final KhataRepository _repository;
  AddRepayment(this._repository);
  Future<int> call({
    required String recordType,
    required int recordId,
    required int amountCents,
    required DateTime date,
    String? note,
  }) =>
      _repository.addRepayment(
        recordType: recordType,
        recordId: recordId,
        amountCents: amountCents,
        date: date,
        note: note,
      );
}

class DeleteRepayment {
  final KhataRepository _repository;
  DeleteRepayment(this._repository);
  Future<int> call(int id) => _repository.deleteRepayment(id);
}
