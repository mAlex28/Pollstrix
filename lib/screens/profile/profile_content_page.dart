import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/services/auth/auth_service.dart';
import 'package:pollstrix/services/auth/auth_user.dart';
import 'package:pollstrix/services/cloud/cloud_storage_constants.dart';
import 'package:pollstrix/services/cloud/polls/cloud_poll.dart';
import 'package:pollstrix/services/cloud/polls/firebase_poll_functions.dart';
import 'package:pollstrix/utilities/custom/poll/poll_tile.dart';
import 'package:pollstrix/screens/profile/user_page.dart';
import 'package:pollstrix/services/theme_service.dart';

class ProfileContentPage extends StatefulWidget {
  const ProfileContentPage({Key? key}) : super(key: key);

  @override
  _ProfileContentPageState createState() => _ProfileContentPageState();
}

class _ProfileContentPageState extends State<ProfileContentPage> {
  final FirebasePollFunctions _pollService = FirebasePollFunctions();
  final currentUserId = AuthService.firebase().currentUser!.userId;
  final urlImage = "assets/images/avatar.png";

  int userSelectedOption = 0;

  @override
  void initState() {
    _getVoteDataOfUsers();
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

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

  _getProfileImage() {
    final profileImage = AuthService.firebase().currentUser!.imageUrl;

    if (profileImage != null) {
      return NetworkImage(profileImage);
    } else {
      return AssetImage(urlImage);
    }
  }

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

    Widget buildProfileInfo(context, snapshot) {
      return Expanded(
          child: Column(
        children: <Widget>[
          Container(
            height: kSpacingUnit.w * 10,
            width: kSpacingUnit.w * 10,
            margin: EdgeInsets.only(top: kSpacingUnit.w * 3),
            child: Stack(
              children: <Widget>[
                CircleAvatar(
                  radius: kSpacingUnit.w * 5,
                  backgroundImage: _getProfileImage(),
                ),
                Align(
                  alignment: Alignment.bottomRight,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => const UserPage(),
                    )),
                    child: Container(
                      height: kSpacingUnit.w * 2.5,
                      width: kSpacingUnit.w * 2.5,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.secondary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        heightFactor: kSpacingUnit.w * 1.5,
                        widthFactor: kSpacingUnit.w * 1.5,
                        child: Icon(
                          Icons.edit,
                          color: kLightPrimaryColor,
                          size: ScreenUtil().setSp(kSpacingUnit.w * 1.5),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: kSpacingUnit.w * 2),
          Text(
            '${snapshot.data.displayName ?? "Unkown"}',
            style: kTitleTextStyle,
          ),
          SizedBox(height: kSpacingUnit.w * 0.5),
          Text(
            '${snapshot.data.email ?? "Anonymous"}',
            style: kCaptionTextStyle,
          ),
          SizedBox(height: kSpacingUnit.w * 2),
        ],
      ));
    }

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
                final allPolls = snapshot.data as Iterable<CloudPoll>;
                return ListView.builder(
                  itemCount: allPolls.length,
                  itemBuilder: (context, index) {
                    final poll = allPolls.elementAt(index);
                    return PollTile(doc: poll);
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
                child: Column(
          children: <Widget>[
            SizedBox(height: kSpacingUnit.w * 5),
            header,
            const TabBar(tabs: [
              Tab(
                text: 'Posted',
              ),
              Tab(
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
}

// db.collection('polls').where(voteDataField, arrayContains: {
//           userIdField: currentUserId,
//           optionField: userSelectedOption
//         }).snapshots()
