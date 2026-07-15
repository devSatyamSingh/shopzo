import 'dart:async';
import 'package:flutter/material.dart';
import '../res/no_internet_connection_screen.dart';
import '../utils/connectivity_service.dart';

/// Shopzo — Global connectivity overlay wrapper.
///
/// HOW IT WORKS (important):
/// This does NOT navigate to a "No Internet" route. It wraps the
/// ENTIRE app (via MaterialApp's `builder`) and simply draws
/// NoInternetScreen ON TOP of whatever screen is currently active,
/// using a Stack. The Navigator underneath (`widget.child`) is never
/// touched — its route stack, scroll positions, text field contents,
/// form state, everything stays exactly as it was.
///
/// Result: user is on Product Detail, internet drops -> overlay fades
/// in. Internet returns -> overlay disappears -> user is still on the
/// exact same Product Detail screen, nothing lost, nothing rebuilt.
///
/// USAGE — in main.dart:
///   MaterialApp(
///     ...
///     builder: (context, child) =>
///         ConnectivityWrapper(child: child ?? const SizedBox.shrink()),
///   )
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _hasInternet = true;
  StreamSubscription<bool>? _sub;

  @override
  void initState() {
    super.initState();
    ConnectivityService.instance.initialize();
    _hasInternet = ConnectivityService.instance.hasInternet;

    _sub = ConnectivityService.instance.onStatusChange.listen((status) {
      if (mounted) setState(() => _hasInternet = status);
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // ---- The actual app (Navigator) — always alive underneath ----
        widget.child,

        // ---- No Internet overlay (only thing this wrapper handles) ----
        if (!_hasInternet)
          Positioned.fill(
            child: Material(
              type: MaterialType.transparency,
              child: const NoInternetScreen(),
            ),
          ),
      ],
    );
  }
}