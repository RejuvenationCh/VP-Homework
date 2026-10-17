import 'package:flutter/material.dart';

// Sized frame + MediaQuery + FittedBox.scaleDown, adapted from W4/lab04.
class DeviceStage extends StatelessWidget {
  const DeviceStage({
    super.key,
    required this.size,
    required this.landscape,
    required this.showKeyboard,
    required this.showInsets,
    required this.appBuilder,
  });

  final Size size;
  final bool landscape;
  final bool showKeyboard;
  final bool showInsets;
  final Widget Function(MediaQueryData media) appBuilder;

  @override
  Widget build(BuildContext context) {
    final keyboard = showKeyboard ? (landscape ? 180.0 : 260.0) : 0.0;
    final padding = !showInsets
        ? EdgeInsets.zero
        : landscape
        ? const EdgeInsets.only(left: 32, bottom: 20)
        : const EdgeInsets.only(top: 32, bottom: 20);
    final safe = keyboard > 0 ? padding.copyWith(bottom: 0) : padding;
    final media = MediaQuery.of(context).copyWith(
      size: size,
      devicePixelRatio: 1,
      padding: safe,
      viewPadding: padding,
      viewInsets: EdgeInsets.only(bottom: keyboard),
    );
    return ColoredBox(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF1B1D1F),
                borderRadius: BorderRadius.circular(30),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: SizedBox.fromSize(
                  size: size,
                  child: Stack(
                    children: [
                      Positioned.fill(child: appBuilder(media)),
                      if (padding.top > 0)
                        Positioned(
                          top: 0,
                          left: 0,
                          right: 0,
                          height: padding.top,
                          child: const IgnorePointer(
                            child: ColoredBox(
                              color: Color(0xFF1B1D1F),
                              child: Center(
                                child: Text(
                                  '9:41',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (padding.left > 0)
                        Positioned(
                          top: 0,
                          bottom: 0,
                          left: 0,
                          width: padding.left,
                          child: const IgnorePointer(
                            child: ColoredBox(color: Color(0xFF1B1D1F)),
                          ),
                        ),
                      if (safe.bottom > 0)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: safe.bottom,
                          child: const IgnorePointer(
                            child: ColoredBox(color: Color(0xFF1B1D1F)),
                          ),
                        ),
                      if (keyboard > 0)
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          height: keyboard,
                          child: const IgnorePointer(
                            child: ColoredBox(
                              color: Color(0xFF2B2F33),
                              child: Center(
                                child: Text(
                                  'Simulated keyboard',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
