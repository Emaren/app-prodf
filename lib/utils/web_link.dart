export 'web_link_stub.dart' // fallback for non-web
  if (dart.library.html) 'web_link_html.dart'; // override on web

