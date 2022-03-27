import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/services/theme_service.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({Key? key}) : super(key: key);

  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  static const loremIpsum =
      "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Curabitur scelerisque, orci vel placerat sodales, lorem arcu bibendum eros, eu ultricies enim velit id nisi. Maecenas quis mollis neque, non bibendum sapien. Nulla eu posuere quam. Nunc lobortis facilisis velit vel malesuada. Nam aliquam tortor in tellus ultricies vehicula. Nullam vestibulum posuere tristique. Sed aliquet metus eu leo blandit, ut viverra nisl vehicula. Phasellus justo ex, ultricies eget nibh at, pulvinar tristique ante. Morbi iaculis hendrerit ultricies. Curabitur egestas, quam id rutrum convallis, nibh erat pellentesque risus, quis pretium tortor ex non mauris. Aenean faucibus dolor sed porttitor ullamcorper. ";

  List<Item> items = [
    Item(
        header: 'How to use this app?',
        body: 'You can post a question on app within'),
    Item(header: 'What happens after the date expired?', body: loremIpsum),
    Item(header: 'Item 3', body: loremIpsum),
    Item(header: 'Item 4', body: loremIpsum),
    Item(header: 'Item 5', body: loremIpsum),
  ];

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
        iconTheme: Theme.of(context).iconTheme,
        centerTitle: true,
        title: Text(
          'FAQ',
          style: kTitleTextStyle.copyWith(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: SingleChildScrollView(
          padding: const EdgeInsets.all(10.0),
          child: ExpansionPanelList.radio(
            expandedHeaderPadding: const EdgeInsets.only(bottom: 0.0),
            children: items
                .map((item) => ExpansionPanelRadio(
                      canTapOnHeader: true,
                      value: item.header,
                      headerBuilder: (context, isExpanded) => ListTile(
                        title: Text(
                          item.header,
                          style: kTitleTextStyle,
                        ),
                      ),
                      body: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Text(
                          item.body,
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: ScreenUtil().setSp(kSpacingUnit.w * 1.3),
                          ),
                        ),
                      ),
                    ))
                .toList(),
          )),
    );
  }
}

class Item {
  final String header;
  final String body;

  Item({required this.header, required this.body});
}
