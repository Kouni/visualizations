package Objects
{
	public class UndoConnect extends UndoBlock
	{

		public var fromID:int;
		public var toID:int;
		public var connect:Boolean;
		public var color:int;
		public var directed:Boolean;
		public var curve:Number;
		public var edgeLabel:String;
		public var anchorPoint:int;

		function UndoConnect(from, to, createConnection, edgeColor = 0x000000, isDirected = true, cv = 0, lab = "", anchor = 0):void
		{
			fromID = from;
			toID = to;
			connect = createConnection;
			color = edgeColor;
			directed = isDirected;
			curve = cv;
			edgeLabel = lab;
			anchorPoint = anchor;
		}
		
		override public function undoInitialStep(world):void
		{
			if (connect)
			{
				world.connectEdge(fromID, toID, color, curve, directed, edgeLabel, anchorPoint);
			}
			else
			{
				world.disconnect(fromID,toID);
			}
		}
	}
}