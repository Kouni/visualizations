package Objects
{

	public class UndoSetBackgroundColor extends UndoBlock
	{

		public var objectID:int;
		var color:int; 
		
		function UndoSetBackgroundColor(id, color):void
		{
			objectID = id;
			this.color = color;

		}
		override public function undoInitialStep(world):void
		{
			world.setBackgroundColor(objectID, color);
		}
	}
}