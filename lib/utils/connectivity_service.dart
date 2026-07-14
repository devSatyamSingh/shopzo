import 'dart:async';
import 'dart:io';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Shopzo — real internet reachability service.
///
/// `connectivity_plus` alone only tells you whether the device is
/// attached to a network (wifi/mobile) — NOT whether that network
/// actually has internet (e.g. connected to wifi with no internet,
/// or a router with no upstream). So this service combines:
///   1) connectivity_plus network-change events (instant reaction)
///   2) a real DNS lookup to confirm actual internet reachability
///   3) a periodic background check (catches "slow/dead wifi" cases
///      where the OS still reports "connected")
class ConnectivityService {
  ConnectivityService._internal();
  static final ConnectivityService instance = ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _statusController = StreamController<bool>.broadcast();

  /// Emits `true` when real internet is available, `false` when not.
  Stream<bool> get onStatusChange => _statusController.stream;

  bool _hasInternet = true;
  bool get hasInternet => _hasInternet;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _periodicTimer;
  bool _initialized = false;

  /// Call once, e.g. from ConnectivityWrapper's initState.
  void initialize() {
    if (_initialized) return;
    _initialized = true;

    _checkAndUpdate();

    _connectivitySub = _connectivity.onConnectivityChanged.listen((_) {
      _checkAndUpdate();
    });

    // Safety-net poll — catches cases where OS reports "connected"
    // but the network is actually dead or too slow.
    _periodicTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      _checkAndUpdate();
    });
  }

  Future<bool> _hasRealInternet() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 4));
      return result.isNotEmpty && result.first.rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    } catch (_) {
      return false;
    }
  }

  Future<void> _checkAndUpdate() async {
    final connectivityResult = await _connectivity.checkConnectivity();

    bool result;
    if (connectivityResult.isEmpty ||
        connectivityResult.every((r) => r == ConnectivityResult.none)) {
      result = false;
    } else {
      result = await _hasRealInternet();
    }

    if (result != _hasInternet) {
      _hasInternet = result;
      _statusController.add(result);
    }
  }

  /// Manual check — used by the "Try Again" button.
  /// Returns the fresh status AND emits it on the stream.
  Future<bool> checkNow() async {
    await _checkAndUpdate();
    return _hasInternet;
  }

  void dispose() {
    _connectivitySub?.cancel();
    _periodicTimer?.cancel();
    _statusController.close();
    _initialized = false;
  }
}