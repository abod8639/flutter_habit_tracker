import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class TextTaile extends StatefulWidget {
  final String habitName;
  final bool habitCompleted;
  final Function(BuildContext)? onDelete;
  final Function(BuildContext)? onEdit;
  final Function(bool?)? onChanged;
  final Function()? onTap;

  const TextTaile({
    required this.habitCompleted,
    required this.onChanged,
    required this.onDelete,
    required this.onEdit,
    required this.onTap,
    required this.habitName,
    super.key,
  });

  @override
  State<TextTaile> createState() => _TextTaileState();
}

class _TextTaileState extends State<TextTaile>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    if (widget.habitCompleted) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(TextTaile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.habitCompleted != oldWidget.habitCompleted) {
      if (widget.habitCompleted) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeColors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Slidable(
        direction: Axis.horizontal,
        startActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              spacing: 5,
              autoClose: true,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: themeColors.error,
              onPressed: widget.onDelete,
              icon: Icons.delete,
            ),
          ],
        ),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              autoClose: true,
              borderRadius: BorderRadius.circular(10),
              backgroundColor: Colors.orange[700]!,
              onPressed: widget.onEdit,
              icon: Icons.edit,
            ),
          ],
        ),
        child: AnimatedBuilder(
          animation: _animationController,
          builder: (context, child) {
            return Transform.scale(scale: _scaleAnimation.value, child: child);
          },
          child: ListTile(
            splashColor: Theme.of(context).primaryColor.withOpacity(0.3),
            focusColor: themeColors.secondary.withOpacity(0.5),
            onTap: () {
              if (widget.onTap != null) {
                // Animate the tile when tapped
                if (!widget.habitCompleted) {
                  _animationController.forward();
                  Future.delayed(const Duration(milliseconds: 150), () {
                    _animationController.reverse();
                  });
                }
                widget.onTap!();
              }
            },
            title: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color:
                    widget.habitCompleted
                        ? Theme.of(context).primaryColor.withOpacity(0.5)
                        : themeColors.brightness == Brightness.light
                        ? Colors.grey[400]
                        : Colors.grey[700],
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (
                      Widget child,
                      Animation<double> animation,
                    ) {
                      return ScaleTransition(scale: animation, child: child);
                    },
                    child: Checkbox(
                      key: ValueKey<bool>(widget.habitCompleted),
                      activeColor: Theme.of(context).primaryColor,
                      checkColor: Colors.white,
                      value: widget.habitCompleted,
                      onChanged: widget.onChanged,
                    ),
                  ),
                  Expanded(
                    child: AnimatedDefaultTextStyle(
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: themeColors.onSurface,
                        decoration:
                            widget.habitCompleted
                                ? TextDecoration.lineThrough
                                : TextDecoration.none,
                      ),
                      duration: const Duration(milliseconds: 300),
                      child: Text(widget.habitName),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
