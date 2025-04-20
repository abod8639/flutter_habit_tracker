import 'package:flutter/material.dart';

class myfloatingActionButton extends StatefulWidget {
  final Function()? onPressed;
  const myfloatingActionButton({this.onPressed, super.key});

  @override
  State<myfloatingActionButton> createState() => _myfloatingActionButtonState();
}

class _myfloatingActionButtonState extends State<myfloatingActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  // late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // _rotateAnimation = Tween<double>(begin: 0, end: 0.125).animate(
    //   CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    // );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => _animationController.forward(),
      onExit: (_) => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: FloatingActionButton(
          tooltip: 'Add Habit',
          autofocus: true,
          focusColor: Theme.of(context).colorScheme.secondary.withOpacity(0.6),
          isExtended: true,
          backgroundColor: Theme.of(context).primaryColor,
          onPressed: () {
            if (widget.onPressed != null) {
              // Add tap animation
              _animationController.forward().then((_) {
                _animationController.reverse();
                widget.onPressed!();
              });
            }
          },
          splashColor: Theme.of(context).colorScheme.primary,
          child: const Icon(size: 25, color: Colors.black87, Icons.add),
        ),
      ),
    );
  }
}
