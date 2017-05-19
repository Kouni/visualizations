package {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.display.DisplayObjectContainer;
	import fl.controls.Button;
	import fl.controls.TextInput;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import fl.events.ComponentEvent;



	public class RedBlackTree extends AlgorithmAnimation 
	{
		
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
		
		
		const FOREGROUND_RED = 0xAA0000;
		const BACKGROUND_RED = 0xFFAAAA;
		
		const FOREGROUND_BLACK =  0x000000
		const BACKGROUND_BLACK = 0xAAAAAA;
		const BACKGROUND_DOUBLE_BLACK = 0x777777;
		
		
		// const HIGHLIGHT_LABEL_COLOR = RED
		// const HIGHLIGHT_LINK_COLOR = RED

		
		const HIGHLIGHT_LABEL_COLOR = 0xFF0000
		const HIGHLIGHT_LINK_COLOR = 0xFF0000
		
		const BLUE = 0x0000FF;
		
		const LINK_COLOR = 0x000000
		const BACKGROUND_COLOR = BACKGROUND_BLACK;
		const HIGHLIGHT_COLOR = 0x007700
		const FOREGROUND_COLOR = FOREGROUND_BLACK;
		const HEIGHT_LABEL_COLOR = 0x00AA00
		const PRINT_COLOR = FOREGROUND_COLOR


		// Input Controls

		var treeRoot:RedBlackNode;
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

		
		public function RedBlackTree(am)
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
			if (insertedValue == "")
				return;
			enterFieldInsert.text = "";
			implementAction(insertElement,insertedValue);
		}
		
		function deleteCallback(event):void
		{
			var deletedValue:String;
			deletedValue = normalizeNumber(enterFieldDelete.text, 4);
			if (deletedValue == "")
				return;
			enterFieldDelete.text = "";
			implementAction(deleteElement,deletedValue);						
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
		   		cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_COLOR, treeRoot.x, treeRoot.y);
				xPosOfNextLabel = FIRST_PRINT_POS_X;
				yPosOfNextLabel = FIRST_PRINT_POS_Y;
				printTreeRec(treeRoot);
				cmd("Delete",highlightID);
				cmd("Step");
				for (var i:int = firstLabel; i < nextIndex; i++)
					cmd("Delete", i);
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
			if (findValue == "")
				return;
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
				
				
		function doFind(tree:RedBlackNode, value:String)
		{
		    cmd("SetText", 0, "Searchiing for "+value);
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
							cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_COLOR, tree.x, tree.y);
							cmd("Move", highlightID, tree.left.x, tree.left.y);
							cmd("Step");
							cmd("Delete", highlightID);
						}
						doFind(tree.left, value);
					}
					else
					{
						cmd("SetText", 0, " Searching for "+value+" : " + value + " > " + tree.data + " (look to right subtree)");					
						cmd("Step");
						cmd("SetHighlight", tree.graphicID, 0);
						if (tree.right!= null)
						{
							cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_COLOR, tree.x, tree.y);
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
				cmd("SetText", 0, " Searching for "+value+" : " + "< Empty Tree > (Element not found)");				
				cmd("Step");					
				cmd("SetText", 0, " Searching for "+value+" : " + " (Element not found)");					
			}
		}
		
		
		function findUncle(tree:RedBlackNode)
		{
			if (tree.parent == null)
			{
				return null;
			}
			var par : RedBlackNode = tree.parent;
			if (par.parent == null)
			{
				return null;
			}
			var grandPar : RedBlackNode  = par.parent;
			
			if (grandPar.left == par)
			{
				return grandPar.right;
			}
			else
			{
				return grandPar.left;
			}				
		}
		
		
		
		function blackLevel(tree:RedBlackNode)
		{
			if (tree == null)
			{
				return 1;
			}
			else
			{
				return tree.blackLevel;
			}
		}
		
		
		function insertElement(insertedValue:String):Array
		{
			commands = new Array();	
		    cmd("SetText", 0, " Inserting "+insertedValue);
			highlightID = nextIndex++;

			if (treeRoot == null)
			{
				var treeNodeID:int = nextIndex++;
                cmd("CreateCircle", treeNodeID, insertedValue,  startingX, startingY);
				cmd("SetForegroundColor", treeNodeID, FOREGROUND_BLACK);
				cmd("SetBackgroundColor", treeNodeID, BACKGROUND_BLACK);
				cmd("Step");				
				treeRoot = new RedBlackNode(insertedValue, treeNodeID, startingX, startingY);
				treeRoot.blackLevel = 1;
			}
			else
			{
				treeNodeID = nextIndex++;
				
				cmd("CreateCircle", treeNodeID, insertedValue, 100, 100);
				cmd("SetForegroundColor", treeNodeID, FOREGROUND_RED);
				cmd("SetBackgroundColor", treeNodeID, BACKGROUND_RED);
				cmd("Step");				
				var insertElem:RedBlackNode = new RedBlackNode(insertedValue, treeNodeID, 100, 100)

				cmd("SetHighlight", insertElem.graphicID, 1);
				insertElem.height = 1;
				insert(insertElem, treeRoot);
//				resizeTree();				
			}
			cmd("SetText", 0, " ");				
			return commands;
		}
	
	
		function singleRotateRight(tree:RedBlackNode): RedBlackNode
		{
			var B:RedBlackNode = tree;
			var t3:RedBlackNode = B.right;
			var A:RedBlackNode = tree.left;
			var t1:RedBlackNode = A.left;
			var t2:RedBlackNode = A.right;

			cmd("SetText", 0, "Single Rotate Right");
			cmd("Disconnect", B.graphicID, A.graphicID);
			cmd("Connect", B.graphicID, A.graphicID, HIGHLIGHT_LINK_COLOR);
			cmd("Step");
			
			// TODO:  Change link color
			
			if (t2 != null)
			{
				cmd("Disconnect", A.graphicID, t2.graphicID);																		  
				cmd("Connect", B.graphicID, t2.graphicID, LINK_COLOR);
				t2.parent = B;
			}
			cmd("Disconnect", B.graphicID, A.graphicID);
			cmd("Connect", A.graphicID, B.graphicID, LINK_COLOR);
			A.parent = B.parent;
			if (treeRoot == B)
			{
				treeRoot = A;
			}
			else
			{
				cmd("Disconnect", B.parent.graphicID, B.graphicID, LINK_COLOR);
				cmd("Connect", B.parent.graphicID, A.graphicID, LINK_COLOR)
				if (B.isLeftChild())
				{
					B.parent.left = A;
				}
				else
				{
					B.parent.right = A;
				}
			}
			A.right = B;
			B.parent = A;
			B.left = t2;
			resetHeight(B);
			resetHeight(A);
			resizeTree();			
			return A;
		}
		
		
		
		function singleRotateLeft(tree:RedBlackNode) : RedBlackNode
		{
			var A:RedBlackNode = tree;
			var B:RedBlackNode = tree.right;
			var t1:RedBlackNode = A.left;
			var t2:RedBlackNode = B.left;
			var t3:RedBlackNode = B.right;

			cmd("SetText", 0, "Single Rotate Left");
			cmd("Disconnect", A.graphicID, B.graphicID);
			cmd("Connect", A.graphicID, B.graphicID, HIGHLIGHT_LINK_COLOR);
			cmd("Step");
						
			if (t2 != null)
			{
				cmd("Disconnect", B.graphicID, t2.graphicID);																		  
				cmd("Connect", A.graphicID, t2.graphicID, LINK_COLOR);
				t2.parent = A;
			}
			cmd("Disconnect", A.graphicID, B.graphicID);
			cmd("Connect", B.graphicID, A.graphicID, LINK_COLOR);
			B.parent = A.parent;
			if (treeRoot == A)
			{
				treeRoot = B;
			}
			else
			{
				cmd("Disconnect", A.parent.graphicID, A.graphicID, LINK_COLOR);
				cmd("Connect", A.parent.graphicID, B.graphicID, LINK_COLOR)
				
				if (A.isLeftChild())
				{
					A.parent.left = B;
				}
				else
				{
					A.parent.right = B;
				}
			}
			B.left = A;
			A.parent = B;
			A.right = t2;
			resetHeight(A);
			resetHeight(B);

			resizeTree();
			return B;
		}
		
		
		
		
		function getHeight(tree:RedBlackNode) :int
		{
			if (tree == null)
			{
				return 0;
			}
			return tree.height;
		}
	
		function resetHeight(tree:RedBlackNode):void
		{
			if (tree != null)
			{
				var newHeight:int = Math.max(getHeight(tree.left), getHeight(tree.right)) + 1;
				if (tree.height != newHeight)
				{
					tree.height = Math.max(getHeight(tree.left), getHeight(tree.right)) + 1
				}
			}
		}
		
		function insert(elem:RedBlackNode, tree:RedBlackNode)
		{
			cmd("SetHighlight", tree.graphicID, 1);
			cmd("SetHighlight", elem.graphicID, 1);

			if (elem.data < tree.data)
			{
				cmd("SetText", 0, elem.data + " < " + tree.data + ".  Looking at left subtree");				
			}
			else
			{
				cmd("SetText",  0, elem.data + " >= " + tree.data + ".  Looking at right subtree");				
			}
			cmd("Step");
			cmd("SetHighlight", tree.graphicID , 0);
			cmd("SetHighlight", elem.graphicID, 0);

			if (elem.data < tree.data)
			{
				if (tree.left == null)
				{
					cmd("SetText", 0, "Found null tree, inserting element");				

					cmd("SetHighlight", elem.graphicID, 0);
					tree.left=elem;
					elem.parent = tree;
					cmd("Connect", tree.graphicID, elem.graphicID, LINK_COLOR);

					resizeTree();
					
					fixDoubleRed(elem);

				}
				else
				{
					cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_COLOR, tree.x, tree.y);
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

					resizeTree();
					fixDoubleRed(elem);
				}
				else
				{
					cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_COLOR, tree.x, tree.y);
					cmd("Move", highlightID, tree.right.x, tree.right.y);
					cmd("Step");
					cmd("Delete", highlightID);
					insert(elem, tree.right);
				}
			}
			
			
		}
		
		
		function fixDoubleRed(tree:RedBlackNode)
		{
			if (tree.parent != null)
			{
				if (tree.parent.blackLevel > 0)
				{
					return;
				}
				if (tree.parent.parent == null)
				{
					cmd("SetText", 0, "Tree root is red, color it black.");
					cmd("Step");
					tree.parent.blackLevel = 1;
					cmd("SetForegroundColor", tree.parent.graphicID, FOREGROUND_BLACK);
					cmd("SetBackgroundColor", tree.parent.graphicID, BACKGROUND_BLACK);
					return;
				}
				var uncle:RedBlackNode = findUncle(tree);
				if (blackLevel(uncle) == 0)
				{
					cmd("SetText", 0, "Node and parent are both red.  Uncle of node is red -- push blackness down from grandparent");
					cmd("Step");

					cmd("SetForegroundColor", uncle.graphicID, FOREGROUND_BLACK);
					cmd("SetBackgroundColor",uncle.graphicID, BACKGROUND_BLACK);
					uncle.blackLevel = 1;
					
					tree.parent.blackLevel = 1;
					cmd("SetForegroundColor", tree.parent.graphicID, FOREGROUND_BLACK);
					cmd("SetBackgroundColor",tree.parent.graphicID, BACKGROUND_BLACK);
					
					tree.parent.parent.blackLevel = 0;
					cmd("SetForegroundColor", tree.parent.parent.graphicID, FOREGROUND_RED);
					cmd("SetBackgroundColor",tree.parent.parent.graphicID, BACKGROUND_RED);
					cmd("Step");
					fixDoubleRed(tree.parent.parent);
				}
				else
				{
					if (tree.isLeftChild() &&  !tree.parent.isLeftChild())
					{
						cmd("SetText", 0, "Node and parent are both red.  Node is left child, parent is right child -- rotate");
						cmd("Step");

						singleRotateRight(tree.parent);
						tree=tree.right;
						
					}
					else if (!tree.isLeftChild() && tree.parent.isLeftChild())
					{
						cmd("SetText", 0, "Node and parent are both red.  Node is right child, parent is left child -- rotate");
						cmd("Step");

						singleRotateLeft(tree.parent);
						tree=tree.left;
					}
					
					if (tree.isLeftChild())
					{
						cmd("SetText", 0, "Node and parent are both red.  Node is left child, parent is left child\nCan fix extra redness with a single rotation");
						cmd("Step");

						singleRotateRight(tree.parent.parent);
						tree.parent.blackLevel = 1;
						cmd("SetForegroundColor", tree.parent.graphicID, FOREGROUND_BLACK);
						cmd("SetBackgroundColor",tree.parent.graphicID, BACKGROUND_BLACK);

						tree.parent.right.blackLevel = 0;
						cmd("SetForegroundColor", tree.parent.right.graphicID, FOREGROUND_RED);
						cmd("SetBackgroundColor",tree.parent.right.graphicID, BACKGROUND_RED);						
						
						
					}
					else
					{
						cmd("SetText", 0, "Node and parent are both red.  Node is right child, parent is right child\nCan fix extra redness with a single rotation");
						cmd("Step");

						singleRotateLeft(tree.parent.parent);
						tree.parent.blackLevel = 1;
						cmd("SetForegroundColor", tree.parent.graphicID, FOREGROUND_BLACK);
						cmd("SetBackgroundColor",tree.parent.graphicID, BACKGROUND_BLACK);

						tree.parent.left.blackLevel = 0;
						cmd("SetForegroundColor", tree.parent.left.graphicID, FOREGROUND_RED);
						cmd("SetBackgroundColor",tree.parent.left.graphicID, BACKGROUND_RED);				
						
					}					
				}
		
			}
			else
			{
				if (tree.blackLevel == 0)
				{
					cmd("SetText", 0, "Root of the tree is red.  Color it black");
					cmd("Step");

					tree.blackLevel = 1;
					cmd("SetForegroundColor", tree.graphicID, FOREGROUND_BLACK);
					cmd("SetBackgroundColor", tree.graphicID, BACKGROUND_BLACK);
				}
			}
			
		}
		
		function deleteElement(deletedValue:String):Array
		{
			commands = new Array();
			cmd("SetText", 0, "Deleting "+deletedValue);
			cmd("Step");
			cmd("SetText", 0, " ");
			highlightID = nextIndex++;
			treeDelete(treeRoot, deletedValue);
			cmd("SetText", 0, " ");			
			// Do delete
			return commands;						
		}
		
		
		function fixLeftNull(tree:RedBlackNode)
		{
				var treeNodeID:int = nextIndex++;
				var nullLeaf:RedBlackNode;
				cmd("SetText", 0, "Coloring 'Null Leaf' double black");

                cmd("CreateCircle", treeNodeID, "NULL\nLEAF",  tree.x, tree.y);
				cmd("SetForegroundColor", treeNodeID, FOREGROUND_BLACK);
				cmd("SetBackgroundColor", treeNodeID, BACKGROUND_DOUBLE_BLACK);
				nullLeaf = new RedBlackNode("NULL\nLEAF", treeNodeID, tree.x, tree.x);
				nullLeaf.parent = tree;
				tree.left = nullLeaf;
				cmd("Connect", tree.graphicID, nullLeaf.graphicID, LINK_COLOR);

				resizeTree();				
				fixExtraBlackChild(tree, true);
				cmd("Delete", nullLeaf.graphicID);
				nullLeaf.parent.left = null;
		}
		

		function fixRightNull(tree:RedBlackNode)
		{
			var treeNodeID:int = nextIndex++;
			var nullLeaf:RedBlackNode;
			cmd("SetText", 0, "Coloring 'Null Leaf' double black");

			cmd("CreateCircle", treeNodeID, "NULL\nLEAF",  tree.x, tree.y);
			cmd("SetForegroundColor", treeNodeID, FOREGROUND_BLACK);
			cmd("SetBackgroundColor", treeNodeID, BACKGROUND_DOUBLE_BLACK);
			nullLeaf = new RedBlackNode("NULL\nLEAF", treeNodeID, tree.x, tree.x);
			nullLeaf.parent = tree;
			tree.right = nullLeaf;
			cmd("Connect", tree.graphicID, nullLeaf.graphicID, LINK_COLOR);

			resizeTree();				

			fixExtraBlackChild(tree, false);
			cmd("Delete", nullLeaf.graphicID);
			nullLeaf.parent.right = null;

		}
		
		
		function fixExtraBlackChild(parNode:RedBlackNode, isLeftChild:Boolean)
		{
			var sibling:RedBlackNode;
			var doubleBlackNode:RedBlackNode;
			if (isLeftChild)
			{
				sibling = parNode.right;
				doubleBlackNode = parNode.left;
			}
			else
			{
				sibling = parNode.left;				
				doubleBlackNode = parNode.right;
			}
			if (blackLevel(sibling) > 0 && blackLevel(sibling.left) > 0 && blackLevel(sibling.right) > 0)
			{
				cmd("SetText", 0, "Double black node has sibling uncle and 2 black nephews.  Push up black level");
				cmd("Step");
				sibling.blackLevel = 0;
				fixNodeColor(sibling);
				if (doubleBlackNode != null)
				{
					doubleBlackNode.blackLevel = 1;
					fixNodeColor(doubleBlackNode);
					
				}
				if (parNode.blackLevel == 0)
				{
					parNode.blackLevel = 1;
					fixNodeColor(parNode);
				}
				else
				{
					parNode.blackLevel = 2;
					fixNodeColor(parNode);
					cmd("SetText", 0, "Pushing up black level created another double black node.  Repeating ...");
					cmd("Step");
					fixExtraBlack(parNode);
				}				
			}
			else if (blackLevel(sibling) == 0)
			{
				cmd("SetText", 0, "Double black node has red sibling.  Rotate tree to make sibling black ...");
				cmd("Step");
				if (isLeftChild)
				{
					var newPar:RedBlackNode = singleRotateLeft(parNode);
					newPar.blackLevel = 1;
					fixNodeColor(newPar);
					newPar.left.blackLevel = 0;
					fixNodeColor(newPar.left);
					fixExtraBlack(newPar.left.left);

				}
				else
				{
					newPar  = singleRotateRight(parNode);
					newPar.blackLevel = 1;
					fixNodeColor(newPar);
					newPar.right.blackLevel = 0;
					fixNodeColor(newPar.right);
					fixExtraBlack(newPar.right.right);
				}
			}
			else if (isLeftChild && blackLevel(sibling.right) > 0)
			{
				cmd("SetText", 0, "Double black node has black sibling, but double black node is a left child, \nand the right nephew is black.  Rotate tree to make opposite nephew red ...");
				cmd("Step");

				var newSib:RedBlackNode = singleRotateRight(sibling);
				newSib.blackLevel = 1;
				fixNodeColor(newSib);
				newSib.right.blackLevel = 0;
				fixNodeColor(newSib.right);
				cmd("Step");
				fixExtraBlackChild(parNode, isLeftChild);
			}
			else if (!isLeftChild && blackLevel(sibling.left) > 0)
			{
				cmd("SetText", 0, "Double black node has black sibling, but double black node is a right child, \nand the left nephew is black.  Rotate tree to make opposite nephew red ...");
				cmd("Step");
				newSib = singleRotateLeft(sibling);
				newSib.blackLevel = 1;
				fixNodeColor(newSib);
				newSib.left.blackLevel = 0;
				fixNodeColor(newSib.left);
				cmd("Step");
				fixExtraBlackChild(parNode, isLeftChild);
			}
			else if (isLeftChild)
			{
				cmd("SetText", 0, "Double black node has black sibling, is a left child, and it's right nephew is red.\nOne rotation can fix double-blackness.");
				cmd("Step");

				var oldParBlackLevel  = parNode.blackLevel;
				newPar = singleRotateLeft(parNode);
				if (oldParBlackLevel == 0)
				{
					newPar.blackLevel = 0;
					fixNodeColor(newPar);
					newPar.left.blackLevel = 1;
					fixNodeColor(newPar.left);
				}
				newPar.right.blackLevel = 1;
				fixNodeColor(newPar.right);
				if (newPar.left.left != null)
				{
					newPar.left.left.blackLevel = 1;
					fixNodeColor(newPar.left.left);
				}
			}
			else
			{
				cmd("SetText", 0, "Double black node has black sibling, is a right child, and it's left nephew is red.\nOne rotation can fix double-blackness.");
				cmd("Step");

				oldParBlackLevel  = parNode.blackLevel;
				newPar = singleRotateRight(parNode);
				if (oldParBlackLevel == 0)
				{
					newPar.blackLevel = 0;
					fixNodeColor(newPar);
					newPar.right.blackLevel = 1;
					fixNodeColor(newPar.right);
				}
				newPar.left.blackLevel = 1;
				fixNodeColor(newPar.left);
				if (newPar.right.right != null)
				{
					newPar.right.right.blackLevel = 1;
					fixNodeColor(newPar.right.right);
				}
			}
		}
		
		
		function fixExtraBlack(tree:RedBlackNode)
		{
			if (tree.blackLevel > 1)
			{
				if (tree.parent == null)
				{
					cmd("SetText", 0, "Double black node is root.  Make it single black.");
					cmd("Step");

					tree.blackLevel = 1;
					cmd("SetBackgroundColor", tree.graphicID, BACKGROUND_BLACK);
				}
				else if (tree.parent.left == tree)
				{
					fixExtraBlackChild(tree.parent, true);
				}
				else
				{
					fixExtraBlackChild(tree.parent, false);					
				}
				
			}
			else 
			{
				// No double blackness
				
			}
		}
		
		
		
		function treeDelete(tree:RedBlackNode, valueToDelete:String)
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
					cmd("SetText", 0, valueToDelete + " > " + tree.data + ".  Looking at right subtree");				
				}
				else
				{
					cmd("SetText", 0, valueToDelete + " == " + tree.data + ".  Found node to delete");									
				}
				cmd("Step");
				cmd("SetHighlight", tree.graphicID, 0);

				if (valueToDelete == tree.data)
				{
					var needFix:Boolean = tree.blackLevel > 0;
					if (tree.left == null && tree.right == null)
					{
					    cmd("SetText",  0, "Node to delete is a leaf.  Delete it.");									
						cmd("Delete", tree.graphicID);


						if (leftchild && tree.parent != null)
						{
							tree.parent.left = null;
							resizeTree();				
							cmd("Step");

							if (needFix)
							{
								fixLeftNull(tree.parent);
							}
						}
						else if (tree.parent != null)
						{
							tree.parent.right = null;
							resizeTree();				
							cmd("Step");
							if (needFix)
							{
								fixRightNull(tree.parent);
							}
						}
						else
						{
							treeRoot = null;
						}

					}
					else if (tree.left == null)
					{
					    cmd("SetText", 0, "Node to delete has no left child.  \nSet parent of deleted node to right child of deleted node.");									
						if (tree.parent != null)
						{
							cmd("Disconnect", tree.parent.graphicID, tree.graphicID);
							cmd("Connect", tree.parent.graphicID, tree.right.graphicID, LINK_COLOR);
							cmd("Step");
							cmd("Delete", tree.graphicID);
							if (leftchild)
							{
								tree.parent.left = tree.right;
								if (needFix)
								{
									tree.parent.left.blackLevel++;
									fixNodeColor(tree.parent.left);
									fixExtraBlack(tree.parent.left);
								}
							}
							else
							{
								tree.parent.right = tree.right;
								if (needFix)
								{
									tree.parent.right.blackLevel++;
									fixNodeColor(tree.parent.right);
									fixExtraBlack(tree.parent.right);
								}
								
							}
							tree.right.parent = tree.parent;
						}
						else
						{
					  		cmd("Delete", tree.graphicID);
							treeRoot = tree.right;
							treeRoot.parent = null;
							if (treeRoot.blackLevel == 0)
							{
								treeRoot.blackLevel = 1;
								cmd("SetForegroundColor", treeRoot.graphicID, FOREGROUND_BLACK);
								cmd("SetBackgroundColor", treeRoot.graphicID, BACKGROUND_BLACK);		
							}
						}
						resizeTree();				
					}
					else if (tree.right == null)
					{
					    cmd("SetText",  0,"Node to delete has no right child.  \nSet parent of deleted node to left child of deleted node.");									
						if (tree.parent != null)
						{
							cmd("Disconnect", tree.parent.graphicID, tree.graphicID);
							cmd("Connect", tree.parent.graphicID, tree.left.graphicID, LINK_COLOR);
							cmd("Step");
							cmd("Delete", tree.graphicID);
							resizeTree();
							cmd("Step");
							if (leftchild)
							{
								tree.parent.left = tree.left;
								if (needFix)
								{
									tree.parent.left.blackLevel++;
									fixNodeColor(tree.parent.left);
									fixExtraBlack(tree.parent.left);
								}
								else
								{
									cmd("SetText", 0, "Deleted node was red.  No tree rotations required.");									
									cmd("Step");									
								}
							}
							else
							{
								tree.parent.right = tree.left;
								if (needFix)
								{
									tree.parent.right.blackLevel++;
									fixNodeColor(tree.parent.right);
									fixExtraBlack(tree.parent.left);
								}
								else
								{
									cmd("SetText", 0, "Deleted node was red.  No tree rotations required.");									
									cmd("Step");									
								}
							}
							tree.left.parent = tree.parent;
						}
						else
						{
					  		cmd("Delete" , tree.graphicID);
							treeRoot = tree.left;
							treeRoot.parent = null;
							if (treeRoot.blackLevel == 0)
							{
								treeRoot.blackLevel = 1;
								fixNodeColor(treeRoot);
							}
						}
					}
					else // tree.left != null && tree.right != null
					{
						cmd("SetText", 0, "Node to delete has two childern.  \nFind largest node in left subtree.");									

						highlightID = nextIndex;
						nextIndex += 1;
						cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_COLOR, tree.x, tree.y);
						var tmp:RedBlackNode = tree;
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
						cmd("SetForegroundColor", labelID, BLUE);
						tree.data = tmp.data;
						cmd("Move", labelID, tree.x, tree.y);
						cmd("SetText", 0, "Copy largest value of left subtree into node to delete.");									

						cmd("Step");
						cmd("SetHighlight", tree.graphicID, 0);
						cmd("Delete", labelID);
						cmd("SetText", tree.graphicID, tree.data);
						cmd("Delete", highlightID);							
						cmd("SetText", 0, "Remove node whose value we copied.");									
						
						needFix = tmp.blackLevel > 0;

						
						if (tmp.left == null)
						{
							cmd("Delete", tmp.graphicID);
							resizeTree();
							if (tmp.parent != tree)
							{
								tmp.parent.right = null;
								if (needFix)
								{
									fixRightNull(tmp.parent);
								}
								else
								{
									cmd("SetText", 0, "Deleted node was red.  No tree rotations required.");									
									cmd("Step");									
								}
							}
							else
							{
								tree.left = null;
								if (needFix)
								{
									fixLeftNull(tmp.parent);
								}
								else
								{
									cmd("SetText", 0, "Deleted node was red.  No tree rotations required.");									
									cmd("Step");									
								}
							}
						}
						else
						{
							cmd("Disconnect", tmp.parent.graphicID, tmp.graphicID);
							cmd("Connect", tmp.parent.graphicID, tmp.left.graphicID, LINK_COLOR);
							cmd("Step");
							cmd("Delete", tmp.graphicID);

							if (tmp.parent != tree)
							{
								tmp.parent.right = tmp.left; 
								tmp.left.parent = tmp.parent;
								resizeTree();

								if (needFix)
								{
									cmd("SetText", 0, "Coloring child of deleted node black");
									cmd("Step");
									tmp.left.blackLevel++;
									fixNodeColor(tmp.left);
									fixExtraBlack(tmp.left);
								}
								else
								{
									cmd("SetText", 0, "Deleted node was red.  No tree rotations required.");									
									cmd("Step");									
								}
							}
							else
							{
								tree.left = tmp.left;
								tmp.left.parent = tree;
								resizeTree();
								if (needFix)
								{
									cmd("SetText", 0, "Coloring child of deleted node black");
									cmd("Step");
									tmp.left.blackLevel++;
									fixNodeColor(tmp.left);
									fixExtraBlack(tmp.left);
								}
								else
								{
									cmd("SetText", 0, "Deleted node was red.  No tree rotations required.");									
									cmd("Step");									
								}
							}
						}
						tmp = tmp.parent;
						
					}
				}
				else if (valueToDelete < tree.data)
				{
					if (tree.left != null)
					{
						cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_COLOR, tree.x, tree.y);
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
						cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_COLOR, tree.x, tree.y);
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
			
			
		function fixNodeColor(tree:RedBlackNode)
		{
			if (tree.blackLevel == 0)
			{
				cmd("SetForegroundColor", tree.graphicID, FOREGROUND_RED);
				cmd("SetBackgroundColor", tree.graphicID, BACKGROUND_RED);									
			}
			else
			{
				cmd("SetForegroundColor", tree.graphicID, FOREGROUND_BLACK);
				if (tree.blackLevel > 1)
				{
					cmd("SetBackgroundColor",tree.graphicID, BACKGROUND_DOUBLE_BLACK);			
				}
				else
				{
					cmd("SetBackgroundColor",tree.graphicID, BACKGROUND_BLACK);
				}
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
		
		function resizeWidths(tree:RedBlackNode) : int
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

