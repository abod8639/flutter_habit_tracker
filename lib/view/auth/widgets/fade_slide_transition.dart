import 'package:flutter/material.dart';

class FadeSlideTransition extends StatelessWidget {
  final Widget child;
  final Animation<double> animation;
  final double slideOffset;

  const FadeSlideTransition({
    super.key,
    required this.child,
    required this.animation,
    this.slideOffset = 50.0,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        return Opacity(
          opacity: animation.value,
          child: Transform.translate(
            offset: Offset(0, slideOffset * (1 - animation.value)),
            child: child,
          ),
        );
      },
      child: child,
    );
  }
}

class AnimatedEntry extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double slideOffset;

  const AnimatedEntry({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 600),
    this.slideOffset = 50.0,
  });

  @override
  State<AnimatedEntry> createState() => _AnimatedEntryState();
}

class _AnimatedEntryState extends State<AnimatedEntry> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeSlideTransition(
      animation: _animation,
      slideOffset: widget.slideOffset,
      child: widget.child,
    );
  }
}
