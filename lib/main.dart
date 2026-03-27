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

  void requestLocationPermission() async {
    await Permission.location.request();
  }

  @override
  void initState() {
    super.initState();

    requestLocationPermission();

    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
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

  void _refreshPage() {
    controller.reload();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        appBar: AppBar(
          title: const Text("JanPramaan"),
          centerTitle: true,
          elevation: 2,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshPage,
            ),
          ],
        ),
        body: isConnected
            ? Stack(
                children: [
                  WebViewWidget(controller: controller),

                  if (isLoading)
                    Container(
                      color: Colors.white,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            CircularProgressIndicator(),
                            SizedBox(height: 12),
                            Text(
                              "Loading JanPramaan...",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
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
    );
  }
}