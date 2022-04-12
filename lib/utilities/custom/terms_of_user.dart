import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:pollstrix/services/theme_service.dart';

class TermsOfUse extends StatelessWidget {
  const TermsOfUse({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
            text: 'By creating an account, you are agreeing to our\n',
            style: kCaptionTextStyle.copyWith(
                color: Colors.blueGrey, fontWeight: FontWeight.w300),
            children: [
              TextSpan(
                  text: "Terms & conditions",
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              child: Column(
                                children: [
                                  Expanded(
                                      child: FutureBuilder(
                                    future: Future.delayed(
                                            const Duration(milliseconds: 150))
                                        .then((value) {
                                      return rootBundle.loadString(
                                          'assets/terms_and_conditions.md');
                                    }),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Markdown(
                                            data: snapshot.data.toString());
                                      }
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    },
                                  )),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Close'),
                                  )
                                ],
                              ),
                            );
                          });
                    }),
              const TextSpan(text: ' and '),
              TextSpan(
                  text: 'Privacy Policy',
                  recognizer: TapGestureRecognizer()
                    ..onTap = () {
                      showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8)),
                              child: Column(
                                children: [
                                  Expanded(
                                      child: FutureBuilder(
                                    future: Future.delayed(
                                            const Duration(milliseconds: 150))
                                        .then((value) {
                                      return rootBundle.loadString(
                                          'assets/privacy_policy.md');
                                    }),
                                    builder: (context, snapshot) {
                                      if (snapshot.hasData) {
                                        return Markdown(
                                            data: snapshot.data.toString());
                                      }
                                      return const Center(
                                          child: CircularProgressIndicator());
                                    },
                                  )),
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Close'),
                                  )
                                ],
                              ),
                            );
                          });
                    },
                  style: const TextStyle(fontWeight: FontWeight.w500))
            ]),
      ),
    );
  }
}
