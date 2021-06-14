


class Exercise
{
  final String id;
  final String name;
  final String difficulty;
  final String imageUrl;
  final String videoUrl;

  Exercise(this.id,this.name,this.difficulty,this.imageUrl,this.videoUrl);

  Exercise.fromJson(Map<String, dynamic> json)
    : 
      id = json['id'],
      name = json['name'],
      difficulty = json['difficulty'],
      imageUrl = json['imageUrl'],
      videoUrl = json['videoUrl'];

  Map<String, dynamic> toJson() => 
  {
    'id' : id,
    'name' : name,
    'difficulty' : difficulty,
    'videoUrl' : videoUrl,
    'imageUrl' : imageUrl
  };

}







