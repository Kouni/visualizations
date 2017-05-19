package {


	public class BSTNode {
		
		public var left:BSTNode;
		public var right:BSTNode;
		public var data:String;
		public var x:int;
		public var y:int;
		public var parent:BSTNode;
		
		public var leftWidth:int;
		public var rightWidth:int;
		public var graphicID:int;
		
		public function BSTNode(val, id, initialX, initialY)
		{
			data = val;
			x = initialX;
			y = initialY;
			graphicID = id;
		}
	}
}

