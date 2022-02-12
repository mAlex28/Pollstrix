import 'package:flutter/material.dart';
import 'package:pollstrix/screens/tesst_screen.dart';
import 'package:pollstrix/screens/user_page.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:provider/provider.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  _MenuPageState createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> {
  final urlImage = "assets/images/avatar.png";

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        FutureBuilder(
            future:
                Provider.of<AuthenticationService>(context).getCurrentUser(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                return buildHeader(context, snapshot);
              } else {
                return const CircularProgressIndicator();
              }
            }),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 20),
              buildMenuItem(
                text: 'Language',
                icon: Icons.language_rounded,
                onClicked: () => {},
              ),
              buildMenuItem(
                text: 'Settings',
                icon: Icons.settings_rounded,
                onClicked: () => {},
              ),
              buildMenuItem(
                text: 'About us',
                icon: Icons.info_rounded,
                onClicked: () => {},
              ),
              buildMenuItem(
                text: 'Invite',
                icon: Icons.share_rounded,
                onClicked: () => {},
              ),
              buildMenuItem(
                  text: 'Sign out',
                  icon: Icons.logout_rounded,
                  onClicked: () {
                    Provider.of<AuthenticationService>(context, listen: false)
                        .signOut(context: context);
                  }),
            ],
          ),
        )
      ],
    );
  }

  Widget buildHeader(context, snapshot) {
    final userData = snapshot.data;

    return InkWell(
        onTap: () => Navigator.of(context).push(MaterialPageRoute(
              builder: (context) => const UserPage(),
            )),
        child: Container(
          color: Colors.lightBlue.shade600,
          padding: const EdgeInsets.symmetric(horizontal: 20).add(
            (const EdgeInsets.symmetric(vertical: 20)),
          ),
          child: Row(
            children: [
              CircleAvatar(radius: 30, backgroundImage: AssetImage(urlImage)),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${userData.displayName ?? "Unkown"}",
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${userData.email ?? "Anonymous"}",
                    style: const TextStyle(fontSize: 14, color: Colors.white),
                  ),
                ],
              ),
              const Spacer(),
            ],
          ),
        ));
  }

  Widget buildMenuItem(
      {required String text, required IconData icon, VoidCallback? onClicked}) {
    final color = Colors.black;
    final hoverColor = Colors.black;

    return ListTile(
      leading: Icon(
        icon,
        color: color,
      ),
      title: Text(
        text,
        style: TextStyle(color: color),
      ),
      hoverColor: hoverColor,
      onTap: onClicked,
    );
  }

  void selectedItem(BuildContext context, int index) {
    Navigator.of(context).pop();

    switch (index) {
      case 0:
        // Navigator.of(context).push(MaterialPageRoute(
        //   builder: (context) {},
        // ));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => TestPage(),
        ));
        break;
    }
  }
}
