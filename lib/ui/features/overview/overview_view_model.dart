import 'package:flutter/foundation.dart';

/// Shared MVVM ViewModel for the Overview screen.
class OverviewViewModel extends ChangeNotifier {
  int _netWorthRp = 0;

  /// Current derived net worth in whole Rupiah.
  int get netWorthRp => _netWorthRp;

  /// Placeholder refresh hook to be wired to repositories.
  void refresh() {
    _netWorthRp = 0;
    notifyListeners();
  }
}
