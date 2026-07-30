import 'package:flutter_riverpod/flutter_riverpod.dart';

class MainTabIndex extends Notifier<int> {
  @override
  int build() => 0;

  void setIndex(int index) {
    state = index;
  }
}

final mainTabIndexProvider = NotifierProvider<MainTabIndex, int>(MainTabIndex.new);
