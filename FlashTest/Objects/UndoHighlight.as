package Objects
{

	public class UndoHighlight extends UndoBlock
	{
		public var objectID:int;
		public var highlightValue:Boolean;

		function UndoHighlight(id, val):void
		{
			objectID = id;
			highlightValue = val;
		}
		override public function undoInitialStep(world):void
		{
			world.setHighlight(objectID, highlightValue);
		}
	}
}