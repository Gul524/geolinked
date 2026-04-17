import 'package:geolinked/utils/app_exports.dart';
import 'package:geolinked/feature/ask/ask_sheet/ask_sheet.dart';
import 'package:geolinked/feature/ask/ask_sheet/ask_sheet_controller.dart';
import 'package:geolinked/feature/broadcast/broadcast_sheet/broadcast_sheet.dart';
import 'package:geolinked/feature/broadcast/broadcast_sheet/broadcast_sheet_controller.dart';
import 'package:geolinked/feature/map/map_controller.dart';
import 'package:latlong2/latlong.dart';

enum HomeTargetAction { ask, broadcast }

class HomeState {
  const HomeState({required this.currentIndex, this.pendingTargetAction});

  final int currentIndex;
  final HomeTargetAction? pendingTargetAction;

  HomeState copyWith({
    int? currentIndex,
    HomeTargetAction? pendingTargetAction,
    bool clearPendingTargetAction = false,
  }) {
    return HomeState(
      currentIndex: currentIndex ?? this.currentIndex,
      pendingTargetAction: clearPendingTargetAction
          ? null
          : (pendingTargetAction ?? this.pendingTargetAction),
    );
  }
}

class HomeController extends Notifier<HomeState> {
  Ref get providerRef => ref;

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

  void onAskPressed(BuildContext context) {
    _startTargetSelection(context, HomeTargetAction.ask);
  }

  void onBroadcastPressed(BuildContext context) {
    _startTargetSelection(context, HomeTargetAction.broadcast);
  }

  void _startTargetSelection(BuildContext context, HomeTargetAction action) {
    setCurrentIndex(0);
    state = state.copyWith(pendingTargetAction: action);

    providerRef
        .read(homeMapControllerProvider.notifier)
        .enterTargetSelectionMode();
    AppMessaging.showInfo(context, 'Tap on map to select target location.');
  }

  Future<void> onLocationConfirmed(BuildContext context) async {
    final HomeTargetAction? action = state.pendingTargetAction;
    if (action == null) {
      return;
    }

    switch (action) {
      case HomeTargetAction.ask:
        await _handleAskLocationConfirmed(context);
      case HomeTargetAction.broadcast:
        await _handleBroadcastLocationConfirmed(context);
    }

    providerRef
        .read(homeMapControllerProvider.notifier)
        .clearTargetSelectionMode();
  }

  Future<void> _handleAskLocationConfirmed(BuildContext context) async {
    final ConfirmedMapTarget? confirmedTarget =
        await _getConfirmedTargetLocation();
    if (confirmedTarget == null) {
      return;
    }

    final LatLng point = confirmedTarget.point;
    final String? locationName = confirmedTarget.locationName;

    final AskSheetResult? askResult = await AskSheet.showSheet(
      context,
      targetLocation: AskSheetGeoPoint(
        latitude: point.latitude,
        longitude: point.longitude,
      ),
      targetLocationName: locationName,
    );

    if (context.mounted && askResult != null) {
      AppMessaging.showSuccess(
        context,
        'Query submitted for ${askResult.radiusMeters}m nearby people.',
      );
    }
  }

  Future<void> _handleBroadcastLocationConfirmed(BuildContext context) async {
    final ConfirmedMapTarget? confirmedTarget =
        await _getConfirmedTargetLocation();
    if (confirmedTarget == null) {
      return;
    }

    final LatLng point = confirmedTarget.point;
    final String? locationName = confirmedTarget.locationName;

    final BroadcastSheetResult? broadcastResult =
        await BroadcastSheet.showSheet(
          context,
          targetLocation: BroadcastSheetGeoPoint(
            latitude: point.latitude,
            longitude: point.longitude,
          ),
          targetLocationName: locationName,
        );

    if (context.mounted && broadcastResult != null) {
      AppMessaging.showSuccess(
        context,
        '${broadcastResult.category} broadcast shared in ${broadcastResult.radiusMeters}m radius.',
      );
    }
  }

  Future<ConfirmedMapTarget?> _getConfirmedTargetLocation() async {
    final ConfirmedMapTarget? confirmedTarget = await providerRef
        .read(homeMapControllerProvider.notifier)
        .confirmLocationSelection();

    if (confirmedTarget == null) {
      return null;
    }

    state = state.copyWith(clearPendingTargetAction: true);
    return confirmedTarget;
  }
}

final homeControllerProvider = NotifierProvider<HomeController, HomeState>(
  HomeController.new,
);
