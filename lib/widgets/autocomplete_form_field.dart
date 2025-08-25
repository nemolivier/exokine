import 'package:flutter/material.dart';

class AutocompleteFormField extends StatefulWidget {
  final TextEditingController controller;
  final List<String> suggestions;
  final String hintText;
  final bool isTagField;

  const AutocompleteFormField({
    super.key,
    required this.controller,
    required this.suggestions,
    required this.hintText,
    this.isTagField = false,
  });

  @override
  State<AutocompleteFormField> createState() => _AutocompleteFormFieldState();
}

class _AutocompleteFormFieldState extends State<AutocompleteFormField> {
  final FocusNode _focusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;
  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      _showOverlay();
    } else {
      _removeOverlay();
    }
  }

  void _onTextChanged() {
    final text = widget.controller.text;
    if (text.isEmpty) {
      _filteredSuggestions = [];
    } else {
      String query = text;
      if (widget.isTagField) {
        query = text.split(',').last.trim();
      }
      if (query.isEmpty) {
        _filteredSuggestions = [];
      } else {
        _filteredSuggestions = widget.suggestions
            .where((s) => s.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    }
    _updateOverlay();
  }

  void _showOverlay() {
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!); 
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  void _updateOverlay() {
    _overlayEntry?.markNeedsBuild();
  }

  void _onSuggestionSelected(String selection) {
      if (widget.isTagField) {
        final List<String> allTags = widget.controller.text.split(',').map((t) => t.trim()).toList();
        if (allTags.isNotEmpty) {
          allTags.removeLast();
        }
        allTags.add(selection);
        widget.controller.text = allTags.where((t) => t.isNotEmpty).join(', ') + ', ';
      } else {
        widget.controller.text = selection;
      }
      widget.controller.selection = TextSelection.fromPosition(TextPosition(offset: widget.controller.text.length));
      _focusNode.unfocus();
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Positioned(
        width: size.width,
        child: CompositedTransformFollower(
          link: _layerLink,
          showWhenUnlinked: false,
          offset: Offset(0.0, size.height + 5.0),
          child: Material(
            elevation: 4.0,
            child: ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 200),
                child: _filteredSuggestions.isEmpty
                    ? const SizedBox.shrink()
                    : ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: _filteredSuggestions.length,
                        itemBuilder: (context, index) {
                          final option = _filteredSuggestions[index];
                          return ListTile(
                            title: Text(option),
                            onTap: () => _onSuggestionSelected(option),
                          );
                        },
                      ),),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        decoration: InputDecoration(hintText: widget.hintText),
        onSubmitted: (_) {
          if (_filteredSuggestions.isNotEmpty) {
            _onSuggestionSelected(_filteredSuggestions.first);
          }
        },
      ),
    );
  }
}