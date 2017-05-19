package Objects
{
	public class UndoDeleteHighlightCircle extends UndoBlock
	{

		public var objectID:int;
		public var posX:int;
		public var posY:int
		public var nodeColor:uint;
		public var rad;
		public var layer;
		
		function UndoDeleteHighlightCircle(id, x, y, color, radius, l):void
		{
			objectID = id;
			posX = x;
			posY = y;
			nodeColor = color;
			rad = radius;
			layer = l
		}
		
		override public function undoInitialStep(world):void
		{

			world.addHighlightCircleObject(objectID, nodeColor, rad);
			world.setLayer(objectID, layer)
			world.setNodePosition(objectID, posX, posY);
		}
	}
}