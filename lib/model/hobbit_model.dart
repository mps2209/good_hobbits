import 'package:cloud_firestore/cloud_firestore.dart';

class Hobbit {
  DocumentReference doc;
  String title;
  Future<List<HobbitEntry>> entries;

  Hobbit.fromSnapshot(QueryDocumentSnapshot snapshot) {
    this.title = snapshot.id;
    //TODO: this will probably not work due to collection need to find async way to do that
    this.doc=snapshot.reference;
    this.entries= doc.collection('entries').get().then(
            (value) => value.docs.map(
                    (doc)=>HobbitEntry.fromSnapshot(doc)).toList());
        //.map((snapshot) => HobbitEntry.fromSnapshot(snapshot)).toList();
    entries.asStream().map((entries)=>entries.sort((a, b) {
      return a.date.millisecondsSinceEpoch -
          b.date.millisecondsSinceEpoch;
    }));
  }
}

class HobbitEntry {
  DateTime date;
  String comment;
  String imageurl;

  HobbitEntry.fromSnapshot(snapshot) {
    this.comment =
        snapshot.data().containsKey('comment') ? snapshot['comment'] : '';
    this.imageurl =
        snapshot.data().containsKey('image') ? snapshot['image'] : '';
    Timestamp ts = snapshot['date'];
    this.date = DateTime.fromMillisecondsSinceEpoch(ts.millisecondsSinceEpoch);
  }
}
