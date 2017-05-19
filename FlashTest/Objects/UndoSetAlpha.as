package Objects
{

	public class UndoSetAlpha extends UndoBlock
	{
		public var objectID:int;
		public var alphaVal:Number;

		function UndoSetAlpha(id:int, alph:Number):void
		{
			objectID = id;
			alphaVal = alph;
		}
		override public function undoInitialStep(world) :void
		{
			world.setAlpha(objectID, alphaVal);
		}
	}
}