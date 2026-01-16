import 'package:flutter/material.dart';
import '../../services/eye_health_service.dart';

/// Mavi ışık filtresi widget'ı
class BlueLightFilterWidget extends StatelessWidget {
  final Widget child;

  const BlueLightFilterWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final eyeHealthService = EyeHealthService.instance;

    if (!eyeHealthService.isBlueLightFilterEnabled) {
      return child;
    }

    return Stack(
      children: [
        child,
        Positioned.fill(
          child: IgnorePointer(
            child: Container(
              color: eyeHealthService.blueLightFilterColor,
            ),
          ),
        ),
      ],
    );
  }
}

/// Mavi ışık filtresi ile sarılmış Scaffold
class BlueLightFilterScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;

  const BlueLightFilterScaffold({
    Key? key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlueLightFilterWidget(
      child: Scaffold(
        appBar: appBar,
        body: body,
        floatingActionButton: floatingActionButton,
        bottomNavigationBar: bottomNavigationBar,
        backgroundColor: backgroundColor,
      ),
    );
  }
}
