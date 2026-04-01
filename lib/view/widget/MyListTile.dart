import 'package:flutter/material.dart';

class MyDrawerListTile extends StatefulWidget {
  final Widget? icon;
  final String title;
  final Function()? onTap;

  const MyDrawerListTile({
    this.onTap,
    this.icon,
    this.title = "test",
    super.key,
  });

  @override
  State<MyDrawerListTile> createState() => _MyDrawerListTileState();
}

class _MyDrawerListTileState extends State<MyDrawerListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: ListTile(
          focusColor: Theme.of(
            context,
          ).colorScheme.secondary.withValues(alpha: 0.5),
          splashColor: Theme.of(context).primaryColor.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          tileColor: _isHovered
              ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
              : Colors.transparent,
          onTap: widget.onTap,
          title: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.only(bottom: _isHovered ? 4.0 : 0.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(widget.title)),
                widget.icon!,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
