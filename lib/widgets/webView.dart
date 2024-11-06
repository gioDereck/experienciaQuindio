import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:travel_hour/widgets/contact_buttons.dart';

class WebView extends StatefulWidget {
  final String url;
  final String label;
  const WebView({Key? key, required this.url, this.label = ''})
      : super(key: key);
  @override
  State<WebView> createState() => _WebViewState();
}

class _WebViewState extends State<WebView> {
  double _progress = 0;
  late InAppWebViewController inAppWebViewController;

  @override
  Widget build(BuildContext context) {
    TextStyle _textStyleMedium = Theme.of(context).textTheme.bodyMedium!;

    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: () async {
        if (!kIsWeb && await inAppWebViewController.canGoBack()) {
          inAppWebViewController.goBack();
          return false; // No cerrar la página aún
        }
        return true; // Cerrar la página si no hay historial
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(
              widget.label != ''
                  ? widget.label
                  : tr('explore ai games and more'),
              style: _textStyleMedium),
        ),
        floatingActionButton: ContactButtons(
          withoutAssistant: false,
          uniqueId: 'viewPage',
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                onWebViewCreated: (InAppWebViewController controller) {
                  inAppWebViewController = controller;
                },
                onProgressChanged:
                    (InAppWebViewController controller, int progress) {
                  setState(() {
                    _progress = progress / 100;
                  });
                },
              ),
              _progress < 1
                  ? Container(
                      child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor:
                              Theme.of(context).primaryColor.withOpacity(0.6),
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).primaryColor)),
                    )
                  : SizedBox()
            ],
          ),
        ),
      ),
    );
  }
}
