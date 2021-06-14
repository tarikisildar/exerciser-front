
class VideoSimilarityRequest
{
  int width;
  int height;
  dynamic frames;

  VideoSimilarityRequest(this.width,this.height,this.frames);

  Map toJson() => {
        'frames': frames,
        'width' : width,
        'height' : height,
      };

}