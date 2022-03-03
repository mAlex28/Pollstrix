import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PageContent extends StatelessWidget {
  final List<Tab> tabs;
  final List<Widget> children;
  final String emptyMessage;

  const PageContent(
      {Key? key,
      required this.tabs,
      required this.emptyMessage,
      required this.children})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
        length: tabs.length,
        child: Scaffold(
          body: TabBarView(
            children: children,
            physics: const NeverScrollableScrollPhysics(),
          ),
        ));
  }
}
