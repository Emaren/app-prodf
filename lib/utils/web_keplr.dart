@JS('window')
library keplr;

import 'package:js/js.dart';

@JS()
external Keplr? get keplr;

@JS()
class Keplr {
  external void enable(String chainId);
  external OfflineSigner getOfflineSignerAuto(String chainId);
}

@JS()
class OfflineSigner {
  external List<Account> getAccounts();
}

@JS()
class Account {
  external String get address;
}

// ✅ JS interop for our chain suggestion JS script
@JS('suggestWolo')
external Future<void> suggestWolo();
