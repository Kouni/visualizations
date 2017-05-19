package Objects
{
	public class UndoDeleteLabel extends UndoBlock
	{

		public var objectID:int;
		public var posX:int;
		public var posY:int
		public var nodeLabel:String;
		public var labCentered:Boolean;
		public var labelColor:uint;
		public var layer:int;
		
		function UndoDeleteLabel(id, lab, x, y, centered, color, l):void
		{
			objectID = id;
			posX = x;
			posY = y;
			nodeLabel = lab;
			labCentered = centered;
			labelColor = color;
			layer = l;
		}
		
		override public function undoInitialStep(world):void
		{
			world.addLabelObject(objectID, nodeLabel, labCentered);
			world.setNodePosition(objectID, posX, posY);
			world.setForegroundColor(objectID, labelColor);
			world.setLayer(objectID, layer);
		}
	}
}