import 'package:flutter/foundation.dart';
import 'package:possystem/models/user_model.dart';

abstract class SignInMethod<T> {
  Future<UserModel> exec({@required Future<UserModel> Function(T) builder});
}
