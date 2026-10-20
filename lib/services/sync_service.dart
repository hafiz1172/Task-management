import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../models/task.dart';
import 'database_helper.dart';

class SyncService {
  static Future<String?> getScriptUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('script_url');
  }

  static Future<bool> isOnline() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    return connectivityResult != ConnectivityResult.none;
  }

  static Future<bool> syncWithGoogleSheets() async {
    if (!await isOnline()) return false;

    final url = await getScriptUrl();
    if (url == null || url.trim().isEmpty) return false;

    try {
      final localTasks = await DatabaseHelper.instance.getAllTasks();
      final body = jsonEncode(localTasks.map((t) => t.toJsonForSheet()).toList());

      // POST local tasks to Google Sheets
      final postResponse = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );

      if (postResponse.statusCode == 200) {
        // GET fresh data from Google Sheets
        final getResponse = await http.get(Uri.parse(url));
        if (getResponse.statusCode == 200) {
          final List<dynamic> remoteList = jsonDecode(getResponse.body);
          List<Task> fetchedTasks = remoteList.map((x) {
            return Task(
              id: x['id'],
              title: x['title'],
              notes: x['notes'] ?? '',
              isStarred: x['isStarred'] == true,
              isCompleted: x['isCompleted'] == true,
              dueDate: x['dueDate'],
              dueTime: x['dueTime'],
              repeatRule: x['repeatRule'],
              isSynced: 1,
            );
          }).toList();

          await DatabaseHelper.instance.replaceAllTasks(fetchedTasks);
          return true;
        }
      }
    } catch (e) {
      print('Sync error: $e');
    }
    return false;
  }
}
