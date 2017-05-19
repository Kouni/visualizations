package Objects
{

	public class UndoMove extends UndoBlock
	{

		public var objectID:int;
		public var fromX:int;
		public var fromY:int;
		public var toX:int;
		public var toY:int;

		function UndoMove(id, fmX, fmy, tx, ty):void
		{
			objectID = id;
			fromX = fmX;
			fromY = fmy;
			toX = tx;
			toY = ty;
		}
		override public function addUndoAnimation(animationList):Boolean
		{
			var nextAnim:SingleAnimation = new SingleAnimation();
			nextAnim.objectID = objectID;
			nextAnim.fromX = fromX;
			nextAnim.fromY = fromY;
			nextAnim.toX = toX;
			nextAnim.toY = toY;
			animationList.push(nextAnim);
			return true;
		}
	}
}