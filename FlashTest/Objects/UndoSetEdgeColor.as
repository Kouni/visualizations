package Objects
{

	public class UndoSetEdgeColor extends UndoBlock
	{
		public var fromID:int;
		public var toID:int;
		public var color:uint;

		function UndoSetEdgeColor(from, to, oldColor):void
		{
			fromID = from;
			toID = to;
			color = oldColor;
		}
		override public function undoInitialStep(world):void
		{
			world.setEdgeColor(fromID, toID, color);
		}
	}
}