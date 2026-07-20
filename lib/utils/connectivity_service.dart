import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';


class ConnectivityService {
  ConnectivityService._internal();
  static final ConnectivityService instance = ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _statusController = StreamController<bool>.broadcast();

  Stream<bool> get onStatusChange => _statusController.stream;

  bool _hasInternet = true;
  bool get hasInternet => _hasInternet;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;
  Timer? _periodicTimer;
  bool _initialized = false;
  bool _isPaused = false;

  void initialize() {
    if (_initialized) return;
    _initialized = true;

    _checkAndUpdate();

    _connectivitySub = _connectivity.onConnectivityChanged.listen((_) {
      if (_isPaused) return;
      _checkAndUpdate();
    });

    _startPeriodicTimer();
  }

  void _startPeriodicTimer() {
    _periodicTimer?.cancel();
    _periodicTimer = Timer.periodic(const Duration(seconds: 6), (_) {
      if (_isPaused) return;
      _checkAndUpdate();
    });
  }

  void pause() {
    _isPaused = true;
  }

  void resume() {
    if (!_isPaused) return;
    _isPaused = false;
    _checkAndUpdate();
  }

  Future<bool> _hasRealInternet() async {
    for (var attempt = 0; attempt < 2; attempt++) {
      try {
        final result = await InternetAddress.lookup('google.com')
            .timeout(const Duration(seconds: 5));
        if (result.isNotEmpty && result.first.rawAddress.isNotEmpty) {
          return true;
        }
      } on SocketException {
        // fall through to retry
      } catch (_) {
        // fall through to retry
      }

      if (attempt == 0) {
        await Future.delayed(const Duration(milliseconds: 800));
      }
    }
    return false;
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