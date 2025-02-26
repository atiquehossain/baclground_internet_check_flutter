import 'dart:async';
import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeService();
  runApp(MyApp());
}

void startBackgroundService() {
  final service = FlutterBackgroundService();
 // if (!service.isRunning()) {
    service.startService();
//  }
}

void stopBackgroundService() {
  final service = FlutterBackgroundService();
  service.invoke("stop");
}

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    iosConfiguration: IosConfiguration(
      autoStart: true,
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
    androidConfiguration: AndroidConfiguration(
      autoStart: true,
      onStart: onStart,
      isForegroundMode: true, // Foreground mode to prevent killing
      autoStartOnBoot: true,
    ),
  );
}

@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  WidgetsFlutterBinding.ensureInitialized();
  return true;
}

@pragma('vm:entry-point')
void onStart(ServiceInstance service) async {
  final connectivity = Connectivity();

  service.on("stop").listen((event) {
    service.stopSelf();
    print("Background process stopped");
  });

  Timer.periodic(const Duration(seconds: 5), (timer) async {
    var result = await connectivity.checkConnectivity();

    if (result == ConnectivityResult.mobile || result == ConnectivityResult.wifi) {
      print("✅ Internet is connected");
    } else {
      print("❌ No Internet Connection");
    }
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text("Background Internet Check")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: startBackgroundService,
                child: Text("Start Background Service"),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: stopBackgroundService,
                child: Text("Stop Background Service"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
