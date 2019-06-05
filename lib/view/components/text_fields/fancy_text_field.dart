import 'package:flutter/material.dart';

class FancyTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final IconData suffixIcon;
  final FocusNode fancyTextFieldFocusNode;
  final TextEditingController fancyTextFieldController;
  final FocusNode nextFocus;

  FancyTextField(this.fancyTextFieldController, this.fancyTextFieldFocusNode,
      {this.label = '', @required this.icon, this.suffixIcon, this.nextFocus});

  @override
  _FancyTextFieldState createState() =>
      _FancyTextFieldState(suffixIcon != null ? true : false);
}

class _FancyTextFieldState extends State<FancyTextField> {
  bool _obscureText;
  TextInputAction onSubmitAction;

  _FancyTextFieldState(this._obscureText);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(top: 20.0, bottom: 20.0, left: 25.0, right: 25.0),
      child: TextFormField(
        focusNode: widget.fancyTextFieldFocusNode,
        onFieldSubmitted: (term) => handleSubmission(context),
        controller: widget.fancyTextFieldController,
        obscureText: _obscureText,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
            fontFamily: "WorkSansSemiBold",
            fontSize: 16.0,
            color: Colors.black),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: widget.icon != null
              ? Icon(
                  widget.icon,
                  color: Colors.black,
                  size: 22.0,
                )
              : null,
          hintText: widget.label,
          hintStyle: TextStyle(fontFamily: "WorkSansSemiBold", fontSize: 17.0),
          suffixIcon: widget.suffixIcon != null
              ? GestureDetector(
                  onTap: _toggleTextObscuration,
                  child: Icon(
                    widget.suffixIcon,
                    size: 15.0,
                    color: Colors.black,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    onSubmitAction =
        widget.nextFocus != null ? TextInputAction.next : TextInputAction.done;
  }

  void _toggleTextObscuration() {
    setState(() {
      _obscureText = !_obscureText;
    });
  }

  void handleSubmission(BuildContext context){
    if(widget.nextFocus!=null) FocusScope.of(context).requestFocus(widget.nextFocus);
  }

}
