import 'package:flutter/material.dart';

class SelectPopup extends StatefulWidget {
  final List<String> keys;
  final double? popupHeight;
  final Function(String) clickCallback;
  final bool refreshing;
  const SelectPopup({
    Key? key,
    required this.keys,
    this.popupHeight,
    required this.clickCallback,
    this.refreshing = false,
  }) : super(key: key);

  @override
  State<SelectPopup> createState() => _SelectPopupState();
}

class _SelectPopupState extends State<SelectPopup> {
  String selectedKey = '';
  bool menuOpen = false;

  @override
  void initState() {
    super.initState();
    selectedKey = widget.refreshing || widget.keys.isEmpty ? '' : widget.keys.first;
    widget.clickCallback(selectedKey);
  }

  @override
  void didUpdateWidget(covariant SelectPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    final next = widget.refreshing || widget.keys.isEmpty
        ? ''
        : widget.keys.contains(selectedKey) ? selectedKey : widget.keys.first;
    if (next != selectedKey) {
      selectedKey = next;
      // Lists can arrive asynchronously or be mutated in place by the dialog.
      // Keep the parent selection in sync after its current build completes.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && selectedKey == next) widget.clickCallback(next);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return Material(
      color: Theme.of(context).highlightColor,
      child: SizedBox(
        width: 360,
        height: 40,
        child: PopupMenuButton<String>(
          enabled: !widget.refreshing && widget.keys.isNotEmpty,
          initialValue: widget.keys.contains(selectedKey) ? selectedKey : null,
          color: Theme.of(context).highlightColor.withValues(alpha: 0.7),
          menuPadding: EdgeInsets.zero,
          constraints: BoxConstraints(
            minWidth: 360,
            maxWidth: 360,
            maxHeight: widget.popupHeight ?? height / 2.5,
          ),
          itemBuilder: (context) => widget.keys.map((value) => PopupMenuItem<String>(
            value: value,
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(value),
          )).toList(),
          onOpened: () => setState(() => menuOpen = true),
          onCanceled: () {
            if (mounted) setState(() => menuOpen = false);
          },
          onSelected: (String value) {
            if (!mounted) return;
            if (widget.refreshing || !widget.keys.contains(value)) {
              setState(() => menuOpen = false);
              return;
            }
            widget.clickCallback(value);
            setState(() {
              selectedKey = value;
              menuOpen = false;
            });
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 16, right: 11),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text(selectedKey, overflow: TextOverflow.ellipsis)),
                Icon(
                  menuOpen ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  color: menuOpen ? Theme.of(context).colorScheme.surface : Colors.grey,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
