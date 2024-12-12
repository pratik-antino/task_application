import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  SecureStorage._();

  /// Cached instance of [SecureStorageHelper];
  static SecureStorage? _instance;

  //Create a singleton pattern
  static SecureStorage get instance {
    _instance ??= SecureStorage._();

    return _instance!;
  }

  /// Create storage
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  /// Read value
  Future<String?> read(String key) async {
    return await _secureStorage.read(key: key);
  }

  Future<void> saveBool(String key, bool value) async {
    await _secureStorage.write(key: key, value: value.toString());
  }

  Future<bool> readBool(String key) async {
    String? value = await _secureStorage.read(key: key);
    return value.toString() == true.toString() ? true : false;
  }

  /// Read value
  Future<void> write(String key, String value) async {
    return await _secureStorage.write(key: key, value: value);
  }

  ///will return a list which is stored as string EX-
  ///'man,mango,apple' => ['man',mango','apple']
  Future<List<String>?> getList(String key) async {
    String? stringList = await _secureStorage.read(key: key);
    return stringList == '' ? [] : stringList?.split(',');
  }

  /// will save a list converted int string EX-
  /// ['man',mango','apple'] => 'man,mango,apple'
  Future<void> saveList(String key, List<String>? value) async {
    if (value != null) {
      return await _secureStorage.write(key: key, value: value.join(','));
    }
  }

  Future<void> saveJson(String key, Map<String, dynamic> value) async {
    return await _secureStorage.write(key: key, value: jsonEncode(value));
  }

  Future<Map<String, dynamic>> getJson(String key) async {
    final value = await _secureStorage.read(key: key);
    if (value != null) {
      return jsonDecode(value);
    }
    return {};
  }

  /// Read all values
  Future<Map<String, String>> readAll() async {
    return await _secureStorage.readAll();
  }

  /// Delete value
  Future<void> delete(String key) async {
    return await _secureStorage.delete(key: key);
  }

  /// Delete all
  Future<void> deleteAll() async {
    return await _secureStorage.deleteAll();
  }

  ///delete all keys expect from given list
  ///EX:preventedKeys => ['accessToken', 'refreshToken', 'onboardingStatus'];
  ///then these keys will not get deleted from local storage
  Future<void> deleteAllExpect({List<String>? preventedKeys}) async {
    ///this will be true if list is passed
    if (preventedKeys != null) {
      ///Map variable to store prevented data
      ///EX:- {'onboardingStatus':true}
      Map<String, String> preventedData = {};
      for (var element in preventedKeys) {
        ///reading the current key of loop from storage
        ///EX:- element =>'onboardingStatus' => true then tempStoredData=>true
        String? tempStoredData = await read(element);

        ///storing the key only if the stored key is not null or empty
        if (tempStoredData != null && tempStoredData.isNotEmpty) {
          ///adding prevented key and its data in preventedData MAP
          ///EX:- element => onboardingStatus the key and tempStoredData => true
          preventedData[element] = tempStoredData;
        }
      }

      ///deleted every thing from the storage
      await _secureStorage.deleteAll();
      if (preventedData.isNotEmpty) {
        ///if the preventedData no empty the running for loop to store the prevented data again
        preventedData.forEach((storedKey, storedData) {
          ///writing the data from prevented data
          ///EX:- storedKey => 'onboardingStatus' and storedData => true
          _secureStorage.write(key: storedKey, value: storedData);
        });
      }
    } else {
      ///if no list is passed delete all
      return await _secureStorage.deleteAll();
    }
  }
}
