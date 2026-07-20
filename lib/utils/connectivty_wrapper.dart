import 'dart:async';
import 'package:flutter/material.dart';
import '../res/no_internet_connection_screen.dart';
import '../utils/connectivity_service.dart';


class ConnectivityWrapper extends StatefulWidget {
  final Widget child;
  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper>
    with WidgetsBindingObserver {
  bool _hasInternet = true;
  StreamSubscription<bool>? _sub;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    ConnectivityService.instance.initialize();
    _hasInternet = ConnectivityService.instance.hasInternet;

    _sub = ConnectivityService.instance.onStatusChange.listen((status) {
      if (mounted) setState(() => _hasInternet = status);
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        ConnectivityService.instance.resume();
        break;

      case AppLifecycleState.paused:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
        ConnectivityService.instance.pause();
        break;

      case AppLifecycleState.detached:
        break;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
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