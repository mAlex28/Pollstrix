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
import 'package:showcaseview/showcaseview.dart';

class FeedContentPage extends StatefulWidget {
  const FeedContentPage({Key? key}) : super(key: key);

  @override
  _FeedContentPageState createState() => _FeedContentPageState();
}

class _FeedContentPageState extends State<FeedContentPage> {
  late final FirebasePollFunctions _pollService;
  late var stream;

  // global keys for showcasesd
  final GlobalKey _searchKey = GlobalKey();
  final GlobalKey _filterKey = GlobalKey();
  final GlobalKey _postPollKey = GlobalKey();

  @override
  void initState() {
    WidgetsBinding.instance!.addPostFrameCallback((_) =>
        ShowCaseWidget.of(context)!
            .startShowCase([_searchKey, _filterKey, _postPollKey]));
    _pollService = FirebasePollFunctions();
    stream =
        _pollService.getAllPolls(orderBy: createdAtField, isDescending: true);

    super.initState();
  }

  startShowCase() {}

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
                                    orderBy: voteCountField,
                                    isDescending: true);
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
                                    orderBy: createdAtField,
                                    isDescending: true);
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
                description: 'Filter results'),
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
          description: 'Add new poll',
          child: FloatingActionButton(
            backgroundColor: kAccentColor,
            foregroundColor: Colors.white,
            child: const Icon(Icons.add_rounded),
            onPressed: () => Navigator.of(context).pushNamed(postNewPollRoute),
          ),
        ));
  }
}
