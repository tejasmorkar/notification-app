class Developer{
  final String login,avatarUrl,bio;

  Developer({this.login, this.avatarUrl, this.bio});
  factory Developer.fromJson(Map<String,dynamic> json){
    return Developer(
      login: json['login'],
      avatarUrl: json['avatar_url'],
      bio: json['bio']
    );
  }
}