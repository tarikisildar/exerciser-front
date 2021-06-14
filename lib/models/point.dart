class Point
{
  final dynamic name;
  final dynamic x;
  final dynamic y;
  final dynamic score;
  Point(this.name,this.x,this.y,this.score);

  Map toJson() => {
        'name': name,
        'x': x,
        'y': y,
        'score':score
      };
}

class KeyPointSequence
{
  final dynamic width;
  final dynamic height;
  final dynamic frames;
  KeyPointSequence(this.width,this.height,this.frames);
  Map toJson() => {
        'frames': frames,
        'width' : width,
        'height' : height
      };
}

class KeyPoints
{
  final dynamic keypoints;
  KeyPoints(this.keypoints);
  Map toJson() => {
        'keypoints': keypoints
      };
}