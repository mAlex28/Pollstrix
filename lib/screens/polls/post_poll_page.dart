import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import 'package:pollstrix/services/auth/auth_service.dart';
import 'package:pollstrix/services/cloud/polls/firebase_poll_functions.dart';
import 'package:pollstrix/utilities/custom/poll/poll_form_options.dart';
import 'package:pollstrix/models/poll_model.dart';
import 'package:pollstrix/services/theme_service.dart';
import 'package:pollstrix/utilities/custom/snackbar/custom_snackbar.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class PostPollPage extends StatefulWidget {
  const PostPollPage({Key? key}) : super(key: key);

  @override
  _PostPollPageState createState() => _PostPollPageState();
}

class _PostPollPageState extends State<PostPollPage> {
  late final FirebasePollFunctions _pollService;
  late GlobalKey<FormState> _formKey;
  late DateTime _startDate, _endDate;
  late TextEditingController _textEditingController;
  final DateRangePickerController _dateRangePickerController =
      DateRangePickerController();
  late Poll _poll;
  final DateTime today = DateTime.now();

  @override
  void initState() {
    _pollService = FirebasePollFunctions();
    _formKey = GlobalKey<FormState>();
    _textEditingController = TextEditingController();
    _poll = Poll();
    _startDate = today;
    _endDate = today.add(const Duration(days: 7));
    _dateRangePickerController.selectedRange =
        PickerDateRange(today, today.add(const Duration(days: 7)));
    super.initState();
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  // save added choices
  void _saveChoices(String choice, int index) {
    setState(() {
      _poll.options ??= [];
      if (index >= _poll.options!.length) {
        _poll.options!.add(choice);
      } else {
        _poll.options![index] = choice;
      }
    });
  }

  // save poll title
  void _saveTitle(String? title) {
    setState(() => _poll.title = title);
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

    const pollChoices = [
      'First',
      'Second',
      'Additional',
      'Additional'
    ]; // only four poll choices can be added

    // flutter design and functions for web
    Widget buildForWeb() {
      return Center(
        child: SizedBox(
          width: 500,
          child: Form(
              key: _formKey,
              child: Column(
                children: [
                  Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ElevatedButton.icon(
                              style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(kAccentColor)),
                              onPressed: () async {
                                // show data picker dialog
                                await showDialog<Widget>(
                                    context: context,
                                    builder: (BuildContext builder) {
                                      return AlertDialog(
                                          backgroundColor:
                                              Theme.of(context).backgroundColor,
                                          content: SizedBox(
                                            height: 450,
                                            width: 300,
                                            child: SfDateRangePicker(
                                              todayHighlightColor: kAccentColor,
                                              selectionColor: kAccentColor,
                                              controller:
                                                  _dateRangePickerController,
                                              enablePastDates: false,
                                              onSubmit: (dynamic value) {
                                                setState(() {
                                                  _startDate = value.startDate;
                                                  _endDate = value.endDate;
                                                });
                                                Navigator.pop(context);
                                              },
                                              showActionButtons: true,
                                              selectionMode:
                                                  DateRangePickerSelectionMode
                                                      .range,
                                              onCancel: () {
                                                Navigator.of(context).pop();
                                              },
                                            ),
                                          ));
                                    });
                              },
                              icon: const Icon(
                                Icons.calendar_today_rounded,
                              ),
                              label: Text(AppLocalizations.of(context)!.date),
                            ),
                            Text(
                                '${DateFormat.yMMMEd().format(_startDate)} - ${DateFormat.yMMMEd().format(_endDate)}'),
                          ])),
                  Container(
                    padding: const EdgeInsets.only(bottom: 10.0),
                    child: TextFormField(
                      onSaved: _saveTitle,
                      controller: _textEditingController,
                      keyboardType: TextInputType.multiline,
                      minLines: 3,
                      validator: (value) {
                        if (value!.isEmpty) return 'Title is required';
                        return null;
                      },
                      maxLines: null,
                      decoration: InputDecoration(
                          isDense: true,
                          contentPadding: const EdgeInsets.all(10.0),
                          border: OutlineInputBorder(
                            borderSide: BorderSide(
                                color: Colors.grey.shade500, width: 1.5),
                          ),
                          hintText: AppLocalizations.of(context)!.wsomething),
                    ),
                  ),
                  PollFormOptions(
                      key: const Key('choice'),
                      optionTitles: pollChoices,
                      saveValue: _saveChoices,
                      initialOptions: _poll.options),
                  Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: ElevatedButton.icon(
                          style: ButtonStyle(
                              backgroundColor:
                                  MaterialStateProperty.all(kAccentColor)),
                          onPressed: () async {
                            if (_formKey.currentState!.validate()) {
                              _formKey.currentState!.save();

                              try {
                                // create a new poll if the user is logged in and all the fields are filled

                                final currentUserId =
                                    AuthService.firebase().currentUser!.userId;
                                await _pollService.createPoll(
                                    currentUserId: currentUserId,
                                    title: _textEditingController.text.trim(),
                                    choices: _poll.options,
                                    createdTime: DateTime.now(),
                                    startDate: _startDate,
                                    endDate: _endDate);
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                    CustomSnackbar.customSnackbar(
                                        content: 'Poll posted',
                                        backgroundColor: Colors.green));
                              } catch (e) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                    CustomSnackbar.customSnackbar(
                                        content: 'Oops! Something went wrong',
                                        backgroundColor: Colors.red));
                              }
                            }
                          },
                          icon: const Icon(Icons.post_add_rounded),
                          label: const Text('Post'))),
                ],
              )),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
          titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: Text(
            AppLocalizations.of(context)!.addNewPoll,
            style: kIsWeb
                ? const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  )
                : kTitleTextStyle.copyWith(fontWeight: FontWeight.w700),
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            color: kAccentColor,
            onPressed: () => Navigator.of(context).pop(),
          )),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: kIsWeb
            ? buildForWeb()
            : Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              ElevatedButton.icon(
                                style: ButtonStyle(
                                    backgroundColor: MaterialStateProperty.all(
                                        kAccentColor)),
                                onPressed: () {
                                  showDialog<Widget>(
                                      context: context,
                                      builder: (BuildContext builder) {
                                        return AlertDialog(
                                            backgroundColor: Theme.of(context)
                                                .backgroundColor,
                                            content: SizedBox(
                                              height: 450,
                                              width: 300,
                                              child: SfDateRangePicker(
                                                todayHighlightColor:
                                                    kAccentColor,
                                                selectionColor: kAccentColor,
                                                controller:
                                                    _dateRangePickerController,
                                                enablePastDates: false,
                                                onSubmit: (dynamic value) {
                                                  setState(() {
                                                    _startDate =
                                                        value.startDate;
                                                    _endDate = value.endDate;
                                                  });
                                                  Navigator.pop(context);
                                                },
                                                showActionButtons: true,
                                                selectionMode:
                                                    DateRangePickerSelectionMode
                                                        .range,
                                                onCancel: () {
                                                  Navigator.of(context).pop();
                                                },
                                              ),
                                            ));
                                      });
                                },
                                icon: const Icon(
                                  Icons.calendar_today_rounded,
                                ),
                                label: Text(AppLocalizations.of(context)!.date),
                              ),
                              Text(
                                  '${DateFormat.yMMMEd().format(_startDate)} - ${DateFormat.yMMMEd().format(_endDate)}'),
                            ])),
                    Container(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        onSaved: _saveTitle,
                        controller: _textEditingController,
                        keyboardType: TextInputType.multiline,
                        minLines: 3,
                        validator: (value) {
                          if (value!.isEmpty) return 'Title is required';
                          return null;
                        },
                        maxLines: null,
                        decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.all(10.0),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Colors.grey.shade500, width: 1.5),
                            ),
                            hintText: AppLocalizations.of(context)!.wsomething),
                      ),
                    ),
                    PollFormOptions(
                        key: const Key('choice'),
                        optionTitles: pollChoices,
                        saveValue: _saveChoices,
                        initialOptions: _poll.options),
                    Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: ElevatedButton.icon(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all(kAccentColor)),
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();

                                try {
                                  final currentUserId = AuthService.firebase()
                                      .currentUser!
                                      .userId;
                                  await _pollService.createPoll(
                                      currentUserId: currentUserId,
                                      title: _textEditingController.text.trim(),
                                      choices: _poll.options,
                                      createdTime: DateTime.now(),
                                      startDate: _startDate,
                                      endDate: _endDate);
                                  Navigator.of(context).pop();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      CustomSnackbar.customSnackbar(
                                          content: 'Poll posted',
                                          backgroundColor: Colors.green));
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                      CustomSnackbar.customSnackbar(
                                          content: 'Oops! Something went wrong',
                                          backgroundColor: Colors.red));
                                }
                              }
                            },
                            icon: const Icon(Icons.post_add_rounded),
                            label: const Text('Post'))),
                  ],
                )),
      ),
    );
  }
}
