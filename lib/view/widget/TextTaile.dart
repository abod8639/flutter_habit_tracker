import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class MyTextTaile extends StatefulWidget {
  final String habitName;
  final bool habitCompleted;
  final Function(BuildContext)? onDelete;
  final Function(BuildContext)? onEdit;
  final Function(bool?)? onChanged;
  final Function()? onTap;
  final Function()? onLongPress;
  final bool isSelected;
  final bool isSelectionMode;

  const MyTextTaile({
    required this.habitCompleted,
    required this.onChanged,
    required this.onDelete,
    required this.onEdit,
    required this.onTap,
    this.onLongPress,
    this.isSelected = false,
    this.isSelectionMode = false,
    required this.habitName,
    super.key,
  });

  @override
  State<MyTextTaile> createState() => _MyTextTaileState();
}

class _MyTextTaileState extends State<MyTextTaile>
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
  void didUpdateWidget(MyTextTaile oldWidget) {
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
            splashColor: Theme.of(context).primaryColor.withValues(alpha:0.3),
            focusColor: themeColors.secondary.withValues(alpha:0.5),
            onTap: () {
              if (widget.isSelectionMode) {
                if (widget.onLongPress != null) widget.onLongPress!();
              } else if (widget.onTap != null) {
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
            onLongPress: widget.onLongPress,
            title: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              decoration: BoxDecoration(
                color: widget.isSelected
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.2)
                    : widget.habitCompleted
                        ? Theme.of(context).primaryColor.withValues(alpha: 0.5)
                        : themeColors.brightness == Brightness.light
                            ? Colors.grey[400]
                            : Colors.grey[700],
                borderRadius: BorderRadius.circular(10),
                border: widget.isSelected
                    ? Border.all(color: Theme.of(context).primaryColor, width: 2)
                    : null,
              ),
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder:
                        (
                          Widget child,
                          Animation<double> animation,
                        ) {
                          return ScaleTransition(
                            scale: animation,
                            child: child,
                          );
                        },
                    child: widget.isSelectionMode
                        ? Icon(
                            widget.isSelected
                                ? Icons.check_circle_rounded
                                : Icons.radio_button_unchecked_rounded,
                            color: widget.isSelected
                                ? Theme.of(context).primaryColor
                                : themeColors.onSurface.withValues(alpha: 0.5),
                          )
                        : Checkbox(
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
                        decoration: widget.habitCompleted
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
