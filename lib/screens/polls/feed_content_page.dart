import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/constants/routes.dart';
import 'package:pollstrix/services/cloud/cloud_storage_constants.dart';
import 'package:pollstrix/services/cloud/polls/cloud_poll.dart';
import 'package:pollstrix/services/cloud/polls/firebase_poll_functions.dart';
import 'package:pollstrix/services/theme_service.dart';
import 'package:pollstrix/utilities/custom/poll/poll_tile.dart';
import 'package:pollstrix/utilities/custom/searchbar/custom_searchbar_delegate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class FeedContentPage extends StatefulWidget {
  const FeedContentPage({Key? key}) : super(key: key);

  @override
  _FeedContentPageState createState() => _FeedContentPageState();
}

class _FeedContentPageState extends State<FeedContentPage> {
  late SharedPreferences _preferences;
  late final FirebasePollFunctions _pollService;
  late var stream;

  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = <TargetFocus>[];

  // global keys for showcasesd
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _sortKey = GlobalKey();
  final GlobalKey _postPollKey = GlobalKey();

  void storeTutorial() async {
    _preferences = await SharedPreferences.getInstance();

    var prefVal = _preferences.getBool("didShowHomeTutorial");

    if (prefVal == false || prefVal == null) {
      Future.delayed(Duration.zero, showTutorial);
    }
  }

  @override
  void initState() {
    storeTutorial();
    _pollService = FirebasePollFunctions();
    stream =
        _pollService.getAllPolls(orderBy: createdAtField, isDescending: true);

    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        automaticallyImplyLeading: false,
        title: SizedBox(
          height: kToolbarHeight * 0.6,
          child: Image.asset(
            "assets/images/logo_inapp.png",
            color: kAccentColor,
          ),
        ),
        actions: <Widget>[
          IconButton(
            key: _searchKey,
            icon: const Icon(
              Icons.search_rounded,
              color: kAccentColor,
            ),
            onPressed: () {
              showSearch(context: context, delegate: CustomSearchBarDelegate());
            },
          ),
          PopupMenuButton(
              key: _sortKey,
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
                          stream = _pollService.getAllPolls(
                            orderBy: voteCountField,
                          );
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
                          stream = _pollService.getAllPolls(
                              orderBy: voteCountField, isDescending: true);
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
                          stream = _pollService.getAllPolls(
                            orderBy: likesField,
                          );
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
                          stream = _pollService.getAllPolls(
                              orderBy: likesField, isDescending: true);
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
                          stream = _pollService.getAllPolls(
                            orderBy: createdAtField,
                          );
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
                          stream = _pollService.getAllPolls(
                              orderBy: createdAtField, isDescending: true);
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
                          stream = _pollService.getAllPollsWithWhere(
                              fieldName: isFinishedField, object: false);
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
                          stream = _pollService.getAllPollsWithWhere(
                              fieldName: isFinishedField, object: true);
                        });
                      },
                    ),
                  ]),
        ],
      ),
      body: Column(children: [
        Flexible(
            child: StreamBuilder(
          stream: stream,
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
              case ConnectionState.active:
                if (snapshot.hasData) {
                  final allPolls = snapshot.data as Iterable<CloudPoll>;
                  return ListView.builder(
                    itemCount: allPolls.length,
                    itemBuilder: (context, index) {
                      final poll = allPolls.elementAt(index);
                      return PollTile(doc: poll);
                    },
                  );
                } else if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

              default:
                return const Center(
                  child: CircularProgressIndicator(),
                );
            }
          },
        )),
      ]),
      floatingActionButton: FloatingActionButton(
        key: _postPollKey,
        backgroundColor: kAccentColor,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add_rounded),
        onPressed: () => Navigator.of(context).pushNamed(postNewPollRoute),
      ),
    );
  }

  void showTutorial() async {
    initTargets();
    tutorialCoachMark = TutorialCoachMark(
      context,
      targets: targets,
      colorShadow: const Color.fromARGB(255, 71, 159, 230),
      textSkip: 'SKIP',
      paddingFocus: 10,
      opacityShadow: 0.9,
    )..show();

    await _preferences.setBool("didShowHomeTutorial", true);
  }

  void initTargets() {
    targets.clear(); // clear any targets

    targets.add(
      TargetFocus(
        identify: "_postPollKey",
        keyTarget: _postPollKey,
        alignSkip: Alignment.bottomLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Text(
                    "Post a new poll",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Click the + button to add a new poll.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );

    targets.add(
      TargetFocus(
        identify: "_searchKey",
        keyTarget: _searchKey,
        alignSkip: Alignment.topLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Text(
                    "Search",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Search for new poll.\nThe search is case sensitive and add at least two letters to find a search.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
    targets.add(
      TargetFocus(
        identify: "_filterKey",
        keyTarget: _sortKey,
        alignSkip: Alignment.topLeft,
        enableOverlayTab: true,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const <Widget>[
                  Text(
                    "Sort",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Sort the viewing method of polls.",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
