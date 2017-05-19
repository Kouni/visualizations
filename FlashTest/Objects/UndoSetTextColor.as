package Objects
{
	public class UndoSetTextColor extends UndoBlock
	{
		public var objectID:int;
		public var color:uint;
		public var labelIndex:int;

		function UndoSetTextColor(id:int, c:uint, index:int = 0):void
		{
			objectID = id;
			color = c;
			labelIndex = index;
		}
		
		override public function undoInitialStep(world):void
		{
			world.setTextColor(objectID, color, labelIndex);
		}
	}
}