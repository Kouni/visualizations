package {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.display.DisplayObjectContainer;




	public class Tree extends Sprite {

		var Nodes:Array;
		var Edges:Array;

		function Tree():void {
			Nodes = new Array();
			Edges = new Array();

		}
		public function connect(n1, n2) {
			var l:Line = new Line(Nodes[n1],Nodes[n2]);
			Edges.push(l);
			addChild(l.graphic);
			setChildIndex(l.graphic,0);
		}
		
		
		public function disconnect(n1,n2)
		{
			var i:int;
			for (i = 0; i < Edges.length; i++)
			{
				if ((Edges[i].Node1 == Nodes[n1] && Edges[i].Node2 == Nodes[n2])  ||
					(Edges[i].Node1 == Nodes[n2] && Edges[i].Node2 == Nodes[n2]))
				{
					var deleted:Line = Edges[i];
					removeChild(deleted.graphic);
					Edges[i] = Edges[Edges.length-1];					
					Edges.pop();
				}
			}
			
		}
		
		public function addNode(lab):int {
			var nodeID:int = Nodes.length;
			var newNode:BinaryTreeNode = new BinaryTreeNode(nodeID, lab);
			Nodes.push(newNode);
			addChild(newNode);
			return nodeID;
		}
		
		
		public function setNodePosition(nodeID, newX, newY)
		{
			Nodes[nodeID].x = newX;
			Nodes[nodeID].y = newY;
			var i:int;
			for (i = 0; i < Edges.length; i++) {
				if (Edges[i].hasNode(Nodes[nodeID]))
				{
				Edges[i].Dirty = true;
				}
			}			
		}
		
		
		public function Highlight(nodeID)
		{
			Nodes[nodeID].Highlight();
		}
		
		public function nodeX(nodeID):int
		{
			return Nodes[nodeID].x;
		}
		
		public function nodeY(nodeID): int
		{
			return Nodes[nodeID].y;
		}
		

		
		public function moveNode(nodeID, deltaX, deltaY)
		{
			setNodePosition(nodeID, Nodes[nodeID].x + deltaX, Nodes[nodeID].y + deltaY);
		}
		
		
		
		public function redoEdges() {
			var i:int;
			for (i = 0; i < Edges.length; i++) {
				Edges[i].Redraw();
			}
		}
	}
}