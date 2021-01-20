
class UserModel {

  final String uid;
  final String name;
  final String pNo;
  final String rNo;
  final String bio;
  final String email;
  final String division;
  final String dept;
  final String year;
  final List subscriptions;
  final int batch;

  UserModel(
    {
      this.uid,
      this.name,
      this.pNo,
      this.rNo,
      this.bio,
      this.email,
      this.division,
      this.year,
      this.subscriptions,
      this.batch,
      this.dept,
    }
  ) ;

}