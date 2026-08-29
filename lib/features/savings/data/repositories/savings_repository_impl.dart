import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';
import '../../../../data/local/app_database.dart';
import '../../domain/entities/savings_contribution.dart';
import '../../domain/entities/savings_goal.dart';
import '../../domain/repositories/savings_repository.dart';

class SavingsRepositoryImpl implements SavingsRepository {
  final AppDatabase _db;
  final Uuid _uuid = const Uuid();

  SavingsRepositoryImpl(this._db);

  @override
  Stream<List<SavingsGoalEntity>> watchAllSavingsGoals() {
    return _db.watchAllSavingsGoals().map(
          (rows) => rows
              .map(
                (r) => SavingsGoalEntity(
                  id: r.id,
                  name: r.name,
                  targetAmountCents: r.targetAmountCents,
                  targetDate: r.targetDate,
                  createdAt: r.createdAt,
                  isCompleted: r.isCompleted,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<List<SavingsGoalEntity>> getAllSavingsGoals() async {
    final rows = await _db.getAllSavingsGoals();
    return rows
        .map(
          (r) => SavingsGoalEntity(
            id: r.id,
            name: r.name,
            targetAmountCents: r.targetAmountCents,
            targetDate: r.targetDate,
            createdAt: r.createdAt,
            isCompleted: r.isCompleted,
          ),
        )
        .toList();
  }

  @override
  Future<String> addSavingsGoal({
    required String name,
    required int targetAmountCents,
    DateTime? targetDate,
  }) async {
    final id = _uuid.v4();
    final now = DateTime.now();

    await _db.insertSavingsGoal(
      SavingsGoalsCompanion.insert(
        id: id,
        name: name.trim(),
        targetAmountCents: targetAmountCents,
        targetDate: Value(targetDate),
        createdAt: now,
      ),
    );
    return id;
  }

  @override
  Future<bool> updateSavingsGoal(SavingsGoalEntity goal) async {
    return await _db.updateSavingsGoal(
      SavingsGoalsCompanion(
        id: Value(goal.id),
        name: Value(goal.name.trim()),
        targetAmountCents: Value(goal.targetAmountCents),
        targetDate: Value(goal.targetDate),
        createdAt: Value(goal.createdAt),
        isCompleted: Value(goal.isCompleted),
      ),
    );
  }

  @override
  Future<void> deleteSavingsGoal(String id) async {
    await _db.deleteSavingsGoal(id);
  }

  // Contributions
  @override
  Stream<List<SavingsContributionEntity>> watchContributionsForGoal(String goalId) {
    return _db.watchContributionsForGoal(goalId).map(
          (rows) => rows
              .map(
                (r) => SavingsContributionEntity(
                  id: r.id,
                  savingsGoalId: r.savingsGoalId,
                  amountCents: r.amountCents,
                  contributionDate: r.contributionDate,
                  notes: r.notes,
                ),
              )
              .toList(),
        );
  }

  @override
  Stream<List<SavingsContributionEntity>> watchAllSavingsContributions() {
    return _db.watchAllSavingsContributions().map(
          (rows) => rows
              .map(
                (r) => SavingsContributionEntity(
                  id: r.id,
                  savingsGoalId: r.savingsGoalId,
                  amountCents: r.amountCents,
                  contributionDate: r.contributionDate,
                  notes: r.notes,
                ),
              )
              .toList(),
        );
  }

  @override
  Future<String> addSavingsContribution({
    required String savingsGoalId,
    required int amountCents,
    required DateTime contributionDate,
    String? notes,
  }) async {
    final id = _uuid.v4();

    await _db.insertSavingsContribution(
      SavingsContributionsCompanion.insert(
        id: id,
        savingsGoalId: savingsGoalId,
        amountCents: amountCents,
        contributionDate: contributionDate,
        notes: Value(notes?.trim()),
      ),
    );
    return id;
  }

  @override
  Future<void> deleteSavingsContribution(String id) async {
    await _db.deleteSavingsContribution(id);
  }
}
