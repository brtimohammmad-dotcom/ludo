// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_emoji_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ActiveEmojiNotifier)
final activeEmojiProvider = ActiveEmojiNotifierProvider._();

final class ActiveEmojiNotifierProvider
    extends $NotifierProvider<ActiveEmojiNotifier, ActiveEmojisState> {
  ActiveEmojiNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeEmojiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeEmojiNotifierHash();

  @$internal
  @override
  ActiveEmojiNotifier create() => ActiveEmojiNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ActiveEmojisState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ActiveEmojisState>(value),
    );
  }
}

String _$activeEmojiNotifierHash() =>
    r'4c6ea0bceca377e23fbe663bd2b490051d4fdd5d';

abstract class _$ActiveEmojiNotifier extends $Notifier<ActiveEmojisState> {
  ActiveEmojisState build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ActiveEmojisState, ActiveEmojisState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ActiveEmojisState, ActiveEmojisState>,
              ActiveEmojisState,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
