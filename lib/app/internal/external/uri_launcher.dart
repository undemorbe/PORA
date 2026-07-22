import 'package:url_launcher/url_launcher.dart';

abstract class IUriLauncher {
  Future<void> launchUri({required String uri});
}

class UriLauncherImpl implements IUriLauncher {
  @override
  Future<void> launchUri({required String uri}) async {
    final url = Uri.parse(uri);
    if (!await launchUrl(url)) {
      throw Exception('Could not launch $url');
    }
  }
}

/*
Scheme	Example	Action
https:<URL>	https://flutter.dev	Open <URL> in the default browser
mailto:<email address>?subject=<subject>&body=<body>	mailto:smith@example.org?subject=News&body=New%20plugin	Create email to <email address> in the default email app
tel:<phone number>	tel:+1-555-010-999	Make a phone call to <phone number> using the default phone app
sms:<phone number>	sms:5550101234	Send an SMS message to <phone number> using the default messaging app
file:<path>	file:/home	Open file or folder using default app association, supported on desktop platforms
*/
