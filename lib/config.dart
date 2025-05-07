import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

class Config {
  static String? _serverIP;
  static const int serverPort = 3001;

  static Future<String> getServerIP() async {
    if (_serverIP != null) return _serverIP!;

    try {
      // First try to read from the server_ip.txt file
      final directory = await getApplicationDocumentsDirectory();
      final file = File(path.join(directory.path, 'server_ip.txt'));
      
      if (await file.exists()) {
        _serverIP = await file.readAsString();
        return _serverIP!;
      }
    } catch (e) {
      print('Error reading server IP file: $e');
    }

    // If file doesn't exist or there's an error, try to discover the IP
    try {
      final interfaces = await NetworkInterface.list(
        type: InternetAddressType.IPv4,
        includeLinkLocal: false,
      );

      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (!addr.isLoopback) {
            _serverIP = addr.address;
            return _serverIP!;
          }
        }
      }
    } catch (e) {
      print('Error discovering IP: $e');
    }

    // Fallback to localhost
    _serverIP = 'localhost';
    return _serverIP!;
  }

  static Future<String> getServerUrl() async {
    final ip = await getServerIP();
    return 'http://$ip:$serverPort';
  }
} 