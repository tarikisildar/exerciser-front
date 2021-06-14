enum ExerciseHistoryType{
  FAILED,COMPLETED,UNCOMPLETED
}

const exerciseHistoryMap = {
  'FAILED' : ExerciseHistoryType.FAILED,
  'COMPLETED' : ExerciseHistoryType.COMPLETED,
  'UNCOMPLETED' : ExerciseHistoryType.UNCOMPLETED
  };

const exerciseHistoryParser = {
  ExerciseHistoryType.FAILED: 'FAILED' ,
  ExerciseHistoryType.COMPLETED: 'COMPLETED',
  ExerciseHistoryType.UNCOMPLETED: 'UNCOMPLETED'
};