import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';

extension CtxColors on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;
}

class IntroScreen extends StatefulWidget {
  final VoidCallback onDone;
  const IntroScreen({super.key, required this.onDone});

  @override
  State<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends State<IntroScreen> {
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Welcome to honeBees",
          body: "turn your unused internet into cash",
          image: const Center(child: Icon(Icons.wifi, size: 100)),
        ),
        PageViewModel(
          title: "Real-time Stats",
          body: "Monitor your bandwidth usage and earnings live.",
          image: const Center(child: Icon(Icons.bar_chart, size: 100)),
        ),
        PageViewModel(
          title: "easy to use",
          body:
              "the app works in the background all you need to do is start and earn",
          image: const Center(child: Icon(Icons.lock, size: 100)),
        ),
      ],
      onDone: widget.onDone,
      onSkip: widget.onDone,
      showSkipButton: true,
      skip: Text(
        'Skip',
        style: TextStyle(color: context.cs.secondary),
      ),
      next: Icon(Icons.arrow_forward, color: context.cs.primary),
      done: Text(
        'Done',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: context.cs.primary,
        ),
      ),
      dotsDecorator: DotsDecorator(
        activeColor: context.cs.primary,
        color: context.cs.onSurface.withOpacity(0.3),
      ),
      // Optionally, you can use globalBackgroundColor to match theme:
      globalBackgroundColor: context.cs.surface,
    );
  }
}
