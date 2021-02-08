import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:good_hobbits/model/hobbit_model.dart';
import 'package:good_hobbits/util/MyAppBar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:transparent_image/transparent_image.dart';

class TodoView extends StatefulWidget {
  Hobbit hobbit;

  TodoView(this.hobbit) {}

  @override
  _TodoViewState createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  List<bool> expandedTiles;
  bool reverseList = false;
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  _TodoViewState() {}

  @override
  void initState() {
    widget.hobbit.entries.then((entries) {
    expandedTiles= new List.generate(entries.length, (index) => false);

    });
  }

  Future<File> downloadFileExample(String url) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    File downloadToFile = File('${appDocDir.path}/{$url}');

    try {
      await firebase_storage.FirebaseStorage.instance
          .ref(url)
          .writeToFile(downloadToFile);
      return downloadToFile;
    } catch (e) {
      // e.g, e.code == 'canceled'
    }
  }

  Future<String> _getImage(String image) async {
    Image m;
    Future<String> downloadUrl =
        firebase_storage.FirebaseStorage.instance.ref(image).getDownloadURL();
    return downloadUrl;
  }

  Widget fireStoreImage(Future<String> url) {
    return FutureBuilder(
        future: url,
        builder: (context, AsyncSnapshot<String> snapshot) {
          if (snapshot.hasError) {
            return Container(
              child: Icon(Icons.image_not_supported_outlined),
            );
          }
          if (snapshot.hasData) {
            return Container(
                padding: EdgeInsets.all(40.0),
                child: FadeInImage.memoryNetwork(
                    placeholder: kTransparentImage, image: snapshot.data));
          }
          return CircularProgressIndicator();
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(
        title: Text(widget.hobbit.title),
      ),
      body: FutureBuilder(
          future: widget.hobbit.entries,
          builder: (context, AsyncSnapshot<List<HobbitEntry>> snapshot) {
            if (snapshot.hasData) {
              return buildHobbitEntries(snapshot.data);
            } else {
              return CircularProgressIndicator();
            }
          }),
    );
  }

  Widget buildHobbitEntries(List<HobbitEntry> hobbitEntries) {
    var entries = hobbitEntries;
    if (this.reverseList) {
      entries = hobbitEntries.reversed;
    }
    return Padding(
      padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            margin: EdgeInsets.only(bottom: 20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(child: Text('Entries')),
                Column(
                  children: [
                    Row(
                      children: [
                        Container(
                          child: Text('reverse List:'),
                        ),
                        Switch(
                            value: reverseList,
                            onChanged: (value) {
                              setState(() {
                                reverseList = value;
                                //this.expandedTiles=this.expandedTiles.reversed.toList();
                              });
                            })
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            child: Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                      child: Container(
                          padding: EdgeInsets.all(0),
                          margin: EdgeInsets.all(0),
                          child: Center(
                              child: ListView.separated(
                                  separatorBuilder: (context, index) =>
                                      Divider(),
                                  itemCount: entries.length,
                                  itemBuilder: (_, index) {
                                    return ExpansionTile(
                                        onExpansionChanged: (expanded) {
                                          setState(() {
                                            this.expandedTiles[index] =
                                                expanded;
                                          });
                                        },
                                        subtitle: this.expandedTiles[index]
                                            ? Container()
                                            : SizedBox(
                                                width: 40.0,
                                                child: Text(
                                                    entries[index].comment,
                                                    overflow:
                                                        TextOverflow.ellipsis),
                                              ),
                                        children: [
                                          Text(entries[index].comment),
                                          entries[index].imageurl != ''
                                              ? fireStoreImage(_getImage(
                                                  entries[index].imageurl))
                                              : Container()
                                        ],
                                        leading: Text(index.toString()),
                                        title: Text(
                                            entries[index].date.toString()));
                                  }))))
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
