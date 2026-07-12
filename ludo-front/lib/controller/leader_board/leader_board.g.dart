// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leader_board.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(LeaderboardDataNotifier)
final leaderboardDataProvider = LeaderboardDataNotifierProvider._();

final class LeaderboardDataNotifierProvider
    extends $NotifierProvider<LeaderboardDataNotifier, LeaderboardStateData?> {
  LeaderboardDataNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'leaderboardDataProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$leaderboardDataNotifierHash();

  @$internal
  @override
  LeaderboardDataNotifier create() => LeaderboardDataNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(LeaderboardStateData? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<LeaderboardStateData?>(value),
    );
  }
}

String _$leaderboardDataNotifierHash() =>
    r'81981a8e247815c9bcb14dcbfcbb444f98cc22f3';

abstract class _$LeaderboardDataNotifier
    extends $Notifier<LeaderboardStateData?> {
  LeaderboardStateData? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<LeaderboardStateData?, LeaderboardStateData?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<LeaderboardStateData?, LeaderboardStateData?>,
              LeaderboardStateData?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
