import 'package:geolinked/utils/app_exports.dart';

class HomeState {
  const HomeState({required this.currentIndex});

  final int currentIndex;

  HomeState copyWith({int? currentIndex}) {
    return HomeState(currentIndex: currentIndex ?? this.currentIndex);
  }
}

class HomeController extends Notifier<HomeState> {
  @override
  HomeState build() {
    return const HomeState(currentIndex: 0);
  }

  void setCurrentIndex(int index) {
    if (index == state.currentIndex) {
      return;
    }

    state = state.copyWith(currentIndex: index);
  }

  void onAskPressed() {
    
  }

  void onBroadcastPressed() {}
}

final homeControllerProvider = NotifierProvider<HomeController, HomeState>(
  HomeController.new,
);
