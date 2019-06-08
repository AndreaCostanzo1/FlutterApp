import 'package:flutter/material.dart';

class FancyTextField extends StatefulWidget {
  final String label;
  final IconData icon;
  final IconData suffixIcon;
  final FocusNode fancyTextFieldFocusNode;
  final TextEditingController fancyTextFieldController;
  final FocusNode nextFocus;
  final bool error;
  final EdgeInsets insets;

  FancyTextField(this.fancyTextFieldController, this.fancyTextFieldFocusNode,
      {this.label = '',
      @required this.icon,
      this.suffixIcon,
      this.nextFocus,
      this.error = false,
      this.insets = const EdgeInsets.only(
          top: 20.0, bottom: 20.0, left: 25.0, right: 25.0)});

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
      padding: widget.insets,
      child: TextFormField(
        focusNode: widget.fancyTextFieldFocusNode,
        onFieldSubmitted: (term) => handleSubmission(context),
        controller: widget.fancyTextFieldController,
        obscureText: _obscureText,
        keyboardType: TextInputType.emailAddress,
        style: TextStyle(
          fontFamily: "WorkSansSemiBold",
          fontSize: 16.0,
          color: widget.error
              ? Theme.of(context).errorColor
              : Theme.of(context).textTheme.title.color,
        ),
        decoration: InputDecoration(
          border: InputBorder.none,
          icon: widget.icon != null
              ? Icon(
                  widget.icon,
                  color: Theme.of(context).textTheme.title.color,
                  size: 22.0,
                )
              : null,
          hintText: widget.label,
          hintStyle: TextStyle(fontFamily: "WorkSansSemiBold", fontSize: 17.0),
          suffixIcon: _MySuffixIcon(
              widget.suffixIcon, widget.error, () => _toggleTextObscuration()),
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

  void handleSubmission(BuildContext context) {
    if (widget.nextFocus != null) {
      FocusScope.of(context).requestFocus(widget.nextFocus);
    }
  }
}

class _MySuffixIcon extends StatelessWidget {
  final IconData _suffixIcon;
  final bool _error;
  final VoidCallback _callback;

  _MySuffixIcon(this._suffixIcon, this._error, this._callback);

  @override
  Widget build(BuildContext context) {
    return _error
        ? Icon(
            Icons.error,
            color: Theme.of(context).errorColor,
            size: 15,
          )
        : _suffixIcon != null
            ? GestureDetector(
                onTap: _callback,
                child: Icon(
                  _suffixIcon,
                  size: 15.0,
                  color: Theme.of(context).textTheme.title.color,
                ),
              )
            : Icon(
                Icons.error,
                color: Theme.of(context).cardColor,
                size: 15,
              );
  }
}
