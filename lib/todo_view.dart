import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class TodoView extends StatefulWidget {
  final String title;
  final List<DateTime> entries;
  final List<String> labels;
  final List<String> comments;

  TodoView(this.title, this.entries, this.labels, this.comments) {}

  @override
  _TodoViewState createState() => _TodoViewState();
}

class _TodoViewState extends State<TodoView> {
  List<bool> expandedTiles;

  @override
  void initState() {
    expandedTiles = new List.generate(widget.entries.length, (index) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(margin: EdgeInsets.all(10), child: Text(widget.title)),
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
                                    itemCount: widget.entries.length,
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
                                                  child: Text(
                                                      widget.comments[index],
                                                      overflow: TextOverflow
                                                          .ellipsis),
                                                ),
                                          children: [
                                            Text(widget.comments[index])
                                          ],
                                          leading: Text(index.toString()),
                                          title: Text(widget.entries[index]
                                              .toString()));
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
