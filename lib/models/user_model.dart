class UserModel {
  String uid;
  String email;
  String displayName;
  String phoneNumber;
  String photoUrl;

  UserModel(
      {this.uid,
      this.email,
      this.displayName,
      this.phoneNumber,
      this.photoUrl});

  UserModel.empty() {
    uid = null;
  }

  get name => uid == null ? '' : displayName;
}