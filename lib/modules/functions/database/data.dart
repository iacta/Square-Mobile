import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:square/modules/functions/notifications/notify.dart';

import '../notifications/plan.dart';

class Account {
  String key;
  String name;
  int? planExpire;
  int? id;
  bool isSelected;

  Account(this.key, this.name, this.planExpire, {this.isSelected = false});

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      json['key'] as String,
      json['name'] as String,
      json['planExpire'],
      isSelected: json['isSelected'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'key': key,
        'name': name,
        'isSelected': isSelected,
        'planExpire': planExpire,
      };
  DateTime getExpirationDate() {
    return DateTime.fromMillisecondsSinceEpoch(planExpire!);
  }
}

class AccountManager {
  static const String _sharedPreferencesKey = "accounts";
  static const String _selectAccountKey = "selectAccount";
  Future<void> checkPlanExpiration() async {
    final accounts = await getAllAccounts();

    for (final account in accounts) {
      if (account.planExpire != null) {
        final now = DateTime.now();
        final expirationDate = account.getExpirationDate();
        final daysRemaining = expirationDate.difference(now).inDays;

        // Subtrai um dia do plano a cada 24 horas
        if (daysRemaining > 0 &&
            now.hour == expirationDate.hour &&
            now.minute == expirationDate.minute) {
          account.planExpire = expirationDate
              .subtract(const Duration(days: 1))
              .millisecondsSinceEpoch;
          await saveAccount(account);
        }

        // Envia notificação se necessário
        final notificationMessage = expireMessage(daysRemaining);
        await showExpirationNotification(notificationMessage);
            }
    }
  }

  Future<void> showExpirationNotification(String notificationMessage) async {
    NotificationService notify = NotificationService();

    await notify.showNotification(
      id: 0,
      title: 'Aviso de Expiração do Plano',
      body: notificationMessage,
    );
  }

  static Future<void> saveAccount(Account account) async {
    final accounts = await getAllAccounts();
    final index = accounts.indexWhere((a) => a.id == account.id);

    if (index != -1) {
      accounts[index] = account;
      await saveAllAccounts(accounts);
    }
  }

  static Future<void> saveAllAccounts(List<Account> accounts) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final accountsString = json.encode(accounts);
    await sharedPreferences.setString(_sharedPreferencesKey, accountsString);
  }

  static Future<List<Account>> getAllAccounts() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final accountsString = sharedPreferences.getString(_sharedPreferencesKey);

    if (accountsString == null) {
      return [];
    }

    final dynamic decodedData = json.decode(accountsString);

    if (decodedData is List &&
        decodedData.every((element) => element is Map<String, dynamic>)) {
      final accounts =
          decodedData.cast<Map<String, dynamic>>().map((accountMap) {
        final account = Account.fromJson(accountMap);
        return account;
      }).toList();

      return accounts;
    } else {
      throw const FormatException("Invalid format for accounts data");
    }
  }

  static Future<bool> addAccount(Account account) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final accounts = await getAllAccounts();
    if (accounts.any((a) => a.name == account.name)) {
      return false;
    }
    accounts.add(account);
    final accountsString = json.encode(accounts);
    await sharedPreferences.setString(_sharedPreferencesKey, accountsString);
    return true;
  }

  static Future<bool> deleteAccount(String accountName) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final accounts = await getAllAccounts();
    final index = accounts.indexWhere((a) => a.name == accountName);
    if (index == -1) {
      return false;
    }
    accounts.removeAt(index);
    final accountsString = json.encode(accounts);
    await sharedPreferences.setString(_sharedPreferencesKey, accountsString);
    return true;
  }

  static Future<bool> selectAccount(String accountName) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    await sharedPreferences.setString(_selectAccountKey, accountName);
    return true;
  }

  static Future<Account?> getCurrentAccount() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final accountName = sharedPreferences.getString(_selectAccountKey);
    if (accountName == null) {
      return null;
    }
    final accounts = await getAllAccounts();
    final account = accounts.firstWhere((a) => a.name == accountName);
    return account;
  }

  static Future<Account?> loadCurrentAccount() async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final accountName = sharedPreferences.getString(_selectAccountKey);

    if (accountName == null) {
      return null;
    }

    final accounts = await getAllAccounts();

    if (accounts.isNotEmpty) {
      final account = accounts.firstWhere((a) => a.name == accountName);
      return account;
    }

    return null;
  }

  Future<int?> getSelectedAccountId() async {
    final account = await loadCurrentAccount();
    if (account == null) {
      return null;
    } else {
      return account.id;
    }
  }

  static Future<bool> changeAccountKey(
      String accountName, String newKey) async {
    final sharedPreferences = await SharedPreferences.getInstance();
    final accounts = await getAllAccounts();
    final index = accounts.indexWhere((a) => a.name == accountName);

    if (index == -1) {
      return false;
    }

    accounts[index].key = newKey;

    // Salva as contas atualizadas no SharedPreferences
    final accountsString = json.encode(accounts);
    await sharedPreferences.setString(_sharedPreferencesKey, accountsString);

    return true; // Chave alterada com sucesso
  }
}
