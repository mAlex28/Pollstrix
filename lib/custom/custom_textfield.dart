import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController textEditingController;
  final String label;
  final bool password;
  final TextInputType keyboardType;
  final IconButton? suffixIcon;
  final Icon? prefixIcon;
  final int minLines;
  final int maxLines;
  final FormFieldValidator<String>? fieldValidator;

  const CustomTextField(
      {Key? key,
      required this.textEditingController,
      required this.label,
      this.password = true,
      this.fieldValidator,
      this.keyboardType = TextInputType.text,
      this.prefixIcon,
      this.minLines = 1,
      this.maxLines = 1,
      this.suffixIcon})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      minLines: minLines,
      maxLines: maxLines,
      keyboardType: keyboardType,
      autofocus: false,
      obscureText: password,
      validator: fieldValidator,
      controller: textEditingController,
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
          suffixIcon: suffixIcon,
          hintText: label,
          prefixIcon: prefixIcon,
          contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(30))),
    );
  }
}
