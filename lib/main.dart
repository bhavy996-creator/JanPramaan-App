import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebViewScreen(),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController controller;
  bool isLoading = true;
  bool isConnected = true;
  late StreamSubscription connectivitySubscription;

  final String url = "https://janpramaan.vercel.app/";

  void requestPermissions() async {
  await Permission.location.request();
  await Permission.camera.request();
  await Permission.microphone.request();
}

  @override
  void initState() {
    super.initState();

    requestPermissions();

  controller = WebViewController()
  ..setJavaScriptMode(JavaScriptMode.unrestricted)
  ..setBackgroundColor(const Color(0x00000000))
  ..loadRequest(Uri.parse(url))
  ..setNavigationDelegate(
    NavigationDelegate(
      onPageStarted: (url) {
        setState(() => isLoading = true);
      },
      onPageFinished: (url) {
        setState(() => isLoading = false);
      },
      onWebResourceError: (error) {
        setState(() => isLoading = false);
      },
    ),
  );

    connectivitySubscription =
        Connectivity().onConnectivityChanged.listen((result) {
      setState(() {
        isConnected = result != ConnectivityResult.none;
      });
    });
  }
  

  @override
  void dispose() {
    connectivitySubscription.cancel();
    super.dispose();
  }

  Future<bool> _onBackPressed() async {
    if (await controller.canGoBack()) {
      controller.goBack();
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        body: SafeArea(
          child: isConnected
              ? Stack(
                  children: [
                    WebViewWidget(controller: controller),

                    // Loading Screen
                    if (isLoading)
                      Container(
                        color: Colors.white,
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(height: 10),
                              Text("Loading JanPramaan..."),
                            ],
                          ),
                        ),
                      ),
                  ],
                )
              : const Center(
                  child: Text(
                    "No Internet Connection",
                    style: TextStyle(fontSize: 18),
                  ),
                ),
        ),

        // ✅ Optional Refresh Button (SAFE)
        floatingActionButton: isConnected
            ? FloatingActionButton(
                onPressed: () => controller.reload(),
                child: const Icon(Icons.refresh),
              )
            : null,
      ),
    );
  }
}