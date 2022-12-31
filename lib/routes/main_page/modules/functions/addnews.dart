import 'package:mongo_dart/mongo_dart.dart';

class AddNews {
  addNew(String author, String date, String title, String description) async {
    final now = DateTime.now();
    const dbName = 'square';
    const dbAddress = 'localhost';

    const defaultUri = 'mongodb://$dbAddress:27017/$dbName';

    var db = Db(defaultUri);
    await db.open();

    Future cleanupDatabase() async {
      await db.close();
    }

    if (!db.masterConnection.serverCapabilities.supportsOpMsg) {
      return;
    }

    var collectionName = 'news';
    await db.dropCollection(collectionName);
    var collection = db.collection(collectionName);

    var ret = await collection.insertOne(<String, dynamic>{
      '_id': ObjectId(),
      'date': IsoDateFromParts(year: now.year, week: now.month, day: now.day, hour: now.hour, second: now.second),
      'author': author,
      'title': title,
      'description': description
    });
    if (!ret.isSuccess) {
      print('Error detected in record insertion');
    }

    var res = await collection.findOne();

      print('Fetched ${res?['name']}');
      await cleanupDatabase();
  }
}
