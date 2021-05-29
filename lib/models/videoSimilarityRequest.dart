
class VideoSimilarityRequest
{
  int exerciseId;
  int width;
  int height;
  dynamic frames;
  int k;
  int size;
  String index;

  VideoSimilarityRequest(this.exerciseId,this.width,this.height,this.frames,this.k,this.size,this.index);

  Map toJson() => {
        'exerciseId' : exerciseId,
        'frames': frames,
        'width' : width,
        'height' : height,
        'k' : k,
        'size' : size,
        'index' : index
      };

}