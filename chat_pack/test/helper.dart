import 'package:rethink_db_ns/rethink_db_ns.dart';

Future<void> createDB(RethinkDb r, Connection c) async {
  await r.dbCreate('test').run(c).catchError((e) => {});
  await r.tableCreate('users').run(c).catchError((e) => {});
  await r.tableCreate('messages').run(c).catchError((e) => {});
  await r.tableCreate('receipts').run(c).catchError((e) => {});
}

Future<void> cleanDB(RethinkDb r, Connection c) async {
  await r.table('users').delete().run(c);
  await r.table('messages').delete().run(c);
  await r.table('receipts').delete().run(c);
}
