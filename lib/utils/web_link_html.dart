import 'dart:html' as html;

Future<void> openInBrowser(String url) async {
  html.window.open(url, '_blank');
}

