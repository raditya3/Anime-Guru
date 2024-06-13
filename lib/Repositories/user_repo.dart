import '../Entities/user_entity.dart';

abstract class UserRepo {

  Future<UserEntity> getMyUserInfo();



}