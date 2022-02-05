import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController textEditingController;
  final String label;
  final bool password;
  final FormFieldValidator<String>? fieldValidator;

  const CustomTextField(
      {required this.textEditingController,
      required this.label,
      this.password = false,
      this.fieldValidator});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Neumorphic(
          margin: const EdgeInsets.only(left: 8, right: 8, top: 2, bottom: 4),
          style: NeumorphicStyle(
            depth: NeumorphicTheme.embossDepth(context),
            boxShape: const NeumorphicBoxShape.stadium(),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          child: TextFormField(
            obscureText: password,
            validator: fieldValidator,
            controller: textEditingController,
            decoration: InputDecoration.collapsed(hintText: label),
          ),
        )
      ],
    );
  }
}
