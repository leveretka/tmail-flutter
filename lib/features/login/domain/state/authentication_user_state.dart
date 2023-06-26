import 'package:core/core.dart';
import 'package:model/model.dart';

class AuthenticationUserLoading extends LoadingState {
  AuthenticationUserLoading();

  @override
  List<Object> get props => [];
}

class AuthenticationUserSuccess extends UIState {
  final UserProfile userProfile;

  AuthenticationUserSuccess(this.userProfile);

  @override
  List<Object> get props => [userProfile];
}

class AuthenticationUserFailure extends FeatureFailure {

  AuthenticationUserFailure(dynamic exception) : super(exception: exception);

  @override
  List<Object?> get props => [exception];
}