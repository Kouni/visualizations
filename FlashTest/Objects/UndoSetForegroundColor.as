package Objects
{

	public class UndoSetForegroundColor extends UndoBlock
	{

		public var objectID:int;
		var color:int; 
		
		function UndoSetForegroundColor(id, color):void
		{
			objectID = id;
			this.color = color;

		}
		override public function undoInitialStep(world):void
		{
			world.setForegroundColor(objectID, color);
		}
	}
}