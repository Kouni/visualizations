package Objects
{

	public class UndoSetPosition extends UndoBlock
	{
		var objectID:int;
		var x:Number;
		var y:Number;

		function UndoSetPosition(id:int, oldX:Number, oldY:Number):void
		{
			objectID = id;
			x = oldX;
			y = oldY;
		}
		override public function undoInitialStep(world):void
		{
			world.setNodePosition(objectID, x, y);
		}
	}
}