import 'package:url_launcher/url_launcher.dart';

void abrirNoGoogleMaps(double lat, double long) {
  String url = "https://www.google.com/maps/search/?api=1&query=$lat,$long";
  print(url);
  launch(url);
}
