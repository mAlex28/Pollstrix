// import 'package:flutter/material.dart';
// import 'package:flutter_neumorphic/flutter_neumorphic.dart';
// import 'package:intl/intl.dart';
// import 'package:pollstrix/custom/custom_textfield.dart';
// import 'package:pollstrix/models/user_model.dart';
// import 'package:pollstrix/services/auth_service.dart';
// import 'package:provider/provider.dart';

// class UserPage extends StatefulWidget {
//   const UserPage({Key? key}) : super(key: key);

//   @override
//   _UserPageState createState() => _UserPageState();
// }

// class _UserPageState extends State<UserPage> {

//    User user = User("", "", "", "", "", "");
//   var _loading = false;
//   final _formKey = GlobalKey<FormState>();
//   String _imageUrl = '';

//   final TextEditingController _fnameController = TextEditingController();
//   final TextEditingController _lnameController = TextEditingController();
//   final TextEditingController _usernameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _passwordController = TextEditingController();

//   Color _textColor(BuildContext context) {
//     if (NeumorphicTheme.isUsingDark(context)) {
//       return Colors.white;
//     } else {
//       return Colors.white;
//     }
//   }

//   String? _formFieldsValidator(String? text) {
//     if (text == null || text.trim().isEmpty) {
//       return 'This field is required';
//     }
//     return null;
//   }

//   String? _emailFieldValidator(String? text) {
//     String pattern =
//         r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+";
//     RegExp regExp = RegExp(pattern);

//     if (text == null || text.trim().isEmpty) {
//       return 'This field is required';
//     } else if (!regExp.hasMatch(text.trim())) {
//       return 'Invalid email address';
//     }

//     return null;
//   }

//   String? _passwordFieldValidator(String? text) {
//     String pattern =
//         r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
//     RegExp regExp = RegExp(pattern);

//     if (text == null || text.trim().isEmpty) {
//       return 'This field is required';
//     } else if (!regExp.hasMatch(text.trim())) {
//       return 'Password should be 8 characters with mix of 1 uppercase, 1 lower case, 1 digit and 1 special character';
//     }

//     return null;
//   }

//   @override
//   Widget build(BuildContext context) {


//     return Scaffold(
//         backgroundColor: NeumorphicTheme.baseColor(context),
//         body: SafeArea(
//             child: Container(
//                width: MediaQuery.of(context).size.width,
//                 padding:
//                     const EdgeInsets.symmetric(horizontal: 15, vertical: 20),
//                 child:
//             Column(
//           children: <Widget>[
//             FutureBuilder(
//               future: Provider.of<AuthenticationService>(context).getCurrentUser(),
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   return _displayUserInformation(context, snapshot);
//                 } else {
//                   return const CircularProgressIndicator();
//                 }
//               },
//             )
//           ],
//         ),
        
//                 )
                
//                 ));
//   }

//   _displayUserInformation(context, snapshot) {
//     final authData = snapshot.data;

//     return Column(
//       children: <Widget>[
//         Padding(
//           padding: const EdgeInsets.only(top: 10.0),
//           child: Provider.of<AuthenticationService>(context).getProfileImage(),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text(
//             "Name: ${authData.displayName ?? 'Anonymous'}",
//             style: TextStyle(fontSize: 20),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text(
//             "Email: ${authData.email ?? 'Anonymous'}",
//             style: TextStyle(fontSize: 20),
//           ),
//         ),
//         Padding(
//           padding: const EdgeInsets.all(8.0),
//           child: Text(
//             "Created: ${DateFormat('MM/dd/yyyy').format(authData.metadata.creationTime)}",
//             style: TextStyle(fontSize: 20),
//           ),
//         ),
//         FutureBuilder(
//             future: _getProfileData(),
//             builder: (context, snapshot) {
//               if (snapshot.connectionState == ConnectionState.done) {
//                 _usernameController.text = user.username;
//               }
//               return Container(
//                 child: Column(
//                   children: <Widget>[
//                     Padding(
//                       padding: const EdgeInsets.all(8.0),
//                       child: Text(
//                         "Home Country: ${_usernameController.text}",
//                         style: TextStyle(fontSize: 20),
//                       ),
//                     ),
                
//                   ],
//                 ),
//               );
//             }),
    
//         ElevatedButton(
//           child: Text("Edit User"),
//           onPressed: () {
//             // _userEditBottomSheet(context);
//           },
//         )
//       ],
//     );
//   }

//   //  _getProfileData() async {
//   //   final uid = await Provider.of(context).auth.getCurrentUID();
//   //   await Provider.of(context)
//   //       .db
//   //       .collection('users')
//   //       .document(uid)
//   //       .get()
//   //       .then((result) {
//   //     user.homeCountry = result.data['homeCountry'];
//   //     user.admin = result.data['admin'];
//   //   });
//   // }
// }
