package Objects
{
	public class UndoCreate extends UndoBlock
	{
		public var objectID:int;

		function UndoCreate(id):void
		{
			objectID = id;
		}
		
		override public function undoInitialStep(world):void
		{
			world.removeObject(objectID);
		}
	}
}