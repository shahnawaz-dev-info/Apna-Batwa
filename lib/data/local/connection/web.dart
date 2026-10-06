import 'package:drift/drift.dart';
import 'package:drift/web.dart';

QueryExecutor constructDb() {
  return LazyDatabase(() async {
    return WebDatabase('apna_batwa');
  });
}
