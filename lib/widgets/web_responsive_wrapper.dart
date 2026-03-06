import 'package:flutter/material.dart';

class WebResponsiveWrapper extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  
  const WebResponsiveWrapper({
    Key? key,
    required this.child,
    this.maxWidth = 480,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}

// Wrapper for Scaffold to add responsive constraints
class ResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget? body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final bool centerBody;
  
  const ResponsiveScaffold({
    Key? key,
    this.appBar,
    this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.centerBody = true,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final scaffold = Scaffold(
      appBar: appBar,
      body: body,
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
    
    // On web, center the content with max width
    if (centerBody) {
      return Container(
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 480),
            child: scaffold,
          ),
        ),
      );
    }
    
    return scaffold;
  }
}
