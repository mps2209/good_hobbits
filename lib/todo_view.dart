import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TodoView extends StatelessWidget {
  final String title;
  final List<DateTime> entries;
  final List<String> labels;
  final List<String> comments;

  TodoView(this.title, this.entries, this.labels,this.comments);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
                margin: EdgeInsets.all(10),
                child: Text(title)),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(child: Text('entries')),
              ],
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
                                        subtitle: SizedBox(
                                          width:40.0,
                                          child: Text(

                                              comments[index],
                                          overflow: TextOverflow.ellipsis),
                                        ),
                                        children: [Text(comments[index])],
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
                ...labels.map((e) => Container(child: new Text(e))).toList()
              ],
            )
          ],
        ),
      ),
    );
  }
}
