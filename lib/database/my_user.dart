class MyUser{
  static const String CollectionName = 'user';

  String id;
  String fullName;
  String email;
  MyUser({required this.id,required this.fullName,required this.email});

  MyUser.fromJson(Map<String , dynamic> json):this(

    id: json['id'],
    fullName: json['fullName'],
    email: json['email'],
  );


  Map<String , dynamic> toJson(){
    return{
    'id':id,
    'fullName':fullName,
    'email':email,
  };
}
}