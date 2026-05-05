import 'package:edupro/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

void loader( ) {
  showDialog(
    context: navigatorKey.currentState!.overlay!.context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: AppLoader(width: 100, height: 100),
            ),
          ],
        ),
      );
    },
  );
}


void loader2( BuildContext context) {
  showDialog(
    context:  context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return WillPopScope(
        onWillPop: () async => false,
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              width: 100,
              height: 100,
              child: AppLoader(width: 100, height: 100),
            ),
          ],
        ),
      );
    },
  );
}
void hideLoader() { navigatorKey.currentState!.pop(); }

void showAppLoader(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    barrierColor: Colors.black.withOpacity(0.3),
    builder: (BuildContext context) {
      return PopScope(
        canPop: false,
        child: Center(
          child: Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Padding(
              padding: EdgeInsets.all(20),
              child: AppLoader(width: 80, height: 80),
            ),
          ),
        ),
      );
    },
  );
}

class AppLoader extends StatefulWidget {
  final double width;
  final double height;
  const AppLoader({
    super.key,
    required this.width,
    required this.height,
  });

  @override
  AppLoaderState createState() => AppLoaderState();
}

class AppLoaderState extends State<AppLoader> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background logo with shimmer effect
        Container(
          width: widget.width * 0.8,
          height: widget.height * 0.8,
          decoration: BoxDecoration(
            color: Theme.of(context).primaryColor,
            shape: BoxShape.circle,
            image: const DecorationImage(
              image: AssetImage("assets/images/logo.png"),
              fit: BoxFit.cover,
            ),
          ),
        )
            .animate(
          onPlay: (controller) => controller.repeat(),
        )
            .shimmer(
          duration: 3000.ms,
          delay: 200.ms,
          color: Colors.white.withOpacity(0.3),
        )
            .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.05, 1.05),
          duration: 2000.ms,
          curve: Curves.easeInOut,
        ),

        // Outer progress indicator
        SizedBox(
          width: widget.width,
          height: widget.height,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
            backgroundColor: Colors.grey[200],
          ),
        )
            .animate(
          onPlay: (controller) => controller.repeat(),
        )
            .rotate(
          duration: 1500.ms,
          curve: Curves.linear,
        ),
      ],
    );
  }
}

// Helper function to dismiss loader
void dismissLoader(BuildContext context) {
  if (Navigator.of(context, rootNavigator: true).canPop()) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}