import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pollstrix/constants/routes.dart';
import 'package:pollstrix/services/auth/auth_service.dart';
import 'package:pollstrix/services/theme_service.dart';
import 'package:timer_button/timer_button.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({Key? key}) : super(key: key);

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailPageState();
}

class _VerifyEmailPageState extends State<VerifyEmailPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
            child: SingleChildScrollView(
                child: kIsWeb
                    ? SizedBox(
                        width: 400,
                        child: Padding(
                          padding: const EdgeInsets.all(30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            verticalDirection: VerticalDirection.down,
                            children: <Widget>[
                              SizedBox(
                                height: kToolbarHeight * 0.7,
                                child: Image.asset(
                                  "assets/images/logo_inapp.png",
                                  color: kAccentColor,
                                ),
                              ),
                              const SizedBox(
                                height: 30,
                              ),
                              const Text(
                                "Please check your inbox to verify the email! If you haven't received an email yet press the button below to request a new vefication link.",
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              TimerButton(
                                  label: 'Re-Send email',
                                  buttonType: ButtonType.TextButton,
                                  disabledColor: Colors.grey,
                                  color: kAccentColor,
                                  onPressed: () async {
                                    await AuthService.firebase()
                                        .sendEmailVerification();
                                  },
                                  timeOutInSeconds: 60),
                              const Text(
                                "Already verifed? Press the below button and login to continue",
                                textAlign: TextAlign.center,
                              ),
                              TextButton(
                                  style: ButtonStyle(
                                    padding: MaterialStateProperty.all(
                                        const EdgeInsets.symmetric(
                                            vertical: 12, horizontal: 40)),
                                  ),
                                  onPressed: () async {
                                    await AuthService.firebase().logOut();
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                            loginRoute, (route) => false);
                                  },
                                  child: const Text(
                                    "Login",
                                    textAlign: TextAlign.center,
                                  )),
                            ],
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.all(30),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          verticalDirection: VerticalDirection.down,
                          children: <Widget>[
                            SizedBox(
                              height: kToolbarHeight * 0.7,
                              child: Image.asset(
                                "assets/images/logo_inapp.png",
                                color: kAccentColor,
                              ),
                            ),
                            const SizedBox(
                              height: 30,
                            ),
                            const Text(
                              "Please check your inbox to verify the email! If you haven't received an email yet press the button below to request a new vefication link.",
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            TimerButton(
                                label: 'Re-Send email',
                                buttonType: ButtonType.TextButton,
                                disabledColor: Colors.grey,
                                color: kAccentColor,
                                onPressed: () async {
                                  await AuthService.firebase()
                                      .sendEmailVerification();
                                },
                                timeOutInSeconds: 60),
                            const Text(
                              "Already verifed? Press the below button and login to continue",
                              textAlign: TextAlign.center,
                            ),
                            TextButton(
                                style: ButtonStyle(
                                  padding: MaterialStateProperty.all(
                                      const EdgeInsets.symmetric(
                                          vertical: 12, horizontal: 40)),
                                ),
                                onPressed: () async {
                                  await AuthService.firebase().logOut();
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                      loginRoute, (route) => false);
                                },
                                child: const Text(
                                  "Login",
                                  textAlign: TextAlign.center,
                                )),
                          ],
                        ),
                      ))));
  }
}
