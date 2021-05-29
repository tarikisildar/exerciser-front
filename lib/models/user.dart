class User
{
  String userId;
  String userName;
  User(this.userId,this.userName);

  User.fromJson(Map<String, dynamic> json) : 
    userId = json["_id"],
    userName = json["username"];
  Map<String, dynamic> toJson() => {
    '_id' : userId,
    'userName' : userName
  };
  
}