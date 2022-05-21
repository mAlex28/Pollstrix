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

    List<Item> items = [
      Item(
        header: AppLocalizations.of(context)!.faqOne,
        body: AppLocalizations.of(context)!.faqAnsOne,
      ),
      Item(
        header: AppLocalizations.of(context)!.faqTwo,
        body: AppLocalizations.of(context)!.faqAnsTwo,
      ),
      Item(
        header: AppLocalizations.of(context)!.faqThree,
        body: AppLocalizations.of(context)!.faqAnsThree,
      ),
      Item(
        header: AppLocalizations.of(context)!.faqFour,
        body: AppLocalizations.of(context)!.faqAnsFour,
      ),
      Item(
        header: AppLocalizations.of(context)!.faqFive,
        body: AppLocalizations.of(context)!.faqAnsFive,
      )
    ];
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
