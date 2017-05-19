package Objects
{

	public class UndoSetWidth extends UndoBlock
	{
		public var objectID:int;
		public var w:int;

		function UndoSetWidth(id:int, hgt:int):void
		{
			objectID = id;
			h = hgt;
		}
		override public function undoInitialStep(world):void
		{
			world.setWidth(objectID, w);
		}
	}
}