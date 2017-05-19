package {


	public class AVLNode {
		
		public var left:AVLNode;
		public var right:AVLNode;
		public var data:String;
		public var x:int;
		public var y:int;
		public var heightLabelID:int;
		public var parent:AVLNode;
		public var heightLabelX:int;
		public var heightLabelY:int;
		
		public var leftWidth:int;
		public var rightWidth:int;
		public var graphicID:int;
		public var height:int;
		
		public function AVLNode(val, id, hid, initialX, initialY)
		{
			data = val;
			x = initialX;
			y = initialY;
			heightLabelID= hid;
			height = 1;
			
			graphicID = id;
		}
		
		public function isLeftChild()
		{
			if (parent == null)
			{
				return true;
			}
			return parent.left == this;
		}
	}
}

