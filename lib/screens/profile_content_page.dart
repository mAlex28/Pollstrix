import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/services/theme_service.dart';
import 'package:pollstrix/custom/poll_tile.dart';
import 'package:pollstrix/screens/user_page.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:provider/provider.dart';

class ProfileContentPage extends StatefulWidget {
  const ProfileContentPage({Key? key}) : super(key: key);

  @override
  _ProfileContentPageState createState() => _ProfileContentPageState();
}

class _ProfileContentPageState extends State<ProfileContentPage> {
  final db = FirebaseFirestore.instance;
  final currentUser = AuthenticationService().getCurrentUID();
  final currentUserEmail = AuthenticationService().getCurrentUserEmail();
  final urlImage = "assets/images/avatar.png";
  var userImage;
  var userSelectedOption;

  @override
  void initState() {
    super.initState();

    userImage = AuthenticationService().getProfileImage();
    _getVoteDataOfUsers();
  }

  @override
  void didChangeDependencies() {
    userImage = AuthenticationService().getProfileImage();
    super.didChangeDependencies();
  }

  _getVoteDataOfUsers() async {
    await db.collection('polls').get().then((value) {
      value.docs.map((e) {
        List<dynamic> voteDataList = e.data()['voteData'];
        for (var vote in voteDataList) {
          if (vote.containsKey('uid') ?? false) {
            if (vote!['uid'] == currentUser) {
              setState(() {
                userSelectedOption = vote['option'];
              });
              return;
            }
          }
        }
      }).toList();
    });
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
                  backgroundImage: userImage,
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
            future:
                Provider.of<AuthenticationService>(context).getCurrentUser(),
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
          child: StreamBuilder<QuerySnapshot>(
        stream: db
            .collection('polls')
            .where('uid', isEqualTo: currentUser)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.none ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text('No data'),
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
    ]);

    var votedPolls = Column(children: [
      Flexible(
          child: StreamBuilder<QuerySnapshot>(
        stream: db.collection('polls').where('voteData', arrayContains: {
          'uid': currentUser,
          'option': userSelectedOption
        }).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.none ||
              snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } else if (!snapshot.hasData) {
            return const Center(
              child: Text('No data'),
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
