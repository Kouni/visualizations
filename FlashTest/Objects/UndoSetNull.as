package Objects
{

	public class UndoSetNull extends UndoBlock
	{
		public var objectID:int;
		public var nullPointer:Boolean;

		function UndoSetNull(id:int, np:Boolean):void
		{
			objectID = id;
			nullPointer = np;
		}
		override public function undoInitialStep(world) :void
		{
			world.setNull(objectID, nullPointer);
		}
	}
}