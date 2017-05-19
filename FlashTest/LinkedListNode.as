package {


	public class LinkedListNode {
		
		public var next:LinkedListNode;
		public var data:String;
		
		// Graphical stuff ...
		
		public var x:Number;
		public var y:Number;
//		public var w:Number;
//		public var h:Number;
		
		public var graphicID:int;
				
		
		public function LinkedListNode(val, id, initialX, initialY)
		{
			data = val;
			graphicID = id;
			x = initialX;
			y = initialY;
			next = null;
		}		
	}
}

