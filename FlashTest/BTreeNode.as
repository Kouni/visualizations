package {

	public class BTreeNode {
		
		public var children:Array;
		public var keys:Array;
		public var numKeys:int;
		public var isLeaf:Boolean;
		public var widths:Array;
		public var width:int;
		
		public var x:int;
		public var y:int;
		public var parent:BTreeNode;
		
		public var leftWidth:int;
		public var rightWidth:int;
		public var graphicID:int;
		
		// only used for B+ trees.  Could use children, but I got lazy ...
		public var next:BTreeNode;
		public function BTreeNode(id, initialX, initialY)
		{
			widths = new Array();
			keys = new Array();
			children = new Array();
			x = initialX;
			y = initialY;
			graphicID = id;
			numKeys = 1;
			isLeaf = true;
			parent = null;
			
		}
	}
}

