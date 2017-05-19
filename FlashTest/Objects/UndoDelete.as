package 
{
	public class UndoDelete extends UndoBlock
	{

		public var objectID:int;
		public var posX:int;
		public var posY:int
		public var nodeLabel:String;
		public var type:int;
		public var labCentered:Boolean;
		public var nodeColor:uint;
		
		function UndoDelete(id, lab, typ, x, y, centered:Boolean = true, color:uint = 0x0000FF):void
		{
			objectID = id;
			posX = x;
			posY = y;
			nodeLabel = lab;
			type = typ;
			labCentered = centered;
			nodeColor = color;
		}
		
		override public function undoInitialStep(world):void
		{
			if (type == AnimatedObject.CIRCLE)
		 	{
				world.addCircleObject(objectID,nodeLabel);
			}
			else if (type == AnimatedObject.LABEL)
			{
				world.addLabelObject(objectID, nodeLabel, labCentered);
			}
			else if (type == AnimatedObject.HIGHLIGHTCIRCLE)
			{
				world.addHighlightCircleObject(objectID, nodeColor);
			}
			else
			{
				// ERROR!
			}
			world.setNodePosition(objectID, posX, posY);

			return false;
		}
	}
}