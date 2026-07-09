// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'global_loading_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(GlobalLoading)
final globalLoadingProvider = GlobalLoadingProvider._();

final class GlobalLoadingProvider
    extends $NotifierProvider<GlobalLoading, Set<String>> {
  GlobalLoadingProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'globalLoadingProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$globalLoadingHash();

  @$internal
  @override
  GlobalLoading create() => GlobalLoading();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Set<String> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Set<String>>(value),
    );
  }
}

String _$globalLoadingHash() => r'd4f0cbdaf347fcf630d727efda573e1b6dd32344';

abstract class _$GlobalLoading extends $Notifier<Set<String>> {
  Set<String> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<Set<String>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<Set<String>, Set<String>>,
              Set<String>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
