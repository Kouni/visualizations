package {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.display.DisplayObjectContainer;
	import fl.controls.Button;
	import fl.controls.TextInput;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import fl.events.ComponentEvent;



	public class BST extends AlgorithmAnimation {
		
		// Input Controls
		var enterFieldInsert:TextInput;
		var enterFieldDelete:TextInput;
		var enterFieldFind:TextInput;
		var insertButton:Button;
		var deleteButton:Button;
		var findButton:Button;
		var printButton:Button;
		
		const FIRST_PRINT_POS_X:int = 50;
		const FIRST_PRINT_POS_Y:int = 500;
		const PRINT_VERTICAL_GAP:int = 20;
		const PRINT_MAX:int = 990;
		const PRINT_HORIZONTAL_GAP = 50;
		
		// Input Controls

		var treeRoot:BSTNode;
		var nextIndex:int  = 0;
		

		// Size constants

		static const widthDelta:int  = 50;
		static const heightDelta:int = 50;
		static const startingX:int = 500;
		static const startingY:int = 50;
		
		
		// For printing (a bit hacky ...)
		var xPosOfNextLabel:int;
		var yPosOfNextLabel:int;
		
		// For resuing highlight ID (a bit hacky ...)
		var highlightID:int;

		
		const LINK_COLOR = 0x007700;
		const HIGHLIGHT_CIRCLE_COLOR = 0x007700;
		const FOREGROUND_COLOR = 0x007700;
		const BACKGROUND_COLOR = 0xEEFFEE;
		const PRINT_COLOR = FOREGROUND_COLOR;
		
		public function BST(am)
		{
			super(am);
			
			commands = new Array();
			
			enterFieldInsert = addTextInput(2,2,100,20);
			insertButton = new Button();
			insertButton.label = "Insert";
			insertButton.x = 105;			
			addChild(insertButton);
					
			enterFieldDelete = addTextInput(220,2,100,20);
			deleteButton = new Button();
			deleteButton.label = "Delete";
			deleteButton.x = 323;			
			addChild(deleteButton);
			
			enterFieldFind = addTextInput(450,2,100,20);
			findButton = new Button();
			findButton.label = "Find";
			findButton.x = 553;			
			addChild(findButton);
			
			printButton = new Button();
			printButton.label = "Print";
			printButton.x = 668;			
			addChild(printButton);
			
			insertButton.addEventListener(MouseEvent.MOUSE_DOWN, insertCallback);
			deleteButton.addEventListener(MouseEvent.MOUSE_DOWN, deleteCallback);
			findButton.addEventListener(MouseEvent.MOUSE_DOWN, findCallback);
			printButton.addEventListener(MouseEvent.MOUSE_DOWN, printCallback);
			enterFieldDelete.addEventListener(ComponentEvent.ENTER, deleteCallback);
			enterFieldInsert.addEventListener(ComponentEvent.ENTER, insertCallback);			
			enterFieldFind.addEventListener(ComponentEvent.ENTER, findCallback);						
			nextIndex = 1;
			
			
			cmd("CreateLabel", 0, "", 20, 50, 0);
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			animationManager.clearHistory();
			commands = new Array();			
		}
		
		override function reset()
		{
			nextIndex = 1;
			treeRoot = null;
		}
		
		
		override function enableUI(event:AnimationStateEvent):void
		{
			deleteButton.enabled = true;
			insertButton.enabled = true;
			findButton.enabled = true;
			printButton.enabled = true;
			enterFieldInsert.enabled = true;
			enterFieldDelete.enabled = true;
			enterFieldFind.enabled =true;
			enterFieldDelete.addEventListener(ComponentEvent.ENTER, deleteCallback);
			enterFieldInsert.addEventListener(ComponentEvent.ENTER, insertCallback);
			enterFieldFind.addEventListener(ComponentEvent.ENTER, findCallback);
			
			
		}
		override function disableUI(event:AnimationStateEvent):void
		{
			insertButton.enabled = false;
			deleteButton.enabled = false;
			findButton.enabled = false;
		    printButton.enabled = false;
			enterFieldDelete.removeEventListener(ComponentEvent.ENTER, deleteCallback);
			enterFieldInsert.removeEventListener(ComponentEvent.ENTER, insertCallback);
			enterFieldFind.removeEventListener(ComponentEvent.ENTER, findCallback);
			enterFieldInsert.enabled = false;
			enterFieldDelete.enabled = false;
			enterFieldFind.enabled = false;
			
		}
		
		
		function insertCallback(event):void
		{
			var insertedValue:String;
			insertedValue = normalizeNumber(enterFieldInsert.text, 4);
			if (insertedValue != "")
			{
				enterFieldInsert.text = "";
				implementAction(insertElement,insertedValue);
			}
		}
		
		function deleteCallback(event):void
		{
			var deletedValue:String;
			if (deletedValue != "")
			{
				deletedValue = normalizeNumber(enterFieldDelete.text, 4);
				enterFieldDelete.text = "";
				implementAction(deleteElement,deletedValue);		
			}
		}
		
				
		function printCallback(event):void
		{
			implementAction(printTree,"");						
		}
		
		function printTree(unused:String)
		{
			commands = new Array();
			
			if (treeRoot != null)
			{
				highlightID = nextIndex++;
				var firstLabel:int = nextIndex;
		   		cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_CIRCLE_COLOR, treeRoot.x, treeRoot.y);
				xPosOfNextLabel = FIRST_PRINT_POS_X;
				yPosOfNextLabel = FIRST_PRINT_POS_Y;
				printTreeRec(treeRoot);
				cmd("Delete", highlightID);
				cmd("Step")

				for (var i:int = firstLabel; i < nextIndex; i++)
				{
					cmd("Delete", i);
				}
				nextIndex = highlightID;  /// Reuse objects.  Not necessary.
			}
			return commands;
		}
		
		function printTreeRec(tree) : void
		{
			cmd("Step");
			if (tree.left != null)
			{
				cmd("Move", highlightID, tree.left.x, tree.left.y);
				printTreeRec(tree.left);
				cmd("Move", highlightID, tree.x, tree.y);				
				cmd("Step");
			}
			var nextLabelID:int = nextIndex++;
			cmd("CreateLabel", nextLabelID, tree.data, tree.x, tree.y);
			cmd("SetForegroundColor", nextLabelID, PRINT_COLOR);
			cmd("Move", nextLabelID, xPosOfNextLabel, yPosOfNextLabel);
			cmd("Step");

			xPosOfNextLabel +=  PRINT_HORIZONTAL_GAP;
			if (xPosOfNextLabel > PRINT_MAX)
			{
				xPosOfNextLabel = FIRST_PRINT_POS_X;
				yPosOfNextLabel += PRINT_VERTICAL_GAP;
				
			}
			if (tree.right != null)
			{
				cmd("Move", highlightID, tree.right.x, tree.right.y);
				printTreeRec(tree.right);
				cmd("Move", highlightID, tree.x, tree.y);	
				cmd("Step");
			}
			return;
		}
		
		function findCallback(event):void
		{
			var findValue:String;
			findValue = normalizeNumber(enterFieldFind.text, 4);
			enterFieldFind.text = "";
			implementAction(findElement,findValue);						
		}
		
		function findElement(findValue:String):Array
		{
			commands = new Array();
			
            highlightID = nextIndex++;

			doFind(treeRoot, findValue);
			
			
			return commands;
		}
				
				
		function doFind(tree:BSTNode, value:String)
		{
		    cmd("SetText", 0, "Searching for "+value);
			if (tree != null)
			{
				cmd("SetHighlight", tree.graphicID, 1);
				if (tree.data == value)
				{
					cmd("SetText", 0, "Searching for "+value+" : " + value + " = " + value + " (Element found!)");
					cmd("Step");					
			     	cmd("SetText", 0, "Found:"+value);
					cmd("SetHighlight", tree.graphicID, 0);
				}
				else
				{
					if (tree.data > value)
					{
						cmd("SetText", 0, "Searching for "+value+" : " + value + " < " + tree.data + " (look to left subtree)");
						cmd("Step");
						cmd("SetHighlight", tree.graphicID, 0);
						if (tree.left!= null)
						{
							cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_CIRCLE_COLOR, tree.x, tree.y);
							cmd("Move", highlightID, tree.left.x, tree.left.y);
							cmd("Step");
							cmd("Delete", highlightID);
						}
						doFind(tree.left, value);
					}
					else
					{
						cmd("SetText", 0, "Searching for "+value+" : " + value + " > " + tree.data + " (look to right subtree)");					
						cmd("Step");
						cmd("SetHighlight", tree.graphicID, 0);
						if (tree.right!= null)
						{
							cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_CIRCLE_COLOR, tree.x, tree.y);
							cmd("Move", highlightID, tree.right.x, tree.right.y);
							cmd("Step");
							cmd("Delete", highlightID);				
						}
						doFind(tree.right, value);						
					}
					
				}
				
			}
			else
			{
				cmd("SetText", 0, "Searching for "+value+" : " + "< Empty Tree > (Element not found)");				
				cmd("Step");					
				cmd("SetText", 0, "Searching for "+value+" : " + " (Element not found)");					
			}
		}
		
		function insertElement(insertedValue:String):Array
		{
			commands = new Array();	
		    cmd("SetText", 0, "Inserting "+insertedValue);
			highlightID = nextIndex++;

			if (treeRoot == null)
			{
                cmd("CreateCircle", nextIndex, insertedValue,  startingX, startingY);
				cmd("SetForegroundColor", nextIndex, FOREGROUND_COLOR);
				cmd("SetBackgroundColor", nextIndex, BACKGROUND_COLOR);
				cmd("Step");				
				treeRoot = new BSTNode(insertedValue, nextIndex, startingX, startingY)
				nextIndex += 1;
			}
			else
			{
				cmd("CreateCircle", nextIndex, insertedValue, 100, 100);
				cmd("SetForegroundColor", nextIndex, FOREGROUND_COLOR);
				cmd("SetBackgroundColor", nextIndex, BACKGROUND_COLOR);
				cmd("Step");				
				var insertElem:BSTNode = new BSTNode(insertedValue, nextIndex, 100, 100)


				nextIndex += 1;
				cmd("SetHighlight", insertElem.graphicID, 1);
				insert(insertElem, treeRoot)
				resizeTree();				
			}
			cmd("SetText", 0, "");				
			return commands;
		}
	
		
		function insert(elem:BSTNode, tree:BSTNode)
		{
			cmd("SetHighlight", tree.graphicID , 1);
			cmd("SetHighlight", elem.graphicID , 1);

			if (elem.data < tree.data)
			{
				cmd("SetText", 0,  elem.data + " < " + tree.data + ".  Looking at left subtree");				
			}
			else
			{
				cmd("SetText",  0, elem.data + " >= " + tree.data + ".  Looking at right subtree");				
			}
			cmd("Step");
			cmd("SetHighlight", tree.graphicID, 0);
			cmd("SetHighlight", elem.graphicID, 0);

			if (elem.data < tree.data)
			{
				if (tree.left == null)
				{
					cmd("SetText", 0,"Found null tree, inserting element");				

					cmd("SetHighlight", elem.graphicID, 0);
					tree.left=elem;
					elem.parent = tree;
					cmd("Connect", tree.graphicID, elem.graphicID, LINK_COLOR);
				}
				else
				{
					cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_CIRCLE_COLOR, tree.x, tree.y);
					cmd("Move", highlightID, tree.left.x, tree.left.y);
					cmd("Step");
					cmd("Delete", highlightID);
					insert(elem, tree.left);
				}
			}
			else
			{
				if (tree.right == null)
				{
					cmd("SetText",  0, "Found null tree, inserting element");				
					cmd("SetHighlight", elem.graphicID, 0);
					tree.right=elem;
					elem.parent = tree;
					cmd("Connect", tree.graphicID, elem.graphicID, LINK_COLOR);
					elem.x = tree.x + widthDelta/2;
					elem.y = tree.y + heightDelta
					cmd("Move", elem.graphicID, elem.x, elem.y);
				}
				else
				{
					cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_CIRCLE_COLOR, tree.x, tree.y);
					cmd("Move", highlightID, tree.right.x, tree.right.y);
					cmd("Step");
					cmd("Delete", highlightID);
					insert(elem, tree.right);
				}
			}
			
			
		}
		
		function deleteElement(deletedValue:String):Array
		{
			commands = new Array();
			cmd("SetText", 0, "Deleting "+deletedValue);
			cmd("Step");
			cmd("SetText", 0, "");
			highlightID = nextIndex++;
			treeDelete(treeRoot, deletedValue);
			cmd("SetText", 0, "");			
			// Do delete
			return commands;						
		}

		function treeDelete(tree:BSTNode, valueToDelete:String)
		{
			var leftchild:Boolean = false;
			if (tree != null)
			{
				if (tree.parent != null)
				{
					leftchild = tree.parent.left == tree;
				}
				cmd("SetHighlight", tree.graphicID, 1);
				if (valueToDelete < tree.data)
				{	
					cmd("SetText", 0, valueToDelete + " < " + tree.data + ".  Looking at left subtree");				
				}
				else if (valueToDelete > tree.data)
				{
					cmd("SetText",  0, valueToDelete + " > " + tree.data + ".  Looking at right subtree");				
				}
				else
				{
					cmd("SetText",  0, valueToDelete + " == " + tree.data + ".  Found node to delete");									
				}
				cmd("Step");
				cmd("SetHighlight",  tree.graphicID, 0);

				if (valueToDelete == tree.data)
				{
					if (tree.left == null && tree.right == null)
					{
					    cmd("SetText", 0, "Node to delete is a leaf.  Delete it.");									
						cmd("Delete", tree.graphicID);
						if (leftchild && tree.parent != null)
						{
							tree.parent.left = null;
						}
						else if (tree.parent != null)
						{
							tree.parent.right = null;
						}
						else
						{
							treeRoot = null;
						}
						resizeTree();				
						cmd("Step");

					}
					else if (tree.left == null)
					{
					    cmd("SetText", 0, "Node to delete has no left child.  \nSet parent of deleted node to right child of deleted node.");									
						if (tree.parent != null)
						{
							cmd("Disconnect",  tree.parent.graphicID, tree.graphicID);
							cmd("Connect",  tree.parent.graphicID, tree.right.graphicID, LINK_COLOR);
							cmd("Step");
							cmd("Delete", tree.graphicID);
							if (leftchild)
							{
								tree.parent.left = tree.right;
							}
							else
							{
								tree.parent.right = tree.right;
							}
							tree.right.parent = tree.parent;
						}
						else
						{
					  		cmd("Delete", tree.graphicID);
							treeRoot = tree.right;
							treeRoot.parent = null;
						}
						resizeTree();				
					}
					else if (tree.right == null)
					{
					    cmd("SetText", 0, "Node to delete has no right child.  \nSet parent of deleted node to left child of deleted node.");									
						if (tree.parent != null)
						{
							cmd("Disconnect", tree.parent.graphicID, tree.graphicID);
							cmd("Connect", tree.parent.graphicID, tree.left.graphicID, LINK_COLOR);
							cmd("Step");
							cmd("Delete", tree.graphicID);
							if (leftchild)
							{
								tree.parent.left = tree.left;								
							}
							else
							{
								tree.parent.right = tree.left;
							}
							tree.left.parent = tree.parent;
						}
						else
						{
					  		cmd("Delete",  tree.graphicID);
							treeRoot = tree.left;
							treeRoot.parent = null;
						}
						resizeTree();
					}
					else // tree.left != null && tree.right != null
					{
						cmd("SetText", 0, "Node to delete has two childern.  \nFind largest node in left subtree.");									

						highlightID = nextIndex;
						nextIndex += 1;
						cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_CIRCLE_COLOR, tree.x, tree.y);
						var tmp:BSTNode = tree;
						tmp = tree.left;
						cmd("Move", highlightID, tmp.x, tmp.y);
						cmd("Step");																									
						while (tmp.right != null)
						{
							tmp = tmp.right;
							cmd("Move", highlightID, tmp.x, tmp.y);
							cmd("Step");																									
						}
						cmd("SetText", tree.graphicID, " ");
						var labelID = nextIndex;
						nextIndex += 1;
						cmd("CreateLabel", labelID, tmp.data, tmp.x, tmp.y);
						tree.data = tmp.data;
						cmd("Move", labelID, tree.x, tree.y);
						cmd("SetText", 0, "Copy largest value of left subtree into node to delete.");									

						cmd("Step");
						cmd("SetHighlight", tree.graphicID, 0);
						cmd("Delete", labelID);
						cmd("SetText", tree.graphicID, tree.data);
						cmd("Delete", highlightID);							
						cmd("SetText", 0,"Remove node whose value we copied.");									

						if (tmp.left == null)
						{
							if (tmp.parent != tree)
							{
								tmp.parent.right = null;
							}
							else
							{
								tree.left = null;
							}
							cmd("Delete", tmp.graphicID);
							resizeTree();
						}
						else
						{
							cmd("Disconnect", tmp.parent.graphicID,  tmp.graphicID);
							cmd("Connect", tmp.parent.graphicID, tmp.left.graphicID, LINK_COLOR);
							cmd("Step");
							cmd("Delete", tmp.graphicID);
							if (tmp.parent != tree)
							{
								tmp.parent.right = tmp.left;
								tmp.left.parent = tmp.parent;
							}
							else
							{
								tree.left = tmp.left;
								tmp.left.parent = tree;
							}
							resizeTree();
						}
						
					}
				}
				else if (valueToDelete < tree.data)
				{
					if (tree.left != null)
					{
						cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_CIRCLE_COLOR, tree.x, tree.y);
						cmd("Move", highlightID, tree.left.x, tree.left.y);
						cmd("Step");
						cmd("Delete", highlightID);
					}
					treeDelete(tree.left, valueToDelete);
				}
				else
				{
					if (tree.right != null)
					{
						cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_CIRCLE_COLOR, tree.x, tree.y);
						cmd("Move", highlightID, tree.right.x, tree.right.y);
						cmd("Step");
						cmd("Delete", highlightID);
					}
					treeDelete(tree.right, valueToDelete);
				}
			}
			else
			{
				cmd("SetText", 0, "Elemet "+valueToDelete+" not found, could not delete");
			}
			
		}
			
		function resizeTree()
		{
			var startingPoint:int  = startingX;
			resizeWidths(treeRoot);
			if (treeRoot != null)
			{
				if (treeRoot.leftWidth > startingX && treeRoot.rightWidth < startingX)
				{
					startingPoint = startingPoint + treeRoot.leftWidth - startingX;
				}
				else if (treeRoot.leftWidth < startingX && treeRoot.rightWidth > startingX)
				{
					startingPoint = startingPoint - treeRoot.rightWidth + startingX;
					
				}
				else if (treeRoot.leftWidth > startingX && treeRoot.rightWidth > startingX)
				{
					startingPoint = startingX - treeRoot.rightWidth + treeRoot.leftWidth;
				}
				setNewPositions(treeRoot, startingPoint, startingY, 0);
				animateNewPositions(treeRoot);
				cmd("Step");
			}
			
		}
			
		function setNewPositions(tree, xPosition, yPosition, side)
		{
			if (tree != null)
			{
				tree.y = yPosition;
				if (side == -1)
				{
					xPosition = xPosition - tree.rightWidth;
				}
				else if (side == 1)
				{
					xPosition = xPosition + tree.leftWidth;
				}
				tree.x = xPosition;
				setNewPositions(tree.left, xPosition, yPosition + heightDelta, -1)
				setNewPositions(tree.right, xPosition, yPosition + heightDelta, 1)
			}
			
		}
		function animateNewPositions(tree)
		{
			if (tree != null)
			{
				cmd("Move", tree.graphicID, tree.x, tree.y);
				animateNewPositions(tree.left);
				animateNewPositions(tree.right);
			}
		}
		
		function resizeWidths(tree:BSTNode) : int
		{
			if (tree == null)
			{
				return 0;
			}
			tree.leftWidth = max(resizeWidths(tree.left), widthDelta / 2);
			tree.rightWidth = max(resizeWidths(tree.right), widthDelta / 2);
			return tree.leftWidth + tree.rightWidth;
		}
	}
}

