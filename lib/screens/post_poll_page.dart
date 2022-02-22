import 'package:flutter/material.dart';
import 'package:pollstrix/models/poll_model.dart';
import 'package:pollstrix/custom/poll_form_options.dart';
import 'package:pollstrix/services/auth_service.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class PostPollPage extends StatefulWidget {
  const PostPollPage({Key? key}) : super(key: key);

  @override
  _PostPollPageState createState() => _PostPollPageState();
}

class _PostPollPageState extends State<PostPollPage> {
  late GlobalKey<FormState> _formKey;

  late TextEditingController _textEditingController;
  late Poll _poll;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();

    _textEditingController = TextEditingController();
    _poll = Poll();
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
          title: const Text('Add new Poll'),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => Navigator.of(context).pop(),
          )),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12.0),
        child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: TextFormField(
                    onSaved: _saveTitle,
                    controller: _textEditingController,
                    keyboardType: TextInputType.multiline,
                    minLines: 5,
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
                Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ElevatedButton.icon(
                      // style: ElevatedButton.styleFrom(
                      //   primary: Colors.lightBlue[300],
                      //   shape: RoundedRectangleBorder(
                      //     borderRadius: BorderRadius.circular(10.0),
                      //   ),
                      // ),
                      onPressed: () {
                        showDialog<Widget>(
                            context: context,
                            builder: (BuildContext builder) {
                              return AlertDialog(
                                  backgroundColor: Colors.white,
                                  content: SizedBox(
                                    height: 500,
                                    width: 300,
                                    child: SfDateRangePicker(
                                      showActionButtons: true,
                                      selectionMode:
                                          DateRangePickerSelectionMode.range,
                                      onCancel: () {
                                        Navigator.pop(context);
                                      },
                                    ),
                                  ));
                            });
                      },
                      icon: const Icon(
                        Icons.calendar_today_rounded,
                      ),
                      label: const Text('Select date range')),
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
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _formKey.currentState!.save();
                          }

                          _poll.isAuth = true;

                          authService.post(
                              title: _textEditingController.text,
                              choices: _poll.options,
                              createdTime: DateTime.now());
                        },
                        icon: const Icon(Icons.post_add_rounded),
                        label: const Text('Post'))),
              ],
            )),
      ),
    );
  }
}
