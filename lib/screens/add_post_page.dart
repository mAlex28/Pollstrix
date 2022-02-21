import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({Key? key}) : super(key: key);

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  final TextEditingController _textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 10.0),
                child: TextField(
                  controller: _textEditingController,
                  keyboardType: TextInputType.multiline,
                  minLines: 5,
                  maxLines: null,
                  decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.all(10.0),
                      focusedBorder: OutlineInputBorder(
                        borderSide:
                            BorderSide(color: Colors.grey.shade500, width: 1.5),
                      ),
                      hintText: 'Write something here!'),
                ),
              ),
              Container(
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.only(bottom: 10.0),
                child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      primary: Colors.lightBlue[300],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
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
                    icon: Icon(
                      Icons.calendar_today_rounded,
                      color: Colors.grey[50],
                      size: 24.0,
                    ),
                    label: const Text('Select date range')),
              ),
              Container(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ElevatedButton.icon(
                      onPressed: () {},
                      icon: const Icon(Icons.more_horiz_rounded),
                      label: const Text('add options'))),
              Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: ElevatedButton.icon(
                      onPressed: () {
                        // validator: (value) {
                        //   if (value!.isEmpty) return 'Title is required';
                        //   return null;
                        // },
                      },
                      icon: const Icon(Icons.post_add_rounded),
                      label: const Text('Post'))),
            ],
          )),
    );
  }
}
