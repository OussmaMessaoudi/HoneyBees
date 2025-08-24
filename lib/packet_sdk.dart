import 'dart:async';
import 'dart:developer' as developer;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:packet_android_sdk/packet_sdk.dart';
import 'package:share2cash/fireStoreServices.dart';
import 'package:traffic_stats/traffic_stats.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

@pragma('vm:entry-point')
void startCallback() {
  developer.log('🔔 startCallback: registering TaskHandler');
  FlutterForegroundTask.setTaskHandler(PacketTaskHandler());
}

/// Task Handler — monitors speed and updates GB in notification
class PacketTaskHandler extends TaskHandler {
  static const _pawnsChannel = MethodChannel('pawns_control');

  Future<void> startPawns() => _pawnsChannel.invokeMethod('startPawns');
  Future<void> stopPawns() => _pawnsChannel.invokeMethod('stopPawns');

  final NetworkSpeedService _speed = NetworkSpeedService();

  double _bytes = 0;
  static const double _rate = 0.25;
  static const int _bytesPerGB = 1024 * 1024 * 1024;
  StreamSubscription<NetworkSpeedData>? _sub;
  

  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {
    await startPawns();
    developer.log('📌 TaskHandler.onStart @ $timestamp');
    _speed.init();
    _sub = _speed.speedStream.listen((d) {
      final added = (d.downloadSpeed + d.uploadSpeed) * 1000 / 8;
      _bytes += added;

      final sessionGB = (_bytes / _bytesPerGB).toStringAsFixed(2);
      final earnings = ((_bytes / _bytesPerGB) * _rate).toStringAsFixed(4);

      FlutterForegroundTask.sendDataToMain({
        'bytes': _bytes,
        'earnings': double.parse(earnings),
      });

      
      
    });
  }

  @override
  Future<void> onDestroy(DateTime timestamp, bool isTimeout) async {
    await stopPawns();
    developer.log('🛑 TaskHandler.onDestroy @ $timestamp (timeout=$isTimeout)');
    await _sub?.cancel();

    _speed.dispose();
  }

  @override void onRepeatEvent(DateTime timestamp) {}
  @override void onReceiveData(Object data) {}
  @override void onNotificationButtonPressed(String id) {}
  @override void onNotificationPressed() {}
  @override void onNotificationDismissed() {}
}

/// Foreground + SDK Controller
class PacketService {
  static final PacketService _inst = PacketService._();
  factory PacketService() => _inst;
  PacketService._();

  final PacketSdk _sdk = PacketSdk();

  Future<void> init({required String appKey}) async {
    _sdk.setCallBack((msg) {
      developer.log('📡 PacketSdk: $msg');
    });
    await _sdk.setAppKey(appKey);
  }

  Future<void> start() async {
    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'packet_share',
        channelName: 'Packet Share',
        channelDescription: 'Tracks bandwidth & earnings',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        onlyAlertOnce: true,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: true,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        allowWakeLock: true,
        allowWifiLock: true,
        autoRunOnBoot: false,
        eventAction: ForegroundTaskEventAction.repeat(500),
      ),
    );

    final isRunning = await FlutterForegroundTask.isRunningService;
    if (!isRunning) {
      await FlutterForegroundTask.startService(
        notificationTitle: "Packet Sharing",
        notificationText: "earning is on",
        callback: startCallback,
      );
    }

    await _sdk.start();
  }

  Future<void> stop() async {
    await _sdk.stop();
    await FlutterForegroundTask.stopService();
  }
}

/// Provider for state management with persistence
class PacketSdkProvider extends ChangeNotifier {
  final PacketService _service = PacketService();

  double _totalBytes = 0;
  double _earnings = 0;
  bool isRunning = false;
  bool _callbackAdded = false;

  double get totalGB => _totalBytes / (1024 * 1024 * 1024);
  double get earnings => _earnings;

  static const String _keyBytes = 'totalBytes';
  static const String _keyEarnings = 'totalEarnings';
   final FirestoreService _fs = FirestoreService();

  void _onTaskData(Object data) {
    if (data is Map<String, dynamic>) {
      _totalBytes += (data['bytes'] as num).toDouble();
      _earnings += (data['earnings'] as num).toDouble();
      notifyListeners();

      // sync to Firestore immediately or schedule
      _syncEarningsToFirestore();
    }
  }

  Future<void> _syncEarningsToFirestore() async {
    try {
      await _fs.updateDailyEarnings(_earnings);
    } catch (e) {
      developer.log('Firestore sync error: $e');
    }
  }

  Future<void> initProvider({required String appKey}) async {
    if (!_callbackAdded) {
      FlutterForegroundTask.addTaskDataCallback(_onTaskData);
      _callbackAdded = true;
    }
    await _service.init(appKey: appKey);
    await _loadSavedTotals();
  }

 

  Future<void> startService() async {
    await _service.start();
    isRunning = true;
    notifyListeners();
  }

  Future<void> stopService() async {
    await _service.stop();
    isRunning = false;
    await _saveTotals();
    notifyListeners();
  }

  Future<void> _loadSavedTotals() async {
    final prefs = await SharedPreferences.getInstance();
    _totalBytes = prefs.getDouble(_keyBytes) ?? 0.0;
    _earnings = prefs.getDouble(_keyEarnings) ?? 0.0;
    notifyListeners();
  }

  Future<void> _saveTotals() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyBytes, _totalBytes);
    await prefs.setDouble(_keyEarnings, _earnings);
  }

  @override
  void dispose() {
    if (_callbackAdded) {
      FlutterForegroundTask.removeTaskDataCallback(_onTaskData);
      _callbackAdded = false;
    }
    super.dispose();
  }
}

/// UI Toggle Switch
class PacketSdkButton extends StatefulWidget {
  final String appKey;
  const PacketSdkButton({Key? key, required this.appKey}) : super(key: key);

  @override
  _PacketSdkButtonState createState() => _PacketSdkButtonState();
}

class _PacketSdkButtonState extends State<PacketSdkButton> {
  bool _isToggling = false;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<PacketSdkProvider>();
    return SwitchListTile(
      activeColor: Colors.yellow,
      title: const Text(
        'Start Earning',
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
      value: provider.isRunning,
      onChanged: _isToggling ? null : (val) => _toggleService(context, val),
    );
  }

  Future<void> _toggleService(BuildContext ctx, bool enable) async {
    setState(() => _isToggling = true);
    final provider = Provider.of<PacketSdkProvider>(ctx, listen: false);
    try {
      if (enable) {
        await provider.initProvider(appKey: widget.appKey);
        await provider.startService();
      } else {
        await provider.stopService();
        await FirestoreService().updateDailyEarnings(Provider.of<PacketSdkProvider>(context,listen: false)._earnings);
      }
    } catch (e) {
      ScaffoldMessenger.of(ctx)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _isToggling = false);
    }
  }
}
