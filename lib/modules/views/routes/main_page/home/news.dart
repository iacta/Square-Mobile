import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class NewsTwitter extends StatelessWidget {
  NewsTwitter({Key? key}) : super(key: key);

  final twitterWebView = WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse('https://squarecloud.app'));

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
            height: 240,
            width: 200,
            child: WebViewWidget(controller: twitterWebView)),
      ],
    );
  }
}
