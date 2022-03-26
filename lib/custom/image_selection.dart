import 'dart:io';
import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:pollstrix/constants.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:provider/provider.dart';

class UserImage extends StatefulWidget {
  final Function(String imageUrl) onFileChanged;
  final bool isProfile;

  const UserImage(
      {Key? key, required this.onFileChanged, required this.isProfile})
      : super(key: key);

  @override
  _UserImageState createState() => _UserImageState();
}

class _UserImageState extends State<UserImage> {
  final ImagePicker _imagePicker = ImagePicker();
  String? imageUrl;

  _getUserProfile() async {
    if (widget.isProfile) {
      final profile =
          await Provider.of<AuthenticationService>(context).getCurrentUser();

      setState(() {
        imageUrl = profile.photoURL;
      });
    }
  }

  @override
  void didChangeDependencies() {
    _getUserProfile();
    super.didChangeDependencies();
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

    return Column(
      children: [
        if (imageUrl == null)
          const Icon(Icons.image, size: 68, color: kAccentColor),
        if (imageUrl != null)
          InkWell(
            splashColor: kAccentColor,
            highlightColor: kAccentColor,
            onTap: () => _selectPhoto(),
            child: AppRoundImage.url(imageUrl!, height: 80, width: 80),
          ),
        InkWell(
          onTap: () => _selectPhoto(),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              imageUrl != null ? 'Change photo' : 'Select photo',
              style: kTitleTextStyle.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        )
      ],
    );
  }

  Future _selectPhoto() async {
    await showModalBottomSheet(
        context: context,
        builder: (context) => BottomSheet(
            onClosing: () {},
            builder: (context) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ListTile(
                      leading: const Icon(Icons.camera),
                      title: const Text('Take a picture'),
                      onTap: () {
                        Navigator.of(context).pop();
                        _pickImage(ImageSource.camera);
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.photo),
                      title: const Text('Select from gallery'),
                      onTap: () {
                        Navigator.of(context).pop();
                        _pickImage(ImageSource.gallery);
                      },
                    )
                  ],
                )));
  }

  Future _pickImage(ImageSource source) async {
    final pickedFile =
        await _imagePicker.pickImage(source: source, imageQuality: 50);

    if (pickedFile == null) {
      return;
    }

    // var file = await ImageCropper().cropImage(
    //     sourcePath: pickedFile.path,
    //     aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1));

    // if (file == null) {
    //   return;
    // }

    // file = await compressImage(file.path, 35);

    await _uploadFile(pickedFile.path);
  }

  // Future<File> compressImage(String path, int quality) async {
  //   final targetPath = p.join((await getTemporaryDirectory()).path,
  //       '${DateTime.now()}.${p.extension(path)}');

  //   // final result = await FlutterImageCompress.compressAndGetFile(
  //   //     path, targetPath,
  //   //     quality: quality);

  //   return targetPath;
  // }

  Future _uploadFile(String path) async {
    final ref = storage.FirebaseStorage.instance
        .ref()
        .child('user/profile')
        .child(DateTime.now().toIso8601String() + p.basename(path));

    final result = await ref.putFile(File(path));

    final fileUrl = await result.ref.getDownloadURL();

    setState(() {
      imageUrl = fileUrl;
    });

    widget.onFileChanged(fileUrl);
  }
}

class AppRoundImage extends StatelessWidget {
  final dynamic imageProvider;
  final double height;
  final double width;

  const AppRoundImage(this.imageProvider,
      {Key? key, required this.height, required this.width})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height / 2),
      child: Image(
        image: imageProvider,
        height: height,
        width: width,
      ),
    );
  }

  factory AppRoundImage.url(String url,
      {required double height, required double width}) {
    return AppRoundImage(NetworkImage(url), height: height, width: width);
  }

  factory AppRoundImage.memory(Uint8List data,
      {required double height, required double width}) {
    return AppRoundImage(MemoryImage(data), height: height, width: width);
  }
}
