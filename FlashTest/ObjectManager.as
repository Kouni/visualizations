package 
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.display.DisplayObjectContainer;
	import Objects.*;



	public class ObjectManager extends Sprite
	{

		var Nodes:Array;
		var Edges:Array;
		var BackEdges:Array;
		var frameNum:int;
		var activeLayers:Array;
		public var runFast = false;
		
		
		function ObjectManager():void
		{
			Nodes = new Array();
			Edges = new Array();
			BackEdges = new Array();
			activeLayers = new Array();
			activeLayers[0] = true;

		}
		
		// Show (or hide, depdending upon the value of the parameter shown)
		// a set of layers (in the parameters args
		public function setLayers(shown, layers)
		{
			for (var i:uint = 0; i < layers.length; i++)
			{
				activeLayers[layers[i]] = shown;								
			}
			resetLayers();
		}
		

		// Show only the set of layers in the parameters args		
		public function setAllLayers(layers):void
		{
			activeLayers = new Array();
			for (var i:uint = 0; i < layers.length; i++)
			{
				activeLayers[layers[i]] = true;								
			}
			resetLayers();			
		}
		
		public function resetLayers()
		{
			for (var i:int = Nodes.length; i >= 0; i--)
			{
				if (Nodes[i] != null)
				{
					if (activeLayers[Nodes[i].layer] && !Nodes[i].addedToScene)
					{
						Nodes[i].addedToScene = true;
						addChildAt(Nodes[i], 0);
					}
					else if (!activeLayers[Nodes[i].layer]  && Nodes[i].addedToScene)
					{
						removeChild(Nodes[i]);
						Nodes[i].addedToScene = false;
					}
				}				
			}
			for (i = Edges.length; i >= 0; i--)
			{
				if (Edges[i] != null)
				{
					for (var j:int = Edges[i].length; j >= 0; j--)
					{
						if (Edges[i][j] != null)
						{
							if (activeLayers[Edges[i][j].Node1.layer] && activeLayers[Edges[i][j].Node2.layer] && !Edges[i][j].addedToScene)
							{
								Edges[i][j].addedToScene = true;
								addChild(Edges[i][j].graphic);
							}
							else if ((!activeLayers[Edges[i][j].Node1.layer]  || !activeLayers[Edges[i][j].Node2.layer]) && Edges[i][j].addedToScene)
							{
								Edges[i][j].addedToScene = false;
								removeChild(Edges[i][j].graphic);
							}
							Edges[i][j].Dirty = true;
						}
					}				
				}
			}
			update();
		}
		
		public function deleteIncident(objectID):Array
		{
			var undoStack:Array = new Array();
// 			var returnArray:Array;

			if (Edges[objectID] != null)
			{
				var len:int = Edges[objectID].length;
				for (var i: int = len - 1; i >= 0; i--)
				{
					var deleted = Edges[objectID][i];
					var node2ID = deleted.Node2.identifier();
					undoStack.push(deleted.createUndoDisconnect());
					
					if (deleted.addedToScene)
					{
						removeChild(deleted.graphic);
						deleted.addedToScene = false;
					}
					var len2: int = BackEdges[node2ID].length;
					for (var j:int = len2 - 1; j >=0; j--)
					{
						if (BackEdges[node2ID][j] == deleted)
						{
							BackEdges[node2ID][j] = BackEdges[node2ID][len2 - 1];
							len2 -= 1;
							BackEdges[node2ID].pop();
						}
					}
				}
				Edges[objectID] = null;
			}
			if (BackEdges[objectID] != null)
			{
				len = BackEdges[objectID].length;
				for (i = len - 1; i >= 0; i--)
				{
					deleted = BackEdges[objectID][i];
					var node1ID = deleted.Node1.identifier();
					undoStack.push(deleted.createUndoDisconnect());
					if (deleted.addedToScene)
					{
						removeChild(deleted.graphic);
						deleted.addedToScene = false;
					}
					len2 = Edges[node1ID].length;
					for (j = len2 - 1; j >=0; j--)
					{
						if (Edges[node1ID][j] == deleted)
						{
							Edges[node1ID][j] = Edges[node1ID][len2 - 1];
							len2 -= 1;
							Edges[node1ID].pop();
						}
					}
				}
				BackEdges[objectID] = null;
			}
			return undoStack;
		}
		
		
		
		
		public function connectEdge(objectIDfrom, objectIDto, color = 0x000000, curve:Number = 0.0, directed= true, lab = "", connectionPoint = 0)
		{
			// TODO:  Make directed as well as undirected
			var fromObj : AnimatedObject = Nodes[objectIDfrom];
			var toObj : AnimatedObject = Nodes[objectIDto];
			if (fromObj == null || toObj == null)
			{
				throw new Error("Tried to connect two nodes, one didn't exist!");
			}
			var l = new Line(Nodes[objectIDfrom],Nodes[objectIDto], color, curve, directed, lab, connectionPoint);
			if (Edges[objectIDfrom] == null)
			{
				Edges[objectIDfrom] = new Array();
			}
			if (BackEdges[objectIDto] == null)
			{
				BackEdges[objectIDto] = new Array();
			}
			Edges[objectIDfrom].push(l);
			BackEdges[objectIDto].push(l);

			if (activeLayers[fromObj.layer] && activeLayers[toObj.layer])
			{
				addChild(l.graphic);
				l.addedToScene = true;
			}
			else
			{
				l.addedToScene = false;
			}
		}
		
		
		
		
		
		public function disconnect(objectIDfrom,objectIDto)
		{
			var undo:UndoConnect = null;
			var i:int;
			if (Edges[objectIDfrom] != null)
			{
				var len:int = Edges[objectIDfrom].length;
				for (i = len - 1; i >= 0; i--)
				{
					if (Edges[objectIDfrom][i] != null && Edges[objectIDfrom][i].Node2 == Nodes[objectIDto])
					{
						var deleted = Edges[objectIDfrom][i];
						undo = deleted.createUndoDisconnect();
						if (deleted.addedToScene)
							removeChild(deleted.graphic);
						Edges[objectIDfrom][i] = Edges[objectIDfrom][len - 1];
						len -= 1;
						Edges[objectIDfrom].pop();
					}
				}
			}
			if (BackEdges[objectIDto] != null)
			{
				len = BackEdges[objectIDto].length;
				for (i = len - 1; i >= 0; i--)
				{
					if (BackEdges[objectIDto][i] != null && BackEdges[objectIDto][i].Node1 == Nodes[objectIDfrom])
					{
						deleted = BackEdges[objectIDto][i];
						// Note:  Don't need to remove this child, did it above on the regular edge
						BackEdges[objectIDto][i] = BackEdges[objectIDto][len - 1];
						len -= 1;
						BackEdges[objectIDto].pop();
					}
				}
			}
			return undo;
		}
		
		
		public function addLinkedListObject(objectID, nodeLabel, width, height, linkPer = 0.25, verticalOrientation = true, linkPosEnd = false, numLabels = 1, backgroundColor = 0xFFFFFF, foregroundColor = 0x000000):void
		{
			if (Nodes[objectID] != null)
			{
				throw new Error("addLinkedListObject:Object with same ID already Exists!");
			}
			var newNode:AnimatedLinkedList = new AnimatedLinkedList(objectID, nodeLabel, width, height, linkPer, verticalOrientation, linkPosEnd, numLabels, backgroundColor, foregroundColor);
			Nodes[objectID] = newNode;
			addChild(newNode);		
		}
		
		
		public function setLayer(objectID, newLayer)
		{
			if (Nodes[objectID] != null)
			{
				Nodes[objectID].layer = newLayer;
				if (activeLayers[Nodes[objectID].layer] && !Nodes[objectID].addedToScene)
				{
					Nodes[objectID].addedToScene = true;
					addChildAt(Nodes[objectID], 0);
				}
				else if (!activeLayers[Nodes[objectID].layer] && Nodes[objectID].addedToScene)
				{
					removeChild(Nodes[objectID]);
					Nodes[objectID].addedToScene = false;
				}
			}
			else
			{
				throw new Error("can't set the layer of a non-existant object");
			}
			
		}
		
		public function getNumElements(objectID)
		{
			return Nodes[objectID].getNumElements();
		}
		
		public function setNumElements(objectID, numElems:int)
		{
			Nodes[objectID].setNumElements(numElems);
			var i:int;
			var len:int;
			if (Edges[objectID] != null)
			{
				len = Edges[objectID].length;
				for (i = 0; i < len; i++)
				{
					if (Edges[objectID][i] != null)
					{
						Edges[objectID][i].Dirty = true;
					}
				}
			}
			if (BackEdges[objectID] != null)
			{
				len = BackEdges[objectID].length;
				for (i = 0; i < len; i++)
				{
					if (BackEdges[objectID][i] != null)
					{
						BackEdges[objectID][i].Dirty = true;
					}
				}
			}
		}
		
		public function addBTreeNode(objectID, widthPerElem, height, numElems, backgroundColor = 0xFFFFFF, foregroundColor = 0x000000)
		{
			if (Nodes[objectID] != null)
			{
				throw new Error("addBTreeNode:Object with same ID already Exists!");
			}
			var newNode:AnimatedBTreeNode = new AnimatedBTreeNode(objectID,widthPerElem, height, numElems, backgroundColor, foregroundColor);
			Nodes[objectID] = newNode;
			addChild(newNode);						
		}
		
		public function addRectangleObject(objectID,nodeLabel, width, height, xJustify = "center", yJustify = "center", backgroundColor = 0xFFFFFF, foregroundColor = 0x000000):void
		{
			if (Nodes[objectID] != null)
			{
				throw new Error("addRectangleObject:Object with same ID already Exists!");
			}
			var newNode:AnimatedRectangle = new AnimatedRectangle(objectID,nodeLabel, width, height, xJustify, yJustify, backgroundColor, foregroundColor);
			Nodes[objectID] = newNode;
			addChild(newNode);		
			
		}
		
		
		public function setNull(objectID, nullVal:Boolean):void
		{
			if (Nodes[objectID] != null)
			{
				Nodes[objectID].setNull(nullVal);
				
			}
		}
		
		public function getNull(objectID):Boolean
		{
			if (Nodes[objectID] != null)
			{
				return Nodes[objectID].getNull();
			}
			return false;  // TODO:  Error here?
		}
		
		
		public function setForegroundColor(objectID, color):void
		{
			if (Nodes[objectID] != null)
			{
				Nodes[objectID].setForegroundColor(color);
				
			}
		}
		
		public function setBackgroundColor(objectID, color):void
		{
			if (Nodes[objectID] != null)
			{
				Nodes[objectID].setBackgroundColor(color);
				
			}
		}

		public function setHeight(objectID, h):void
		{
			if (Nodes[objectID] != null)
			{
				Nodes[objectID].setHeight(h);
			}
		}
		
		public function setWidth(objectID, w):void
		{
			if (Nodes[objectID] != null)
			{
				Nodes[objectID].setWidth(w);
			}
		}
		
		public function getHeight(objectID):int
		{
			if (Nodes[objectID] != null)
			{
				return Nodes[objectID].getHeight();
			}
			else
			{
				return -1;
			}
		}
		
		public function getWidth(objectID):int
		{
			if (Nodes[objectID] != null)
			{
				return Nodes[objectID].getWidth();
			}
			else
			{
				return -1;
			}
		}
	
		
		public function backgroundColor(objectID):uint
		{
			if (Nodes[objectID] != null)
			{
				return Nodes[objectID].backgroundColor;
			}
			else
			{
				return 0;
			}
		}
		
		public function foregroundColor(objectID):uint
		{
			if (Nodes[objectID] != null)
			{
				return Nodes[objectID].foregroundColor;
			}
			else
			{
				return 0;
			}
		}
		
		public function addCircleObject(objectID, objectLabel):void
		{
			if (Nodes[objectID] != null)
			{
				throw new Error("addCircleObject:Object with same ID already Exists!");
			}
			var newNode:AnimatedCircle = new AnimatedCircle(objectID, objectLabel);
			Nodes[objectID] = newNode;
			addChild(newNode);
		}
		
		public function addHighlightCircleObject(objectID, objectColor, radius = 20):void
		{
			if (Nodes[objectID] != null)
			{
				throw new Error("addHighlightCircleObject: Object Already Exists!");
			}
			var newNode:HighlightCircle = new HighlightCircle(objectID, objectColor, radius)
			Nodes[objectID] = newNode;
			addChild(newNode);
			
		}
		
		
		public function addLabelObject(objectID, objectLabel, centering:Boolean = true):void
		{
			if (Nodes[objectID] != null)
			{
				throw new Error("addLabelObject: Object Already Exists!");
			}

			var newLabel:AnimatedLabel = new AnimatedLabel(objectID, objectLabel, centering);
			Nodes[objectID] = newLabel;
			addChild(newLabel);
		}
		
		public function removeObject(ObjectID):void
		{
			var OldObject:AnimatedObject = Nodes[ObjectID];
			if (OldObject.addedToScene)
			{
				removeChild(OldObject);
			}
			if (ObjectID == Nodes.length - 1)
			{
				Nodes.pop();
			}
			else
			{
				Nodes[ObjectID] = null;
			}
		}
		
		public function setText(nodeID, newText, index = 0)
		{
			Nodes[nodeID].setText(newText, index);			
		}
		
		public function setTextColor(nodeID, newColor, index = 0)
		{
			Nodes[nodeID].setTextColor(newColor, index);			
		}
		
		public function getTextColor(nodeID, index = 0) :uint
		{
			return Nodes[nodeID].getTextColor(index);			
		}
		
		public function getText(nodeID:int, index:int = 0) : String
		{
			return Nodes[nodeID].getText(index);			
		}
		
		public function setAlpha(nodeID, alphaVal) : void
		{
			if (Nodes[nodeID] != null)
			{
				Nodes[nodeID].setAlpha(alphaVal);
			}
		}

		public function getAlpha(nodeID) : Number
		{
			if (Nodes[nodeID] != null)
			{
				return Nodes[nodeID].getAlpha();
			}
			else
			{
				return -1;
			}
		}
		
		public function clearAllObjects():void
		{
			for (var i:int = 0; i < Nodes.length; i++)
			{
				if (Nodes[i] != null && Nodes[i].addedToScene)
				{
					removeChild(Nodes[i]);
				}
			}
			Nodes = new Array();
			for (i = 0; i < Edges.length; i++)
			{
				if (Edges[i] != null)
				{
					for (var j:int = 0; j < Edges[i].length; j++)
					{
						if (Edges[i][j] != null && Edges[i][j].addedToScene)
						{
						      removeChild(Edges[i][j].graphic);
						}
						Edges[i][j] = null;							
					}
					Edges[i] = null;						
				}
			}
			Nodes = new Array();
			Edges = new Array();
			BackEdges = new Array();
		}
		
		
		public function getObject(nodeID)
		{
			return Nodes[nodeID];
		}
		
		
		public function getNodeX(nodeID:int):Number
		{
			if (Nodes[nodeID] == null)
			{
				throw new Error("getting x position of an object that does not exit");
			}	
			return Nodes[nodeID].x;
		}
		
		public function getNodeY(nodeID:int):Number
		{
			if (Nodes[nodeID] == null)
			{
				throw new Error("getting y position of an object that does not exit");
			}	
			return Nodes[nodeID].y;
		}
		
		public function setNodePosition(nodeID, newX:Number, newY:Number)
		{
			if (Nodes[nodeID] == null)
			{
				// TODO:  Error here?
				return;
			}
			Nodes[nodeID].x = newX;
			Nodes[nodeID].y = newY;
			Nodes[nodeID].actualX = newX;
			Nodes[nodeID].actualY = newY;
			var i:int;
			var len:int;
			if (Edges[nodeID] != null)
			{
				len = Edges[nodeID].length;
				for (i = 0; i < len; i++)
				{
					if (Edges[nodeID][i] != null)
					{
						Edges[nodeID][i].Dirty = true;
					}
				}
			}
			if (BackEdges[nodeID] != null)
			{
				len = BackEdges[nodeID].length;
				for (i = 0; i < len; i++)
				{
					if (BackEdges[nodeID][i] != null)
					{
						BackEdges[nodeID][i].Dirty = true;
					}
				}
			}
		}
		
		
		
		public function getEdgeColor(fromID, toID)
		{
			if (Edges[fromID] != null)
			{
				var len:int = Edges[fromID].length;
				for (var i:int = len - 1; i >= 0; i--)
				{
					if (Edges[fromID][i] != null && Edges[fromID][i].Node2 == Nodes[toID])
					{
						return Edges[fromID][i].color();;		
					}
				}
			}			
			
		}
		
		public function setEdgeColor(fromID, toID, color) :uint
		{
			var oldColor:uint = 0x000000;
			if (Edges[fromID] != null)
			{
				var len:int = Edges[fromID].length;
				for (var i:int = len - 1; i >= 0; i--)
				{
					if (Edges[fromID][i] != null && Edges[fromID][i].Node2 == Nodes[toID])
					{
						oldColor = Edges[fromID][i].color();
						Edges[fromID][i].setColor(color);		
					}
				}
			}	
			return oldColor;
		}		
		
		public function setEdgeHighlight(fromID, toID, val) : Boolean
		{
			var oldHighlight = false;
			if (Edges[fromID] != null)
			{
				var len:int = Edges[fromID].length;
				for (var i:int = len - 1; i >= 0; i--)
				{
					if (Edges[fromID][i] != null && Edges[fromID][i].Node2 == Nodes[toID])
					{
						oldHighlight = Edges[fromID][i].highlighted;
						Edges[fromID][i].setHighlight(val);		
					}
				}
			}
			return oldHighlight;
		}
		
		public function setHighlight(nodeID, val)
		{
			if (this.Nodes[nodeID] == null)
			{
				// TODO:  Error here?
				return;
			}
			this.Nodes[nodeID].setHighlight(val);
		}
		
		public function nodeX(nodeID):Number
		{
			if (Nodes[nodeID] == null)
			{
				// TODO:  Error here?
				return 0;
			}
			return Nodes[nodeID].actualX;
		}
		public function nodeY(nodeID):Number
		{
			if (Nodes[nodeID] == null)
			{
				// TODO:  Error here?
				return 0;
			}
			return Nodes[nodeID].actualY;
		}
		public function objectLabel(nodeID):String
		{
			return Nodes[nodeID].getText();
		}
		public function moveNode(nodeID, deltaX, deltaY)
		{
			if (Nodes[nodeID] == null)
			{
				// TODO:  Error here?
				return;
			}
			setNodePosition(nodeID, Nodes[nodeID].x + deltaX, Nodes[nodeID].y + deltaY);
		}
		
		
		public function update()
		{
			updateEdges();
			updateHighlight();
			for (var i:int = Nodes.length - 1; i >= 0; i--)
			{
				if (Nodes[i] != null)
				{
					Nodes[i].draw();					
				}
			}
			
		}
		
		function updateHighlight()
		{
			frameNum += 1;
			if (frameNum > 10000)
				frameNum = 0;
			for (var i:int = Nodes.length - 1; i >= 0; i--)
			{
				if (Nodes[i] != null)
				{
					Nodes[i].pulseHighlight(frameNum);					
				}
			}
			
		}
		
		
		function updateEdges()
		{
			var len1 : int = Edges.length;
			var len2 : int;
			var i : int;
			var j : int;
			for (i = 0; i < len1; i++)
			{
				if (Edges[i] != null)
				{
					len2 = Edges[i].length;
					for (j = 0; j < len2; j++)
					{
						if (Edges[i][j] != null)
						{
							Edges[i][j].Redraw();
							Edges[i][j].pulseHighlight(frameNum);
						}
					}
				}
			}
		}
	}
}