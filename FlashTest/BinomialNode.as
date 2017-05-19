package {

	public class BinomialNode {
		
		public var degree:int;
		public var leftChild:BinomialNode;
		public var rightSib:BinomialNode;
		public var parent:BinomialNode;
		
		public var data:String;
		public var x:Number;
		public var y:Number;
		
		public var graphicID:int;
		public var internalGraphicID:int;
		public var degreeID:int;
		
		public function BinomialNode(val, id, initialX, initialY)
		{
			data = val;
			x = initialX;
			y = initialY;
			graphicID = id;
			degree = 0;
		}
	}
}

