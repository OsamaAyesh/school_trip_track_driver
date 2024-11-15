

import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkCheck {

    static Future<bool> isConnect() async {
        var connectivityResult = await (Connectivity().checkConnectivity());
        if (connectivityResult == ConnectivityResult.mobile ||
            connectivityResult == ConnectivityResult.wifi) {
            return true;
        }
        else {
            return false;
        }
    }
}
