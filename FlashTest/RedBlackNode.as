package {


	public class RedBlackNode {
		
		public var left:RedBlackNode;
		public var right:RedBlackNode;
		public var data:String;
		public var x:int;
		public var y:int;
		public var parent:RedBlackNode;
		
		public var leftWidth:int;
		public var rightWidth:int;
		public var graphicID:int;
		public var blackLevel:int;
		public var height:int;
		public var phantomLeaf:Boolean;
		
		public function RedBlackNode(val, id, initialX, initialY)
		{
			data = val;
			x = initialX;
			y = initialY;
			blackLevel = 0;
			phantomLeaf = false;
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

