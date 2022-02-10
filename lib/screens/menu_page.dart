import 'package:flutter/material.dart';
import 'package:pollstrix/models/user_model.dart';
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
  User user = User("", "", "", "");
  final urlImage =
      'https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&ixlib=rb-1.2.1&auto=format&fit=crop&w=634&q=80';

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
              const SizedBox(height: 24),
              buildMenuItem(
                text: 'Language',
                icon: Icons.language_rounded,
                onClicked: () => {},
              ),
              const SizedBox(height: 24),
              buildMenuItem(
                text: 'Sign out',
                icon: Icons.door_back_door,
                onClicked: () => {},
              ),
            ],
          ),
        )
      ],
    );
  }

  Widget buildHeader(context, snapshot) {
    final userData = snapshot.data;

    return InkWell(
        onTap: () {},
        child: Container(
          color: Colors.amber,
          padding: const EdgeInsets.symmetric(horizontal: 20).add(
            (const EdgeInsets.symmetric(vertical: 40)),
          ),
          child: Row(
            children: [
              CircleAvatar(radius: 30, backgroundImage: NetworkImage(urlImage)),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${userData.displayName ?? "Unkown"}",
                    style:
                        const TextStyle(fontSize: 20, color: Colors.blueAccent),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${userData.email ?? "Unkown"}",
                    style:
                        const TextStyle(fontSize: 14, color: Colors.blueAccent),
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
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => const UserPage(),
        ));
        break;
      case 1:
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => TestPage(),
        ));
        break;
    }
  }

  // _getUserData() async {
  //   final uid = await Provider.of(context).auth.getCurrentUID();

  // }
}
