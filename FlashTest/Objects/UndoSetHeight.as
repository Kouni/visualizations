package Objects
{

	public class UndoSetHeight extends UndoBlock
	{
		public var objectID:int;
		public var h:int;

		function UndoSetHeight(id:int, hgt:int):void
		{
			objectID = id;
			h = hgt;
		}
		override public function undoInitialStep(world):void
		{
			world.setHeight(objectID, h);
		}
	}
}