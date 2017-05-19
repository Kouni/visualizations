package Objects
{

	public class UndoHighlightEdge extends UndoBlock
	{
		public var fromID:int;
		public var toID:int;
		public var highlightValue:Boolean;

		function UndoHighlightEdge(from, to, val):void
		{
			fromID = from;
			toID = to;
			highlightValue = val;
		}
		override public function undoInitialStep(world):void
		{
			world.setEdgeHighlight(fromID, toID, highlightValue);
		}
	}
}