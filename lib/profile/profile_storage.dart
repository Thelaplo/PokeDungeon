import 'package:shared_preferences/shared_preferences.dart';

abstract interface class ProfileStorage {
  String? read();

  Future<void> write(String encodedProfile);
}

class SharedPreferencesProfileStorage implements ProfileStorage {
  SharedPreferencesProfileStorage(this._preferences);

  static const storageKey = 'poke_dungeon.player_profile';

  final SharedPreferences _preferences;

  static Future<SharedPreferencesProfileStorage> create() async =>
      SharedPreferencesProfileStorage(await SharedPreferences.getInstance());

  @override
  String? read() => _preferences.getString(storageKey);

  @override
  Future<void> write(String encodedProfile) =>
      _preferences.setString(storageKey, encodedProfile);
}
