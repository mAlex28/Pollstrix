import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pollstrix/models/poll_model.dart';
import 'package:pollstrix/custom/poll_form_options.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:pollstrix/services/theme_service.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class PostPollPage extends StatefulWidget {
  const PostPollPage({Key? key}) : super(key: key);

  @override
  _PostPollPageState createState() => _PostPollPageState();
}

class _PostPollPageState extends State<PostPollPage> {
  late GlobalKey<FormState> _formKey;
  late DateTime _startDate, _endDate;
  late TextEditingController _textEditingController;
  final DateRangePickerController _dateRangePickerController =
      DateRangePickerController();
  late Poll _poll;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _textEditingController = TextEditingController();
    _poll = Poll();
    final DateTime today = DateTime.now();
    _startDate = today;
    _endDate = today.add(const Duration(days: 7));
    _dateRangePickerController.selectedRange =
        PickerDateRange(today, today.add(const Duration(days: 7)));
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

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

  void _saveTitle(String? title) {
    setState(() => _poll.title = title);
  }

  @override
  Widget build(BuildContext context) {
    const pollChoices = ['First', 'Second', 'Additional', 'Additional'];
    final authService = Provider.of<AuthenticationService>(context);

    return Scaffold(
      appBar: AppBar(
          titleTextStyle: Theme.of(context).appBarTheme.titleTextStyle,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          title: const Text(
            'Add new Poll',
          ),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            color: kAccentColor,
            onPressed: () => Navigator.of(context).pop(),
          )),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
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
                            onPressed: () {
                              showDialog<Widget>(
                                  context: context,
                                  builder: (BuildContext builder) {
                                    return AlertDialog(
                                        backgroundColor: Colors.white,
                                        content: SizedBox(
                                          height: 450,
                                          width: 300,
                                          child: SfDateRangePicker(
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
                            label: const Text('Date'),
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
                        hintText: 'Write something here!'),
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
                          }

                          await authService.post(
                              title: _textEditingController.text,
                              choices: _poll.options,
                              createdTime: DateTime.now(),
                              startDate: _startDate,
                              endDate: _endDate,
                              context: context);
                          Navigator.of(context).pop();
                        },
                        icon: const Icon(Icons.post_add_rounded),
                        label: const Text('Post'))),
              ],
            )),
      ),
    );
  }
}
