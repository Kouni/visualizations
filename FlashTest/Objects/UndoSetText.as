package Objects
{
	public class UndoSetText extends UndoBlock
	{
		public var objectID:int;
		public var newText:String;
		public var labelIndex:int;

		function UndoSetText(id:int, str:String, index:int = 0):void
		{
			objectID = id;
			newText = str;
			labelIndex = index;
		}
		
		override public function undoInitialStep(world):void
		{
			world.setText(objectID, newText, labelIndex);
		}
	}
}