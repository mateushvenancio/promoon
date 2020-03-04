import 'package:onesignal_flutter/onesignal_flutter.dart';

class Bloc{

  void initOneSignal(){
    OneSignal.shared.init("46c10a93-188e-4e13-8cee-e0dbba9480ae");
    OneSignal.shared.setInFocusDisplayType(OSNotificationDisplayType.none);
  }
}