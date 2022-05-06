import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pollstrix/services/theme_service.dart';

class FAQPage extends StatefulWidget {
  const FAQPage({Key? key}) : super(key: key);

  @override
  _FAQPageState createState() => _FAQPageState();
}

class _FAQPageState extends State<FAQPage> {
  List<Item> items = [
    Item(
        header: 'What is the purpose of this application?',
        body:
            'The old system of conducting surveys is to visit the area and meet people face to face. This process takes time and cost. Pollstrix application allows to conduct surveys online and without cost. '),
    Item(
        header: 'What happens after a poll expired?',
        body:
            'After the poll date expired the results of the poll will be calculated. The calculated results can be view as bar charts or pie charts'),
    Item(
        header: 'Can other user see my voted polls?',
        body: 'No, You are the only one who can view your polls.'),
    Item(
        header: 'How can I report a poll?',
        body:
            'You can click on the menu button on the poll and choose report option. Our admins will review the poll and delete if they are considered as spam or malicious'),
    Item(
        header: 'Can I create collection of polls?',
        body: 'Not yet. But this is one of the upcoming features'),
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
          AppLocalizations.of(context)!.faq,
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
                          style: kCaptionTextStyle.copyWith(
                            fontSize: ScreenUtil().setSp(kSpacingUnit.w * 1.15),
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
