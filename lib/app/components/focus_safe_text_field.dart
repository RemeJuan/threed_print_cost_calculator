import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A text field that accepts an external text value but only writes
/// it into the controller when the field is not focused (avoids clobbering
/// user input while they are typing).
class FocusSafeTextField extends StatefulWidget {
  final TextEditingController controller;
  final String externalText;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator;
  final AutovalidateMode? autovalidateMode;
  final InputDecoration? decoration;
  final TextInputType? keyboardType;
  final bool? obscureText;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;

  const FocusSafeTextField({
    super.key,
    required this.controller,
    required this.externalText,
    this.focusNode,
    this.onChanged,
    this.validator,
    this.autovalidateMode,
    this.decoration,
    this.keyboardType,
    this.obscureText,
    this.textInputAction,
    this.inputFormatters,
  });

  @override
  State<FocusSafeTextField> createState() => _FocusSafeTextFieldState();
}

class _FocusSafeTextFieldState extends State<FocusSafeTextField> {
  FocusNode? _internalNode;
  bool _ownsNode = false;

  FocusNode get _node => widget.focusNode ?? _internalNode!;

  @override
  void initState() {
    super.initState();
    if (widget.focusNode == null) {
      _internalNode = FocusNode();
      _ownsNode = true;
    } else {
      // Do not allocate an internal node when an external one is provided
      _internalNode = null;
      _ownsNode = false;
    }

    _node.addListener(_onFocusChange);

    // Initialize controller text if not focused
    if (!_node.hasFocus && widget.controller.text != widget.externalText) {
      _setControllerTextPreservingSelection(widget.externalText);
    }
  }

  @override
  void didUpdateWidget(covariant FocusSafeTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If the focusNode changed ownership, adjust listeners
    if (oldWidget.focusNode != widget.focusNode) {
      // If the old widget previously used an internal node (we owned it),
      // remove its listener and dispose it to avoid leaks.
      if (oldWidget.focusNode == null || _ownsNode) {
        _internalNode?.removeListener(_onFocusChange);
        _internalNode?.dispose();
        _internalNode = null;
        _ownsNode = false;
      } else {
        // Old widget had an external node; only remove listener from it.
        oldWidget.focusNode?.removeListener(_onFocusChange);
      }

      // If the new widget needs an internal node, create it now.
      if (widget.focusNode == null && !_ownsNode) {
        _internalNode = FocusNode();
        _ownsNode = true;
      }

      // Attach listener to the current node.
      _node.addListener(_onFocusChange);
    }

    // When external text changes, update controller only if not focused
    if (!_node.hasFocus && widget.controller.text != widget.externalText) {
      _setControllerTextPreservingSelection(widget.externalText);
    }
  }

  void _onFocusChange() {
    // When field loses focus, ensure controller reflects external state.
    if (!_node.hasFocus && widget.controller.text != widget.externalText) {
      _setControllerTextPreservingSelection(widget.externalText);
    }
  }

  void _setControllerTextPreservingSelection(String text) {
    final previous = widget.controller.value;
    // Try to preserve a sensible selection offset relative to the new text length
    final previousOffset = previous.selection.end.clamp(
      0,
      previous.text.length,
    );
    final newOffset = previousOffset.clamp(0, text.length);

    widget.controller.value = TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: newOffset),
      composing: TextRange.empty,
    );
  }

  @override
  void dispose() {
    _node.removeListener(_onFocusChange);
    if (_ownsNode) {
      _internalNode?.dispose();
      _internalNode = null;
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      focusNode: _node,
      onChanged: widget.onChanged,
      validator: widget.validator,
      autovalidateMode: widget.autovalidateMode,
      keyboardType: widget.keyboardType,
      decoration: widget.decoration,
      obscureText: widget.obscureText ?? false,
      textInputAction: widget.textInputAction,
      inputFormatters: widget.inputFormatters,
    );
  }
}
