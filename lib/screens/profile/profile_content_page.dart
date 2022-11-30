import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/services/auth/auth_service.dart';
import 'package:pollstrix/services/auth/auth_user.dart';
import 'package:pollstrix/services/cloud/cloud_storage_constants.dart';
import 'package:pollstrix/services/cloud/polls/cloud_poll.dart';
import 'package:pollstrix/services/cloud/polls/firebase_poll_functions.dart';
import 'package:pollstrix/utilities/custom/poll/poll_tile.dart';
import 'package:pollstrix/screens/profile/user_page.dart';
import 'package:pollstrix/services/theme_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class ProfileContentPage extends StatefulWidget {
  const ProfileContentPage({Key? key}) : super(key: key);

  @override
  _ProfileContentPageState createState() => _ProfileContentPageState();
}

class _ProfileContentPageState extends State<ProfileContentPage> {
  late SharedPreferences _preferences;
  final FirebasePollFunctions _pollService = FirebasePollFunctions();
  final currentUserId = AuthService.firebase().currentUser!.userId;
  final urlImage = "assets/images/avatar.png";
  late TutorialCoachMark tutorialCoachMark;
  List<TargetFocus> targets = <TargetFocus>[];

  // global keys for showcases
  final GlobalKey _editProfileKey = GlobalKey();
  final GlobalKey _postedKey = GlobalKey();
  final GlobalKey _votedKey = GlobalKey();

  int userSelectedOption = 0;

  /// Store and check if the show case tutorial is showsn
  void storeTutorial() async {
    _preferences = await SharedPreferences.getInstance();

    var prefVal = _preferences.getBool("didShowProfileTutorial");

    if (prefVal == false || prefVal == null) {
      Future.delayed(Duration.zero, showTutorial);
    }
  }

  @override
  void initState() {
    storeTutorial();
    _getVoteDataOfUsers();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  /// Get all the polls current user has voted
  _getVoteDataOfUsers() async {
    await _pollService.polls.get().then((value) {
      value.docs.map((e) {
        List<dynamic> voteDataList = e.data()[voteDataField];
        for (var vote in voteDataList) {
          if (vote.containsKey(userIdField) ?? false) {
            if (vote![userIdField] == currentUserId) {
              setState(() {
                userSelectedOption = vote[optionField];
              });
              return;
            }
          }
        }
      }).toList();
    });
  }

  /// Get profile image of the current user (if there's no user image, a default assest image is shown)
  _getProfileImage() {
    final profileImage = AuthService.firebase().currentUser!.imageUrl;

    if (profileImage != null) {
      return NetworkImage(profileImage);
    } else {
      return AssetImage(urlImage);
    }
  }

  /// Get current logged in user
  Future<AuthUser> _getCurrentUser() async {
    final user = AuthService.firebase().currentUser!;
    return user;
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

    // fetch current user's email, display name and photo form firebase
    Widget buildProfileInfo(context, snapshot) {
      return Expanded(
          child: Column(
        children: <Widget>[
          Container(
            height: kIsWeb ? 100 : kSpacingUnit.w * 10,
            width: kIsWeb ? 100 : kSpacingUnit.w * 10,
            margin: EdgeInsets.only(top: kIsWeb ? 20 : kSpacingUnit.w * 3),
            child: Stack(
              key: _editProfileKey,
              children: <Widget>[
                CircleAvatar(
                  radius: kIsWeb ? 70 : kSpacingUnit.w * 5,
                  backgroundImage: _getProfileImage(),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const UserPage(),
                    )),
                    child: Container(
                      height: kIsWeb ? 30 : kSpacingUnit.w * 2.5,
                      width: kIsWeb ? 30 : kSpacingUnit.w * 2.5,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        heightFactor: kIsWeb ? 20 : kSpacingUnit.w * 1.5,
                        widthFactor: kIsWeb ? 20 : kSpacingUnit.w * 1.5,
                        child: Icon(
                          Icons.edit,
                          color: kLightPrimaryColor,
                          size: kIsWeb
                              ? 18
                              : ScreenUtil().setSp(kSpacingUnit.w * 1.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: kIsWeb ? 15 : kSpacingUnit.w * 2),
          Text(
            '${snapshot.data.displayName ?? "Unkown"}',
            style: kIsWeb
                ? const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  )
                : kTitleTextStyle,
          ),
          SizedBox(height: kSpacingUnit.w * 0.5),
          Text(
            '${snapshot.data.email ?? "Anonymous"}',
            style: kIsWeb
                ? const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w100,
                  )
                : kCaptionTextStyle,
          ),
          SizedBox(height: kSpacingUnit.w * 2),
        ],
      ));
    }

    // header contains the fetched data of the current user
    var header = Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        SizedBox(width: kSpacingUnit.w * 3),
        FutureBuilder(
            future: _getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return buildProfileInfo(context, snapshot);
              } else {
                return const CircularProgressIndicator();
              }
            }),
        // themeSwitcher,
        SizedBox(width: kSpacingUnit.w * 3),
      ],
    );

    // all the posted polls by the current user
    var postedPolls = Column(children: [
      Flexible(
          child: StreamBuilder(
              stream: _pollService.getAllPollsOfTheUser(
                  currentUserId: currentUserId),
              builder: (context, snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                  case ConnectionState.active:
                    if (snapshot.hasData) {
                      final allPolls = snapshot.data as Iterable<
                          CloudPoll>; // get all the polls and assign to the poll structure
                      return ListView.builder(
                        itemCount: allPolls.length,
                        itemBuilder: (context, index) {
                          final poll = allPolls.elementAt(index);
                          return PollTile(
                            doc: poll,
                            index: index,
                            pollList: allPolls.toList(),
                          );
                        },
                      );
                    } else if (!snapshot.hasData) {
                      return const Center(
                        child: Text('No polls available'),
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
              })),
    ]);

    // all the voted data by the user
    var votedPolls = Column(children: [
      Flexible(
          child: StreamBuilder(
        stream: _pollService.getVotedPollsOfTheUser(
            currentUserId: currentUserId,
            userSelectedOption: userSelectedOption),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.waiting:
            case ConnectionState.active:
              if (snapshot.hasData) {
                final allPolls = snapshot.data as Iterable<
                    CloudPoll>; // get all the polls and assign to the poll structure
                return ListView.builder(
                  itemCount: allPolls.length,
                  itemBuilder: (context, index) {
                    final poll = allPolls.elementAt(index);
                    return PollTile(
                      doc: poll,
                      index: index,
                      pollList: allPolls.toList(),
                    );
                  },
                );
              } else {
                return const Center(
                  child: Text('No polls available'),
                );
              }
            default:
              return const Center(
                child: CircularProgressIndicator(),
              );
          }
        },
      )),
    ]);

    return DefaultTabController(
        length: 2,
        child: Scaffold(
            body: SingleChildScrollView(
                child: kIsWeb
                    ? Center(
                        child: SizedBox(
                        width: 700,
                        child: Column(
                          children: <Widget>[
                            SizedBox(height: kIsWeb ? 20 : kSpacingUnit.w * 5),
                            header,
                            TabBar(tabs: [
                              Tab(
                                key: _postedKey,
                                text: 'Posted',
                              ),
                              Tab(
                                key: _votedKey,
                                text: 'Voted',
                              ),
                            ]),
                            SizedBox(
                              height: 400,
                              child: TabBarView(children: [
                                postedPolls,
                                votedPolls,
                              ]),
                            )
                          ],
                        ),
                      ))
                    : Column(
                        children: <Widget>[
                          SizedBox(height: kIsWeb ? 20 : kSpacingUnit.w * 5),
                          header,
                          TabBar(tabs: [
                            Tab(
                              key: _postedKey,
                              text: 'Posted',
                            ),
                            Tab(
                              key: _votedKey,
                              text: 'Voted',
                            ),
                          ]),
                          SizedBox(
                            height: 400,
                            child: TabBarView(children: [
                              postedPolls,
                              votedPolls,
                            ]),
                          )
                        ],
                      ))));
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

    await _preferences.setBool("didShowProfileTutorial", true);
  }

  void initTargets() {
    targets.clear();
    targets.add(
      TargetFocus(
        identify: "_editProfileKey",
        keyTarget: _editProfileKey,
        alignSkip: Alignment.bottomLeft,
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
                    "Edit Profile",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "Click the button to edit the profile information.",
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
        identify: "_postedKey",
        keyTarget: _postedKey,
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
                    "Posted",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "This tab shows all the posted polls by you",
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
        identify: "_votedKey",
        keyTarget: _votedKey,
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
                    "Voted polls",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 10.0),
                    child: Text(
                      "This tab shows all the voted polls by you",
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
