import 'package:shared_preferences/shared_preferences.dart';

abstract class UsersViewLocalDataSource {
  Future<void> setView(bool isGrid);
  Future<bool?> getView();
}

class UsersViewLocalDataSourceImpl implements UsersViewLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String cachedListView = 'CACHED_LIST_VIEW';

  UsersViewLocalDataSourceImpl({required this.sharedPreferences});
  
  @override
  Future<void> setView(bool isGrid) async {
    await sharedPreferences.setBool(cachedListView, isGrid);
  }
  
  @override
  Future<bool?> getView() async {
    return sharedPreferences.getBool(cachedListView);
  }  
}