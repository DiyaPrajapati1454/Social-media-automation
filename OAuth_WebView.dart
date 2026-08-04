import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class OAuthWebView extends StatefulWidget{
   final String authUrl;
   final String redirectUri;
   OAuthWebView({required this.authUrl,required this.redirectUri});
   @override
  _OAuthWebViewState createState()=>_OAuthWebViewState();
}
class _OAuthWebViewState extends State<OAuthWebView>{
  late WebViewController _controller;
  @override
  void initState(){
    super.initState();
    _controller=WebViewController()
    ..setJavaScriptMode(JavaScriptMode.unrestricted)
    ..loadRequest(Uri.parse(widget.authUrl))
    ..setNavigationDelegate(NavigationDelegate(
      onPageStarted: (String url){
        if(url.startsWith(widget.redirectUri)){
          Uri uri=Uri.parse(url);
          String? accessToken=uri.queryParameters["access_token"];
          if(accessToken!=null){
            print("Access Token: ${accessToken}");
          }
          Navigator.pop(context,accessToken);
        }
      },
    ));
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Login"),),
      body: WebViewWidget(controller: _controller),
    );
  }
}