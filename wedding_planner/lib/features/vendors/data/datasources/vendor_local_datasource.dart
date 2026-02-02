import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for vendor-related local storage operations
/// Handles favorites storage locally
abstract class VendorLocalDataSource {
  Future<List<String>> getFavoriteVendorIds();
  Future<void> addToFavorites(String vendorId);
  Future<void> removeFromFavorites(String vendorId);
  Future<bool> isFavorite(String vendorId);
}

class VendorLocalDataSourceImpl implements VendorLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _favoritesKey = 'favorite_vendors';

  VendorLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<String>> getFavoriteVendorIds() async {
    final favorites = sharedPreferences.getStringList(_favoritesKey);
    return favorites ?? [];
  }

  @override
  Future<void> addToFavorites(String vendorId) async {
    final favorites = await getFavoriteVendorIds();
    if (!favorites.contains(vendorId)) {
      favorites.add(vendorId);
      await sharedPreferences.setStringList(_favoritesKey, favorites);
    }
  }

  @override
  Future<void> removeFromFavorites(String vendorId) async {
    final favorites = await getFavoriteVendorIds();
    favorites.remove(vendorId);
    await sharedPreferences.setStringList(_favoritesKey, favorites);
  }

  @override
  Future<bool> isFavorite(String vendorId) async {
    final favorites = await getFavoriteVendorIds();
    return favorites.contains(vendorId);
  }
}
