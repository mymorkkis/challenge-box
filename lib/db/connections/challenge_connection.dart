import 'package:challenge_box/db/connections/db_connection.dart';
import 'package:challenge_box/db/constants.dart';
import 'package:challenge_box/db/models/challenge.dart';
import 'package:sqflite/sqflite.dart';

class ChallengeConnection {
  final database = DatabaseConnection.instance.database;

  ChallengeConnection();

  Future<void> insertChallenge(Challenge challenge) async {
    Database db = await database;
    await db.insert(tableChallenges, challenge.toMap());
  }

  Future<Challenge> queryChallenge(int id) async {
    Database db = await database;
    List<Map> maps = await db.query(
      tableChallenges,
      columns: [
        columnId,
        columnName,
        columnStartDate,
        columnLongestDuration,
        columnFailed,
        columnFailedDate,
        columnEndDate
      ],
      where: '$columnId = ?',
      whereArgs: [id],
    );
    if (maps.length > 0) {
      return Challenge.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Challenge>> queryCurrentChallenges() async {
    Database db = await database;

    List<Map> maps = await db.query(
      tableChallenges,
      columns: [
        columnId,
        columnName,
        columnStartDate,
        columnLongestDuration,
        columnFailed,
        columnFailedDate,
        columnEndDate
      ],
    );

    List<Challenge> challengeMaps = [];
    for (var map in maps) {
      challengeMaps.add(Challenge.fromMap(map));
    }
    return challengeMaps;
  }

  Future<void> updateChallenge(Challenge challenge) async {
    Database db = await database;
    await db.update(tableChallenges, challenge.toMap(),
        where: "$columnId = ?", whereArgs: [challenge.id]);
  }

  Future<void> deleteChallenge(Challenge challenge) async {
    Database db = await database;
    await db.delete(
      tableChallenges,
      where: '$columnId = ?',
      whereArgs: [challenge.id],
    );
  }
}
