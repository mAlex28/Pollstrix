import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/custom/custom_searchbar_delegate.dart';
import 'package:pollstrix/custom/poll_tile.dart';
import 'package:pollstrix/screens/post_poll_page.dart';
import 'package:pollstrix/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

class FeedContentPage extends StatefulWidget {
  const FeedContentPage({Key? key}) : super(key: key);

  @override
  _FeedContentPageState createState() => _FeedContentPageState();
}

class _FeedContentPageState extends State<FeedContentPage> {
  final db = FirebaseFirestore.instance;
  late var stream =
      db.collection('polls').orderBy('createdAt', descending: true).snapshots();
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _filterKey = GlobalKey();
  final GlobalKey _postPollKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    stream = db
        .collection('polls')
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    SharedPreferences preferences;

    displayShowcase() async {
      preferences = await SharedPreferences.getInstance();
      bool? showCaseVisibilityStatus = preferences.getBool("displayShowCase");

      if (showCaseVisibilityStatus == null) {
        preferences.setBool("displayShowCase", true);
        return true;
      }
      return false;
    }

    displayShowcase().then((status) {
      if (status) {
        WidgetsBinding.instance!.addPostFrameCallback((_) =>
            ShowCaseWidget.of(context)!
                .startShowCase([_searchKey, _filterKey, _postPollKey]));
      }
    });

    ScreenUtil.init(
        BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width,
            maxHeight: MediaQuery.of(context).size.height),
        designSize: const Size(360, 690),
        context: context,
        minTextAdapt: true,
        orientation: Orientation.portrait);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: SizedBox(
            height: kToolbarHeight * 0.6,
            child: Image.asset(
              "assets/images/logo_inapp.png",
              color: kAccentColor,
            ),
          ),
          actions: <Widget>[
            Showcase(
              key: _searchKey,
              showcaseBackgroundColor: const Color.fromARGB(255, 62, 131, 221),
              contentPadding: const EdgeInsets.all(12),
              description: 'Search for an item',
              descTextStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
              overlayColor: Colors.white,
              overlayOpacity: 0.7,
              child: IconButton(
                icon: const Icon(
                  Icons.search_rounded,
                  color: kAccentColor,
                ),
                onPressed: () {
                  showSearch(
                      context: context, delegate: CustomSearchBarDelegate());
                },
              ),
            ),
            Showcase(
                key: _filterKey,
                showcaseBackgroundColor:
                    const Color.fromARGB(255, 62, 131, 221),
                contentPadding: const EdgeInsets.all(12),
                descTextStyle: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                overlayColor: Colors.white,
                overlayOpacity: 0.7,
                child: PopupMenuButton(
                    icon: const Icon(Icons.sort_rounded, color: kAccentColor),
                    elevation: 8.0,
                    itemBuilder: (context) => [
                          PopupMenuItem(
                            child: const Text(
                              'Sorty by Votes (ASC)',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                            ),
                            value: 1,
                            onTap: () {
                              setState(() {
                                stream = db
                                    .collection('polls')
                                    .orderBy('voteCount')
                                    .snapshots();
                              });
                            },
                          ),
                          PopupMenuItem(
                            child: const Text(
                              'Sorty by Votes (DESC)',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                            ),
                            value: 2,
                            onTap: () {
                              setState(() {
                                stream = db
                                    .collection('polls')
                                    .orderBy('voteCount', descending: true)
                                    .snapshots();
                              });
                            },
                          ),
                          PopupMenuItem(
                            child: const Text(
                              'Sort by Likes (ASC)',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                            ),
                            value: 3,
                            onTap: () {
                              setState(() {
                                stream = db
                                    .collection('polls')
                                    .orderBy('likes')
                                    .snapshots();
                              });
                            },
                          ),
                          PopupMenuItem(
                            child: const Text(
                              'Sort by Likes (DESC)',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                            ),
                            value: 4,
                            onTap: () {
                              setState(() {
                                stream = db
                                    .collection('polls')
                                    .orderBy('likes', descending: true)
                                    .snapshots();
                              });
                            },
                          ),
                          PopupMenuItem(
                            child: const Text(
                              'Sort by Date (ASC)',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                            ),
                            value: 5,
                            onTap: () {
                              setState(() {
                                stream = db
                                    .collection('polls')
                                    .orderBy('createdAt')
                                    .snapshots();
                              });
                            },
                          ),
                          PopupMenuItem(
                            child: const Text(
                              'Sort by Date (DESC)',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                            ),
                            value: 6,
                            onTap: () {
                              setState(() {
                                stream = db
                                    .collection('polls')
                                    .orderBy('createdAt', descending: true)
                                    .snapshots();
                              });
                            },
                          ),
                          PopupMenuItem(
                            child: const Text(
                              'Sort by Running',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                            ),
                            value: 7,
                            onTap: () {
                              setState(() {
                                stream = db
                                    .collection('polls')
                                    .where('finished', isEqualTo: false)
                                    .snapshots();
                              });
                            },
                          ),
                          PopupMenuItem(
                            child: const Text(
                              'Sort by Ended',
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w400),
                            ),
                            value: 8,
                            onTap: () {
                              setState(() {
                                stream = db
                                    .collection('polls')
                                    .where('finished', isEqualTo: true)
                                    .snapshots();
                              });
                            },
                          ),
                        ]),
                description: 'Filter results'),
          ],
        ),
        body: Column(children: [
          Flexible(
              child: StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
              if (snapshot.hasData) {
                return ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return PollTile(doc: snapshot.data!.docs[index]);
                  },
                );
              } else {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }
            },
          )),
        ]),
        floatingActionButton: Showcase(
          key: _postPollKey,
          showcaseBackgroundColor: const Color.fromARGB(255, 62, 131, 221),
          contentPadding: const EdgeInsets.all(12),
          descTextStyle: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
          overlayColor: Colors.white,
          overlayOpacity: 0.7,
          description: 'Add a new poll',
          child: FloatingActionButton(
              backgroundColor: kAccentColor,
              foregroundColor: Colors.white,
              child: const Icon(Icons.add_rounded),
              onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (BuildContext context) =>
                          const PostPollPage()))),
        ));
  }
}
