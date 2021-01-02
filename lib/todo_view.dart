import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:transparent_image/transparent_image.dart';

class TodoView extends StatefulWidget {
  final String title;
  final List<DateTime> entries;
  final List<String> labels;
  final List<String> comments;
  final List<String> downloadUrls;

  TodoView(this.title, this.entries, this.labels, this.comments,
      this.downloadUrls) {}

  @override
  _TodoViewState createState() =>
      _TodoViewState(this.entries, this.comments, this.downloadUrls);
}

class _TodoViewState extends State<TodoView> {
  List<bool> expandedTiles;
  bool reverseList = false;
  List<DateTime> entries;
  List<String> comments;
  List<String> downloadUrls;
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  _TodoViewState(this.entries, this.comments, this.downloadUrls) {}

  @override
  void initState() {
    expandedTiles = new List.generate(widget.entries.length, (index) => false);
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
  Future<String> _getImage( String image) async {
    Image m;
    Future<String> downloadUrl = firebase_storage.FirebaseStorage.instance.ref(image).getDownloadURL();
    return downloadUrl;
    /*await StorageService.loadImage(context, image).then((downloadUrl) {
      m = Image.network(
        downloadUrl.toString(),
        fit: BoxFit.scaleDown,
      );
    });
    return m;*/
  }
  Widget fireStoreImage(Future<String> url){
    return FutureBuilder(
        future: url,
        builder: (context,AsyncSnapshot<String> snapshot){
          if(snapshot.hasError){
            return Container(child: Icon(Icons.image_not_supported_outlined),);
          }
         if(snapshot.hasData){
           return Container(
               padding: EdgeInsets.all(40.0),
               child: FadeInImage.memoryNetwork(placeholder: kTransparentImage, image: snapshot.data));
         }else{
           return CircularProgressIndicator();
         }
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Padding(
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
                                  this.entries = entries.reversed.toList();
                                  this.comments = comments.reversed.toList();
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
                                              ? null
                                              : SizedBox(
                                                  width: 40.0,
                                                  child: Text(comments[index],
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                ),
                                          children: [
                                            Text(comments[index]),
                                            downloadUrls[index] != ''
                                                ?fireStoreImage(_getImage(downloadUrls[index]))
                                                /*FutureBuilder(
                                                    future: downloadFileExample(
                                                        downloadUrls[index]),
                                                    builder: (context,
                                                        AsyncSnapshot<File>
                                                            snapshot) {
                                                      if (snapshot.hasData) {
                                                        return Image.file(
                                                            snapshot.data);
                                                      } else
                                                        return Container();
                                                    })*/
                                                : Container()
                                          ],
                                          leading: Text(index.toString()),
                                          title:
                                              Text(entries[index].toString()));
                                    }))))
                  ],
                ),
              ),
            ),
            Row(
              children: [
                ...widget.labels
                    .map((e) => Container(child: new Text(e)))
                    .toList()
              ],
            )
          ],
        ),
      ),
    );
  }
}
