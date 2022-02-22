import 'package:flutter/material.dart';
import 'package:pollstrix/models/poll_model.dart';
import 'package:pollstrix/custom/poll_form_options.dart';

class PollForm extends StatefulWidget {
  const PollForm({Key? key}) : super(key: key);

  @override
  _PollFormState createState() => _PollFormState();
}

class _PollFormState extends State<PollForm> {
  late GlobalKey<FormState> _formKey;
  late TextEditingController _titleController;
  late Poll _poll;

  @override
  void initState() {
    super.initState();
    _formKey = GlobalKey<FormState>();
    _titleController = TextEditingController();
    _poll = Poll();
  }

  void _saveTitleValue(String? title) {
    setState(() => _poll.title = title);
  }

  void _saveOptionValue(String option, int index) {
    setState(() {
      _poll.options ??= [];

      if (index >= _poll.options!.length) {
        _poll.options!.add(option);
      } else {
        _poll.options![index] = option;
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const choicePollOptions = ['First', 'Second', 'Extra', 'Extra'];

    return Scaffold(
        body: SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 16.0),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _titleController,
                    validator: (title) {
                      if (title!.isEmpty) return 'Please, provide a title';
                      return null;
                    },
                    onSaved: _saveTitleValue,
                    decoration: const InputDecoration(
                      labelText: 'Question title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  const Divider(),
                  const SizedBox(height: 16.0),
                  PollFormOptions(
                    key: const Key('choice'),
                    optionTitles: choicePollOptions,
                    initialOptions: _poll.options,
                    saveValue: _saveOptionValue,
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: Theme.of(context).primaryColor,
                      onPrimary: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                    ),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();

                        _poll.isAuth = true;

                        Navigator.of(context).pop(
                          ChoicePoll.fromPoll(
                            _poll,
                            optionsVoteCount: List.filled(
                              _poll.options!.length,
                              0,
                              growable: false,
                            ),
                          ),
                        );
                      }
                    },
                    child: const Text('Create poll'),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    ));
  }
}
