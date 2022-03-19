import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:pollstrix/custom/custom_searchbar_delegate.dart';
import 'package:pollstrix/custom/poll_tile.dart';

class FeedContentPage extends StatefulWidget {
  const FeedContentPage({Key? key}) : super(key: key);

  @override
  _FeedContentPageState createState() => _FeedContentPageState();
}

class _FeedContentPageState extends State<FeedContentPage> {
  final db = FirebaseFirestore.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late DateTime _currentDate;
  var stream;

  @override
  void initState() {
    super.initState();
    _currentDate = DateTime.now();
    stream = db
        .collection('polls')
        .orderBy('createdAt', descending: true)
        .snapshots();
    _compareDates();
  }

  void _openEndDrawer() {
    _scaffoldKey.currentState!.openEndDrawer();
  }

  _compareDates() async {
    await db.collection('polls').get().then((value) {
      value.docs.map((e) {
        e.data()['endDate'];
      });
    });

    db.collection('polls').where('endDate');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _scaffoldKey,
        endDrawer: SizedBox(
          width: MediaQuery.of(context).size.width * 0.5,
          child: Drawer(
            child: ListView(
              padding: const EdgeInsets.all(10.0),
              children: [
                const Padding(
                  padding: EdgeInsets.only(top: 20, bottom: 8),
                  child: Text(
                    'Sort By:',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.blue),
                  ),
                ),
                ListTile(
                  title: const Text(
                    'Votes (most - least)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  hoverColor: Colors.lightBlue,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  onTap: () {
                    setState(() {
                      stream = db
                          .collection('polls')
                          .orderBy('voteCount', descending: true)
                          .snapshots();
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text(
                    'Votes (least - most)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  hoverColor: Colors.lightBlue,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  onTap: () {
                    setState(() {
                      stream = db
                          .collection('polls')
                          .orderBy('voteCount')
                          .snapshots();
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text(
                    'Likes (most - least)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  hoverColor: Colors.lightBlue,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  onTap: () {
                    setState(() {
                      stream = db
                          .collection('polls')
                          .orderBy('likes', descending: true)
                          .snapshots();
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text(
                    'Likes (least - most)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  hoverColor: Colors.lightBlue,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  onTap: () {
                    setState(() {
                      stream =
                          db.collection('polls').orderBy('likes').snapshots();
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text(
                    'Running',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  hoverColor: Colors.lightBlue,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text(
                    'Ended',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  hoverColor: Colors.lightBlue,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  onTap: () {
                    // Update the state of the app
                    // ...
                    // Then close the drawer
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text(
                    'Created Date (Asc)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  hoverColor: Colors.lightBlue,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  onTap: () {
                    setState(() {
                      stream = db
                          .collection('polls')
                          .orderBy('createdAt')
                          .snapshots();
                    });
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text(
                    'Created Date (Desc)',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
                  ),
                  hoverColor: Colors.lightBlue,
                  dense: true,
                  visualDensity: VisualDensity.compact,
                  onTap: () {
                    setState(() {
                      stream = db
                          .collection('polls')
                          .orderBy('createdAt', descending: true)
                          .snapshots();
                    });
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
        appBar: AppBar(
          title: const Text('Pollstrix'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.search_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                showSearch(
                    context: context, delegate: CustomSearchBarDelegate());
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.sort_rounded,
                color: Colors.white,
              ),
              onPressed: () {
                _openEndDrawer();
              },
            )
          ],
        ),
        body: Column(children: [
          Flexible(
              child: StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              } else {
                return ListView(
                  scrollDirection: Axis.vertical,
                  children: snapshot.data!.docs.map((doc) {
                    return PollTile(
                      doc: doc,
                    );
                  }).toList(),
                );
              }
            },
          )),
        ]));
  }
}
