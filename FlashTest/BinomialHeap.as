package 
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.display.DisplayObjectContainer;
	import fl.controls.Button;
	import fl.controls.TextInput;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import fl.events.ComponentEvent;
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	import flash.events.Event;



	public class BinomialHeap extends AlgorithmAnimation
	{

		
		var enterFieldInsert:TextInput;
		var insertButton:Button;
		var removeSmallestButton:Button;
		var clearButton:Button;
		
		var logicalRepButton:RadioButton;
		var internalRepButton:RadioButton;
		var representationGroup:RadioButtonGroup;

		
		
		const LINK_COLOR = 0x007700;
		const HIGHLIGHT_CIRCLE_COLOR = 0x007700;
		const MERGE_SEPARATING_LINE_COLOR = 0x0000FF;
		const FOREGROUND_COLOR = 0x007700;
		const BACKGROUND_COLOR = 0xEEFFEE;
		const DEGREE_OFFSET_X = -20;
		const DEGREE_OFFSET_Y = -20;
		
		static const DELETE_LAB_X = 30;
		static const DELETE_LAB_Y = 50;
		
		
		static const NODE_WIDTH = 60;
		static const NODE_HEIGHT = 70
		
		static const STARTING_X = 70;
		static const STARTING_Y = 120;
		
		static const INSERT_X = 30;
		static const INSERT_Y = 50

		var treeRoot:BinomialNode;
		var secondaryTreeRoot:BinomialNode;
		
		var nextIndex:int  = 0;

		var currentLayer:int = 1;
		
		// Object IDs for labels, so we don't keep creating new ones ...
	    var swapLabel1:int;
	 	var swapLabel2:int;
		var swapLabel3:int;
		var swapLabel4:int;
		
		var descriptLabel1:int;
		var descriptLabel2:int;
		
		public function BinomialHeap(am)
		{
			super(am);

			commands = new Array();

			enterFieldInsert = addTextInput(2,2,100,20,true);
			insertButton = new Button();
			insertButton.label = "Insert";
			insertButton.x = 105;			
			addChild(insertButton);
			
			removeSmallestButton = new Button();
			removeSmallestButton.label = "Remove Smallest";
			removeSmallestButton.x = 210;
			addChild(removeSmallestButton);
			
			clearButton = new Button();
			clearButton.label = "Clear";
			clearButton.x = 310;
			addChild(clearButton);
			
			
			representationGroup = new RadioButtonGroup("GraphRepresentation");

			logicalRepButton = new RadioButton();
			logicalRepButton.x = 725;
			logicalRepButton.label = "Logical Representation"
			logicalRepButton.width = 250;
			logicalRepButton.selected = true;
			logicalRepButton.addEventListener(Event.CHANGE, representationChangedHandler);
			logicalRepButton.group = representationGroup;
			addChild(logicalRepButton);
			
			internalRepButton = new RadioButton();
			internalRepButton.x = 725;
			internalRepButton.y = 20;
			internalRepButton.label = "Internal Representation";
			internalRepButton.width = 250;
			internalRepButton.addEventListener(Event.CHANGE, representationChangedHandler);
			internalRepButton.group = representationGroup;
			addChild(internalRepButton);

			
			insertButton.addEventListener(MouseEvent.MOUSE_DOWN, insertCallback);
			enterFieldInsert.addEventListener(ComponentEvent.ENTER, insertCallback);

			clearButton.addEventListener(MouseEvent.MOUSE_DOWN, clearCallback);
			removeSmallestButton.addEventListener(MouseEvent.MOUSE_DOWN, removeSmallestCallback);

			treeRoot = null;
			animationManager.setAllLayers(0,currentLayer);


		}
		
		
		private function representationChangedHandler(event:Event):void 
		{
			if ( event.currentTarget.selected )
			{
				
				if (event.currentTarget == logicalRepButton)
				{
					animationManager.setAllLayers(0,1);
					currentLayer = 1;
				}
				else if (event.currentTarget == internalRepButton)
				{
					animationManager.setAllLayers(0,2);
					currentLayer = 2;
				}
			}
		}
		
		
		
		
		function setPositions(tree:BinomialNode, xPosition, yPosition) : Number
		{
			if (tree != null)
			{
				if (tree.degree == 0)
				{
					tree.x = xPosition;
					tree.y = yPosition;
					return setPositions(tree.rightSib, xPosition + NODE_WIDTH, yPosition);
				}
				else if (tree.degree == 1)
				{
					tree.x = xPosition;
					tree.y = yPosition;
					setPositions(tree.leftChild, xPosition, yPosition + NODE_HEIGHT);
					return setPositions(tree.rightSib, xPosition + NODE_WIDTH, yPosition);					
				}
				else
				{
					var treeWidth = Math.pow(2, tree.degree - 1);
					tree.x = xPosition + (treeWidth - 1) * NODE_WIDTH;
					tree.y = yPosition;
					setPositions(tree.leftChild, xPosition, yPosition + NODE_HEIGHT);
					return setPositions(tree.rightSib, xPosition + treeWidth * NODE_WIDTH, yPosition);
				}
			}
			return xPosition;
		}
		
		function moveTree(tree:BinomialNode)
		{
			if (tree != null)
			{
				cmd("Move", tree.graphicID, tree.x, tree.y);
				cmd("Move", tree.internalGraphicID, tree.x, tree.y);
				cmd("Move", tree.degreeID, tree.x  + DEGREE_OFFSET_X, tree.y + DEGREE_OFFSET_Y);

				moveTree(tree.leftChild);
				moveTree(tree.rightSib);
			}
		}
		

		function insertCallback(event)
		{
			var insertedValue:String;

			insertedValue = normalizeNumber(enterFieldInsert.text, 4);
			if (insertedValue != "")
			{
				enterFieldInsert.text = "";
				implementAction(insertElement,insertedValue);
			}
		}
		
		function clearCallback(event)
		{
			clear();
		}
		
		function clear()
		{
			commands = new Array();
			
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			animationManager.clearHistory();
			actionHistory = new Array();
		}
	
		
		override function reset()
		{
			treeRoot = null;
			nextIndex = 0;
		}
		
		function removeSmallestCallback(event)
		{
			implementAction(removeSmallest,"");
		}
		
		
		
		function removeSmallest(dummy)
		{
			commands = new Array();
			
			if (treeRoot != null)
			{
          
        		var  tmp:BinomialNode;
       			var prev:BinomialNode;
        		var smallest:BinomialNode = treeRoot;

				cmd("SetHighlight", smallest.graphicID, 1);
				cmd("SetHighlight", smallest.internalGraphicID, 1);
				
        		for (tmp = treeRoot.rightSib; tmp != null; tmp = tmp.rightSib) 
				{
            		cmd("SetHighlight", tmp.graphicID, 1);
            		cmd("SetHighlight", tmp.internalGraphicID, 1);
					cmd("Step");
		            if (tmp.data < smallest.data) 
					{
						cmd("SetHighlight", smallest.graphicID, 0);
						cmd("SetHighlight", smallest.internalGraphicID, 0);
						smallest = tmp;
            		} 
					else 
					{
						cmd("SetHighlight", tmp.graphicID, 0);
						cmd("SetHighlight", tmp.internalGraphicID, 0);
            		}
       			}

        		if (smallest == treeRoot) {
            		treeRoot = treeRoot.rightSib;
					prev = null;
       		 	} 
				else 
				{
            		for (prev = treeRoot; prev.rightSib != smallest; prev = prev.rightSib) ;
           			prev.rightSib = prev.rightSib.rightSib;

        		}
				var moveLabel:int = nextIndex++;
				cmd("SetText", smallest.graphicID, "");
				cmd("SetText", smallest.internalGraphicID, "");
				cmd("CreateLabel", moveLabel, smallest.data, smallest.x, smallest.y);
				cmd("Move", moveLabel, DELETE_LAB_X, DELETE_LAB_Y);
				cmd("Step");
				if (prev != null && prev.rightSib != null)
					{
						cmd("Connect", prev.internalGraphicID, 
									   prev.rightSib.internalGraphicID,
									   FOREGROUND_COLOR,
									   0, // Curve
									   1, // Directed
									   ""); // Label
						
					}
				cmd("Delete", smallest.graphicID);
				cmd("Delete", smallest.internalGraphicID);
				cmd("Delete", smallest.degreeID);
				
		        secondaryTreeRoot = reverse(smallest.leftChild);
       			for (tmp = secondaryTreeRoot; tmp != null; tmp = tmp.rightSib)
            		tmp.parent = null;
		        merge();
				cmd("Delete", moveLabel);
			}
			return commands;
		}
		
		function reverse(tree:BinomialNode) : BinomialNode
		{
			var newTree:BinomialNode = null;
        	var tmp:BinomialNode;
        	while (tree != null) 
			{
				if (tree.rightSib != null)
				{
					cmd("Disconnect", tree.internalGraphicID, tree.rightSib.internalGraphicID);
					cmd("Connect", tree.rightSib.internalGraphicID, 
								   tree.internalGraphicID,
								   FOREGROUND_COLOR,
								   0, // Curve
								   1, // Directed
								   ""); // Label
				}
            	tmp = tree;
            	tree = tree.rightSib;
            	tmp.rightSib = newTree;
            	tmp.parent=null;
            	newTree = tmp;
        	}
        	return newTree;
		}
		
		
		function insertElement(insertedValue)
		{
			commands = new Array();
			
			var insertNode:BinomialNode = new BinomialNode(insertedValue, nextIndex++,  INSERT_X, INSERT_Y);
			insertNode.internalGraphicID = nextIndex++;
			insertNode.degreeID= nextIndex++;
			cmd("CreateCircle", insertNode.graphicID, insertedValue, INSERT_X, INSERT_Y);
			cmd("SetForegroundColor", insertNode.graphicID, FOREGROUND_COLOR);
			cmd("SetBackgroundColor", insertNode.graphicID, BACKGROUND_COLOR);
			cmd("SetLayer", insertNode.graphicID, 1);
			cmd("CreateCircle", insertNode.internalGraphicID, insertedValue, INSERT_X, INSERT_Y);
			cmd("SetForegroundColor", insertNode.internalGraphicID, FOREGROUND_COLOR);
			cmd("SetBackgroundColor", insertNode.internalGraphicID, BACKGROUND_COLOR);
			cmd("SetLayer", insertNode.internalGraphicID, 2);
			cmd("CreateLabel", insertNode.degreeID, insertNode.degree, insertNode.x  + DEGREE_OFFSET_X, insertNode.y + DEGREE_OFFSET_Y);
			cmd("SetTextColor", insertNode.degreeID, 0x0000FF);
			cmd("SetLayer", insertNode.degreeID, 2);
			cmd("Step");
		
			if (treeRoot == null)
			{
				treeRoot = insertNode;
				setPositions(treeRoot, STARTING_X, STARTING_Y);
				moveTree(treeRoot);
			}
			else
			{
				secondaryTreeRoot = insertNode;
				merge();				
			}
			
			return commands;
		}
	
		
		function merge()
		{
			if (treeRoot != null)
			{
				var leftSize:Number = setPositions(treeRoot, STARTING_X, STARTING_Y);
				setPositions(secondaryTreeRoot, leftSize + NODE_WIDTH, STARTING_Y);
				moveTree(secondaryTreeRoot);
				moveTree(treeRoot);
				var lineID:int = nextIndex++;
				cmd("CreateRectangle", lineID, "", 0, 200, leftSize, 50,"left","top");
				cmd("SetForegroundColor", lineID, MERGE_SEPARATING_LINE_COLOR);
				cmd("SetLayer", lineID, 0);
				cmd("Step");
			}
			else
			{
				treeRoot = secondaryTreeRoot;
				secondaryTreeRoot = null;
				setPositions(treeRoot,  NODE_WIDTH, STARTING_Y);
				moveTree(treeRoot);
				return;
			}
			while (secondaryTreeRoot != null)
			{
				var tmp : BinomialNode = secondaryTreeRoot;
				secondaryTreeRoot = secondaryTreeRoot.rightSib;
				if (secondaryTreeRoot != null)
				{
					cmd("Disconnect", tmp.internalGraphicID, secondaryTreeRoot.internalGraphicID);
				}
				if (tmp.degree <= treeRoot.degree)
				{
					tmp.rightSib = treeRoot;
					treeRoot = tmp;
					cmd("Connect", treeRoot.internalGraphicID, 
								   treeRoot.rightSib.internalGraphicID,
								   FOREGROUND_COLOR,
								   0, // Curve
								   1, // Directed
								   ""); // Label
				}
				else
				{
					var tmp2 : BinomialNode = treeRoot;
					while (tmp2.rightSib != null && tmp2.rightSib.degree < tmp.degree)
					{
						tmp2 = tmp2. rightSib;
					}
					if (tmp2.rightSib != null)
					{
						cmd("Disconnect", tmp2.internalGraphicID, tmp2.rightSib.internalGraphicID);
						cmd("Connect", tmp.internalGraphicID, 
								   tmp2.rightSib.internalGraphicID,
								   FOREGROUND_COLOR,
								   0, // Curve
								   1, // Directed
								   ""); // Label
					}
					tmp.rightSib= tmp2.rightSib;
					tmp2.rightSib = tmp;
					cmd("Connect", tmp2.internalGraphicID, 
								   tmp.internalGraphicID,
								   FOREGROUND_COLOR,
								   0, // Curve
								   1, // Directed
								   ""); // Label
				}
				leftSize = setPositions(treeRoot, STARTING_X, STARTING_Y);
				setPositions(secondaryTreeRoot, leftSize + NODE_WIDTH, STARTING_Y);
				moveTree(secondaryTreeRoot);
				moveTree(treeRoot);
				cmd("Move", lineID, leftSize, 50);
				cmd("Step");
			}
			cmd("Delete", lineID);
			combineNodes();
		}
	
		
		function combineNodes()
		{
			var tmp:BinomialNode;
			var tmp2:BinomialNode;
	        while ((treeRoot != null && treeRoot.rightSib != null && treeRoot.degree == treeRoot.rightSib.degree) &&
               (treeRoot.rightSib.rightSib == null || treeRoot.rightSib.degree != treeRoot.rightSib.rightSib.degree))
        	{
				cmd("Disconnect", treeRoot.internalGraphicID, treeRoot.rightSib.internalGraphicID);
				if (treeRoot.rightSib.rightSib != null)
				{
					cmd("Disconnect", treeRoot.rightSib.internalGraphicID, treeRoot.rightSib.rightSib.internalGraphicID);					
				}
				if (treeRoot.data < treeRoot.rightSib.data) 
				{
					tmp = treeRoot.rightSib;
					treeRoot.rightSib = tmp.rightSib;
					tmp.rightSib = treeRoot.leftChild;
					treeRoot.leftChild = tmp;
					tmp.parent = treeRoot;
				} 
				else 
				{
					tmp = treeRoot;
					treeRoot = treeRoot.rightSib;
					tmp.rightSib = treeRoot.leftChild;
					treeRoot.leftChild = tmp;
					tmp.parent = treeRoot;
				}
				cmd("Connect", treeRoot.graphicID, 
							   treeRoot.leftChild.graphicID,
							   FOREGROUND_COLOR,
							   0, // Curve
							   0, // Directed
							   ""); // Label
					
									
				cmd("Connect", treeRoot.internalGraphicID, 
						       treeRoot.leftChild.internalGraphicID,
						       FOREGROUND_COLOR,
						       0.15, // Curve
						       1, // Directed
						       ""); // Label
				
				cmd("Connect",  treeRoot.leftChild.internalGraphicID, 
						   treeRoot.internalGraphicID,
						   FOREGROUND_COLOR,
						   0, // Curve
						   1, // Directed
						   ""); // Label					
				if (treeRoot.leftChild.rightSib != null)
				{
					cmd("Disconnect", treeRoot.internalGraphicID, treeRoot.leftChild.rightSib.internalGraphicID);
					cmd("Connect", treeRoot.leftChild.internalGraphicID, 
						   treeRoot.leftChild.rightSib.internalGraphicID,
						   FOREGROUND_COLOR,
						   0, // Curve
						   1, // Directed
						   ""); // Label
				}
				if (treeRoot.rightSib != null)
				{
					cmd("Connect", treeRoot.internalGraphicID, 
						   treeRoot.rightSib.internalGraphicID,
						   FOREGROUND_COLOR,
						   0, // Curve
						   1, // Directed
						   ""); // Label
				}
			
				treeRoot.degree++;
				
				cmd("SetText", treeRoot.degreeID, treeRoot.degree);
				

				setPositions(treeRoot, STARTING_X, STARTING_Y);
				moveTree(treeRoot);	
				cmd("Step");
			}
		
			tmp2 = treeRoot;
			while (tmp2 != null && tmp2.rightSib != null && tmp2.rightSib.rightSib != null) 
			{
				if (tmp2.rightSib.degree != tmp2.rightSib.rightSib.degree) 
				{
					tmp2 = tmp2.rightSib;
				} else if ((tmp2.rightSib.rightSib.rightSib != null) &&
						   (tmp2.rightSib.rightSib.degree == tmp2.rightSib.rightSib.rightSib.degree)) 
				{
					tmp2 = tmp2.rightSib;
				} 
				else 
				{
					cmd("Disconnect", tmp2.rightSib.internalGraphicID,  tmp2.rightSib.rightSib.internalGraphicID);
					cmd("Disconnect", tmp2.internalGraphicID,  tmp2.rightSib.internalGraphicID);
					if (tmp2.rightSib.rightSib.rightSib != null)
					{
						cmd("Disconnect", tmp2.rightSib.rightSib.internalGraphicID,  tmp2.rightSib.rightSib.rightSib.internalGraphicID);
					}

					var tempRoot:BinomialNode;
					if (tmp2.rightSib.data < tmp2.rightSib.rightSib.data) 
					{
						tmp = tmp2.rightSib.rightSib;
						tmp2.rightSib.rightSib = tmp.rightSib;
						
						tmp.rightSib = tmp2.rightSib.leftChild;
						tmp2.rightSib.leftChild = tmp;
						tmp.parent = tmp2.rightSib;
						tmp2.rightSib.degree++;
						cmd("SetText", tmp2.rightSib.degreeID, tmp2.rightSib.degree);
						tempRoot = tmp2.rightSib;

					}
					else
					{
						tmp = tmp2.rightSib;
						tmp2.rightSib = tmp2.rightSib.rightSib;
						tmp.rightSib = tmp2.rightSib.leftChild;
						tmp2.rightSib.leftChild = tmp;
						tmp.parent = tmp2.rightSib;
						tmp2.rightSib.degree++;
						cmd("SetText", tmp2.rightSib.degreeID, tmp2.rightSib.degree);
						tempRoot = tmp2.rightSib;
					}
					cmd("Connect", tempRoot.graphicID, 
						   tempRoot.leftChild.graphicID,
						   FOREGROUND_COLOR,
						   0, // Curve
						   0, // Directed
						   ""); // Label
					
					cmd("Connect", tempRoot.internalGraphicID, 
						   tempRoot.leftChild.internalGraphicID,
						   FOREGROUND_COLOR,
						   0.15, // Curve
						   1, // Directed
						   ""); // Label
					
					cmd("Connect",  tempRoot.leftChild.internalGraphicID, 
						    tempRoot.internalGraphicID,
						   FOREGROUND_COLOR,
						   0, // Curve
						   1, // Directed
						   ""); // Label
					
					cmd("Connect",  tmp2.internalGraphicID, 
						    tempRoot.internalGraphicID,
						   FOREGROUND_COLOR,
						   0, // Curve
						   1, // Directed
						   ""); // Label
					
					if (tempRoot.leftChild.rightSib != null)
					{
						cmd("Disconnect",tempRoot.internalGraphicID, tempRoot.leftChild.rightSib.internalGraphicID);
						cmd("Connect",tempRoot.leftChild.internalGraphicID, 
							          tempRoot.leftChild.rightSib.internalGraphicID,
									   FOREGROUND_COLOR,
						               0, // Curve
						               1, // Directed
						               ""); // Label);
					}
					if (tempRoot.rightSib != null)
					{
							cmd("Connect",tempRoot.internalGraphicID, 
							          tempRoot.rightSib.internalGraphicID,
									   FOREGROUND_COLOR,
						               0, // Curve
						               1, // Directed
						               ""); // Label);					
					}
					
					

					
					setPositions(treeRoot, STARTING_X, STARTING_Y);
					moveTree(treeRoot);	
					cmd("Step");
				}
			}
		}
		
	
		override function enableUI(event:AnimationStateEvent):void
		{
			clearButton.enabled = true;
			insertButton.enabled = true;
			removeSmallestButton.enabled = true;
			enterFieldInsert.enabled = true;
			enterFieldInsert.addEventListener(ComponentEvent.ENTER, insertCallback);
		}
		
		override function disableUI(event:AnimationStateEvent):void
		{
			clearButton.enabled = false;
			insertButton.enabled = false;
			removeSmallestButton.enabled = false;
			enterFieldInsert.enabled = false;
			enterFieldInsert.removeEventListener(ComponentEvent.ENTER, insertCallback);
		}
	}
}