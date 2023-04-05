import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'dart:isolate';
import 'dart:ui';
import 'dart:io';
import 'dart:async';
import 'package:path_provider/path_provider.dart';

class WakZooWebViewScreen extends StatefulWidget {
  const WakZooWebViewScreen({Key? key}) : super(key: key);

  @override
  State<WakZooWebViewScreen> createState() => _WakZooWebViewScreenState();
}

class _WakZooWebViewScreenState extends State<WakZooWebViewScreen> {
  final GlobalKey webViewKey = GlobalKey();
  Uri myUrl = Uri.parse("https://m.cafe.naver.com/ca-fe/");
  late final InAppWebViewController webViewController;
  late final PullToRefreshController pullToRefreshController;
  double progress = 0;
  late ContextMenu contextMenu;
  final ReceivePort _port = ReceivePort();

  @pragma('vm:entry-point')
  static void downloadCallback(
      String id, DownloadTaskStatus status, int downloadProgress) {
    final SendPort send =
        IsolateNameServer.lookupPortByName('downloader_send_port')!;
    send.send([id, status, downloadProgress]);
  }

  @override
  void initState() {
    super.initState();

    contextMenu = ContextMenu(
        options: ContextMenuOptions(hideDefaultSystemContextMenuItems: false),
        onCreateContextMenu: (hitTestResult) async {
          if (hitTestResult.type == InAppWebViewHitTestResultType.IMAGE_TYPE) {
            // Get the image URL
            String imageUrl = '${hitTestResult.extra}';
            imageUrl = imageUrl.substring(0, imageUrl.indexOf('?ty'));
            // Download the image
            final taskId = await FlutterDownloader.enqueue(
              url: imageUrl,
              savedDir: '/storage/emulated/0/Pictures/navercafe/',
              showNotification: true,
              openFileFromNotification: true,
            );
          }
        },
        onHideContextMenu: () {},
        onContextMenuActionItemClicked: (contextMenuItemClicked) async {
          var id = (Platform.isAndroid)
              ? contextMenuItemClicked.androidId
              : contextMenuItemClicked.iosId;
        });

    pullToRefreshController = (kIsWeb
        ? null
        : PullToRefreshController(
            options: PullToRefreshOptions(
              color: Colors.grey[800],
            ),
            onRefresh: () async {
              if (defaultTargetPlatform == TargetPlatform.android) {
                webViewController.reload();
              } else if (defaultTargetPlatform == TargetPlatform.iOS ||
                  defaultTargetPlatform == TargetPlatform.macOS) {
                webViewController.loadUrl(
                    urlRequest:
                        URLRequest(url: await webViewController.getUrl()));
              }
            },
          ))!;
    IsolateNameServer.registerPortWithName(
        _port.sendPort, 'downloader_send_port');
    _port.listen((dynamic data) {
      String id = data[0];
      DownloadTaskStatus status = data[1];
      int progress = data[2];
      setState(() {});
    });
    FlutterDownloader.registerCallback(downloadCallback);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () => _goBack(context),
          child: Column(
            children: <Widget>[
              progress < 1.0
                  ? LinearProgressIndicator(
                      value: progress,
                      color: Colors.white,
                    )
                  : Container(),
              Expanded(
                child: Stack(
                  children: [
                    InAppWebView(
                      key: webViewKey,
                      initialUrlRequest: URLRequest(url: myUrl),
                      initialOptions: InAppWebViewGroupOptions(
                        crossPlatform: InAppWebViewOptions(
                            javaScriptCanOpenWindowsAutomatically: true,
                            javaScriptEnabled: true,
                            useOnDownloadStart: true,
                            useOnLoadResource: true,
                            useShouldOverrideUrlLoading: true,
                            mediaPlaybackRequiresUserGesture: true,
                            allowFileAccessFromFileURLs: true,
                            allowUniversalAccessFromFileURLs: true,
                            verticalScrollBarEnabled: true,
                            userAgent:
                                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/81.0.4044.122 Safari/537.36'),
                        android: AndroidInAppWebViewOptions(
                          useHybridComposition: true,
                          allowContentAccess: true,
                          builtInZoomControls: true,
                          thirdPartyCookiesEnabled: true,
                          allowFileAccess: true,
                          supportMultipleWindows: true,
                          domStorageEnabled: true,
                          mixedContentMode: AndroidMixedContentMode
                              .MIXED_CONTENT_ALWAYS_ALLOW,
                        ),
                        ios: IOSInAppWebViewOptions(
                          allowsInlineMediaPlayback: true,
                          allowsBackForwardNavigationGestures: true,
                        ),
                      ),
                      pullToRefreshController: pullToRefreshController,
                      onLoadStart: (InAppWebViewController controller, uri) {
                        setState(() {
                          myUrl = uri!;
                        });
                      },
                      onLoadStop: (InAppWebViewController controller, uri) {
                        controller.injectJavascriptFileFromAsset(
                            assetFilePath: "assets/scripts/wakzoo_script.js");
                        controller.injectCSSFileFromAsset(
                            assetFilePath: "assets/styles/wakzoo_style.css");
                        setState(() {
                          myUrl = uri!;
                        });
                      },
                      onProgressChanged: (controller, progress) {
                        if (progress == 100) {
                          pullToRefreshController.endRefreshing();
                        }
                        setState(() {
                          this.progress = progress / 100;
                        });
                      },
                      androidOnPermissionRequest:
                          (controller, origin, resources) async {
                        return PermissionRequestResponse(
                            resources: resources,
                            action: PermissionRequestResponseAction.GRANT);
                      },
                      onWebViewCreated: (InAppWebViewController controller) {
                        webViewController = controller;
                      },
                      contextMenu: contextMenu,
                      onCreateWindow: (controller, createWindowRequest) async {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              content: SizedBox(
                                width: MediaQuery.of(context).size.width,
                                height: 400,
                                child: InAppWebView(
                                  // Setting the windowId property is important here!
                                  windowId: createWindowRequest.windowId,
                                  initialOptions: InAppWebViewGroupOptions(
                                    android: AndroidInAppWebViewOptions(
                                      builtInZoomControls: true,
                                      thirdPartyCookiesEnabled: true,
                                    ),
                                    crossPlatform: InAppWebViewOptions(
                                        cacheEnabled: true,
                                        javaScriptEnabled: true,
                                        userAgent:
                                            "Mozilla/5.0 (Linux; Android 9; LG-H870 Build/PKQ1.190522.001) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/83.0.4103.106 Mobile Safari/537.36"),
                                    ios: IOSInAppWebViewOptions(
                                      allowsInlineMediaPlayback: true,
                                      allowsBackForwardNavigationGestures: true,
                                    ),
                                  ),
                                  onCloseWindow: (controller) async {
                                    if (Navigator.canPop(context)) {
                                      Navigator.pop(context);
                                    }
                                  },
                                ),
                              ),
                            );
                          },
                        );
                        return true;
                      },
                      onDownloadStartRequest:
                          (InAppWebViewController controller,
                              DownloadStartRequest downloadStartRequest) async {
                        final directory =
                            await getApplicationDocumentsDirectory();
                        var savedDirPath = directory.path;

                        await FlutterDownloader.enqueue(
                          url: downloadStartRequest.url.toString(),
                          savedDir: savedDirPath,
                          saveInPublicStorage: true,
                          showNotification: true,
                          openFileFromNotification: true,
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');
    super.dispose();
  }

  Future<bool> _goBack(BuildContext context) async {
    if (await webViewController.canGoBack()) {
      webViewController.goBack();
      return Future.value(false);
    } else {
      return Future.value(true);
    }
  }
}
