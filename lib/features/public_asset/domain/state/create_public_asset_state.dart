import 'package:core/presentation/state/failure.dart';
import 'package:core/presentation/state/success.dart';
import 'package:jmap_dart_client/jmap/mail/extensions/public_asset/public_asset.dart';
import 'package:tmail_ui_user/features/public_asset/domain/exceptions/public_asset_exceptions.dart';

class CreatingPublicAssetState extends LoadingState {}

class CreatePublicAssetSuccessState extends UIState {
  CreatePublicAssetSuccessState(this.publicAsset);

  final PublicAsset publicAsset;

  @override
  List<Object?> get props => [publicAsset];
}

class CreatePublicAssetFailureState extends FeatureFailure {

  CreatePublicAssetFailureState({super.exception});

  @override
  List<Object?> get props => [exception];
}

class PublicAssetOverQuotaFailureState extends FeatureFailure {

  PublicAssetOverQuotaFailureState({required this.publicAssetQuotaExceededException})
    : super(exception: publicAssetQuotaExceededException);

  final PublicAssetQuotaExceededException publicAssetQuotaExceededException;

  @override
  List<Object?> get props => [publicAssetQuotaExceededException];
}