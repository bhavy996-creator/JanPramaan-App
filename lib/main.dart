import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WebViewScreen(),
    );
  }
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool isLoading = true;
  bool isConnected = true;
  late StreamSubscription connectivitySubscription;

  final String url = "https://janpramaan.vercel.app/";
  InAppWebViewController? webViewController;

  void requestPermissions() async {
    await Permission.location.request();
    await Permission.camera.request();
    await Permission.microphone.request();
  }

  @override
  void initState() {
    super.initState();

    requestPermissions();

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
    if (webViewController != null &&
        await webViewController!.canGoBack()) {
      webViewController!.goBack();
      return false;
    }
    return true;
  }

  void _refreshPage() {
    webViewController?.reload();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onBackPressed,
      child: Scaffold(
        backgroundColor: Colors.white,

        // 🔥 APP BAR (NOW LOOKS LIKE REAL APP)
        appBar: AppBar(
          elevation: 2,
          backgroundColor: Colors.blue,
          centerTitle: true,
          title: const Text(
            "JanPramaan",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),

        body: SafeArea(
          child: isConnected
              ? Stack(
                  children: [
                    InAppWebView(
                      initialUrlRequest:
                          URLRequest(url: WebUri(url)),
                      initialSettings: InAppWebViewSettings(
                        javaScriptEnabled: true,
                        geolocationEnabled: true,
                        mediaPlaybackRequiresUserGesture: false,
                        allowsInlineMediaPlayback: true,
                      ),

                      onWebViewCreated: (controller) {
                        webViewController = controller;
                      },

                      onLoadStart: (controller, url) {
                        setState(() => isLoading = true);
                      },

                      onLoadStop: (controller, url) {
                        setState(() => isLoading = false);
                      },

                      androidOnPermissionRequest:
                          (controller, origin, resources) async {
                        return PermissionRequestResponse(
                          resources: resources,
                          action:
                              PermissionRequestResponseAction.GRANT,
                        );
                      },

                      androidOnGeolocationPermissionsShowPrompt:
                          (controller, origin) async {
                        return GeolocationPermissionShowPromptResponse(
                          origin: origin,
                          allow: true,
                          retain: true,
                        );
                      },
                    ),

                    // 🔥 PREMIUM LOADING SCREEN
                    if (isLoading)
                      Container(
                        color: Colors.white,
                        child: Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                "assets/logo.png",
                                height: 80,
                              ),
                              const SizedBox(height: 20),
                              const CircularProgressIndicator(),
                              const SizedBox(height: 10),
                              const Text(
                                "Loading...",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.black54,
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

        // 🔥 BETTER FLOATING BUTTON
        floatingActionButton: isConnected
            ? FloatingActionButton.extended(
                onPressed: _refreshPage,
                icon: const Icon(Icons.refresh),
                label: const Text("Refresh"),
              )
            : null,
      ),
    );
  }
}