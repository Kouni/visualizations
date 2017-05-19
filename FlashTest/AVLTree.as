package {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.display.DisplayObjectContainer;
	import fl.controls.Button;
	import fl.controls.TextInput;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import fl.events.ComponentEvent;



	public class AVLTree extends AlgorithmAnimation 
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
		
		
		const RED = 0xFF0000
		const BLUE = 0x0000FF
		
		// const HIGHLIGHT_LABEL_COLOR = RED
		// const HIGHLIGHT_LINK_COLOR = RED

		
		const HIGHLIGHT_LABEL_COLOR = 0xFF0000
		const HIGHLIGHT_LINK_COLOR = 0xFF0000
		
		
		const LINK_COLOR = 0x007700
		const BACKGROUND_COLOR = 0xEEFFEE
		const HIGHLIGHT_COLOR = 0x007700
		const FOREGROUND_COLOR = 0x007700
		const HEIGHT_LABEL_COLOR = 0x00AA00
		const PRINT_COLOR = FOREGROUND_COLOR


		// Input Controls

		var treeRoot:AVLNode;
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

		
		public function AVLTree(am)
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
				
				
		function doFind(tree:AVLNode, value:String)
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
		
		function insertElement(insertedValue:String):Array
		{
			commands = new Array();	
		    cmd("SetText", 0, " Inserting "+insertedValue);
			highlightID = nextIndex++;

			if (treeRoot == null)
			{
				var treeNodeID:int = nextIndex++;
				var labelID:int  = nextIndex++;
                cmd("CreateCircle", treeNodeID, insertedValue,  startingX, startingY);
				cmd("SetForegroundColor", treeNodeID, FOREGROUND_COLOR);
				cmd("SetBackgroundColor", treeNodeID, BACKGROUND_COLOR);
                cmd("CreateLabel", labelID, 1,  startingX - 20, startingY-20);
				cmd("SetForegroundColor", labelID, HEIGHT_LABEL_COLOR);
				cmd("Step");				
				treeRoot = new AVLNode(insertedValue, treeNodeID, labelID, startingX, startingY);
				treeRoot.height = 1;
			}
			else
			{
				treeNodeID = nextIndex++;
				labelID = nextIndex++;

				cmd("CreateCircle", treeNodeID, insertedValue, 100, 100);
				cmd("SetForegroundColor", treeNodeID, FOREGROUND_COLOR);
				cmd("SetBackgroundColor", treeNodeID, BACKGROUND_COLOR);
				cmd("CreateLabel", labelID, "",  100-20, 100-20);
				cmd("SetForegroundColor", labelID, HEIGHT_LABEL_COLOR);
				cmd("Step");				
				var insertElem:AVLNode = new AVLNode(insertedValue, treeNodeID, labelID, 100, 100)

				cmd("SetHighlight", insertElem.graphicID, 1);
				insertElem.height = 1;
				insert(insertElem, treeRoot);
//				resizeTree();				
			}
			cmd("SetText", 0, " ");				
			return commands;
		}
	
	
		function singleRotateRight(tree:AVLNode)
		{
			var B:AVLNode = tree;
			var t3:AVLNode = B.right;
			var A:AVLNode = tree.left;
			var t1:AVLNode = A.left;
			var t2:AVLNode = A.right;

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
		}
		
		
		
		function singleRotateLeft(tree:AVLNode)
		{
			var A:AVLNode = tree;
			var B:AVLNode = tree.right;
			var t1:AVLNode = A.left;
			var t2:AVLNode = B.left;
			var t3:AVLNode = B.right;

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
		}
		
		
		
		
		function getHeight(tree:AVLNode) :int
		{
			if (tree == null)
			{
				return 0;
			}
			return tree.height;
		}
	
		function resetHeight(tree:AVLNode):void
		{
			if (tree != null)
			{
				var newHeight:int = Math.max(getHeight(tree.left), getHeight(tree.right)) + 1;
				if (tree.height != newHeight)
				{
					tree.height = Math.max(getHeight(tree.left), getHeight(tree.right)) + 1
					cmd("SetText",tree.heightLabelID, newHeight);
				}
			}
		}
		
		function doubleRotateRight(tree:AVLNode):void
		{
			cmd("SetText", 0, "Double Rotate Right");
			var A:AVLNode = tree.left;
			var B:AVLNode = tree.left.right;
			var C:AVLNode = tree;
			var t1:AVLNode = A.left;
			var t2:AVLNode = B.left;
			var t3:AVLNode = B.right;
			var t4:AVLNode = C.right;
			
			cmd("Disconnect", C.graphicID, A.graphicID);
			cmd("Disconnect", A.graphicID, B.graphicID);
			cmd("Connect", C.graphicID, A.graphicID, HIGHLIGHT_LINK_COLOR);
			cmd("Connect", A.graphicID, B.graphicID, HIGHLIGHT_LINK_COLOR);
			cmd("Step");
			
			if (t2 != null)
			{
				cmd("Disconnect",B.graphicID, t2.graphicID);
				t2.parent = A;
				A.right = t2;
				cmd("Connect", A.graphicID, t2.graphicID, LINK_COLOR);
			}
			if (t3 != null)
			{
				cmd("Disconnect",B.graphicID, t3.graphicID);
				t3.parent = C;
				C.left = t2;
				cmd("Connect", C.graphicID, t3.graphicID, LINK_COLOR);
			}
			if (C.parent == null)
			{
				B.parent = null;
				treeRoot = B;
			}
			else
			{
				cmd("Disconnect",C.parent.graphicID, C.graphicID);
				cmd("Connect",C.parent.graphicID, B.graphicID, LINK_COLOR);
				if (C.isLeftChild())
				{
					C.parent.left = B
				}
				else
				{
					C.parent.right = B;
				}
				C.parent = B;
			}
			cmd("Disconnect", C.graphicID, A.graphicID);
			cmd("Disconnect", A.graphicID, B.graphicID);
			cmd("Connect", B.graphicID, A.graphicID, LINK_COLOR);
			cmd("Connect", B.graphicID, C.graphicID, LINK_COLOR);
			B.left = A;
			A.parent = B;
			B.right=C;
			C.parent=B;
			A.right=t2;
			C.left = t3;
			resetHeight(A);
			resetHeight(C);
			resetHeight(B);

			resizeTree();

			
		}
		
		function doubleRotateLeft(tree:AVLNode):void
		{
			cmd("SetText", 0, "Double Rotate Left");
			var A:AVLNode = tree;
			var B:AVLNode = tree.right.left;
			var C:AVLNode = tree.right;
			var t1:AVLNode = A.left;
			var t2:AVLNode = B.left;
			var t3:AVLNode = B.right;
			var t4:AVLNode = C.right;
			
			cmd("Disconnect", A.graphicID, C.graphicID);
			cmd("Disconnect", C.graphicID, B.graphicID);
			cmd("Connect", A.graphicID, C.graphicID, HIGHLIGHT_LINK_COLOR);
			cmd("Connect", C.graphicID, B.graphicID, HIGHLIGHT_LINK_COLOR);
			cmd("Step");
			
			if (t2 != null)
			{
				cmd("Disconnect",B.graphicID, t2.graphicID);
				t2.parent = A;
				A.right = t2;
				cmd("Connect", A.graphicID, t2.graphicID, LINK_COLOR);
			}
			if (t3 != null)
			{
				cmd("Disconnect",B.graphicID, t3.graphicID);
				t3.parent = C;
				C.left = t2;
				cmd("Connect", C.graphicID, t3.graphicID, LINK_COLOR);
			}
			
			
			
			if (A.parent == null)
			{
				B.parent = null;
				treeRoot = B;
			}
			else
			{
				cmd("Disconnect",A.parent.graphicID, A.graphicID);
				cmd("Connect",A.parent.graphicID, B.graphicID, LINK_COLOR);
				if (A.isLeftChild())
				{
					A.parent.left = B
				}
				else
				{
					A.parent.right = B;
				}
				A.parent = B;
			}
			cmd("Disconnect", A.graphicID, C.graphicID);
			cmd("Disconnect", C.graphicID, B.graphicID);
			cmd("Connect", B.graphicID, A.graphicID, LINK_COLOR);
			cmd("Connect", B.graphicID, C.graphicID, LINK_COLOR);
			B.left = A;
			A.parent = B;
			B.right=C;
			C.parent=B;
			A.right=t2;
			C.left = t3;
			resetHeight(A);
			resetHeight(C);
			resetHeight(B);

			resizeTree();

			
		}
		
		function insert(elem:AVLNode, tree:AVLNode)
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
					cmd("SetText",elem.heightLabelID,1); 

					cmd("SetHighlight", elem.graphicID, 0);
					tree.left=elem;
					elem.parent = tree;
					cmd("Connect", tree.graphicID, elem.graphicID, LINK_COLOR);

					resizeTree();
					cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_COLOR, tree.left.x, tree.left.y);
					cmd("Move", highlightID, tree.x, tree.y);
					cmd("SetText",  0, "Unwinding Recursion");			
					cmd("Step");
					cmd("Delete", highlightID);

					if (tree.height < tree.left.height + 1)
					{
						tree.height = tree.left.height + 1
						cmd("SetText",tree.heightLabelID,tree.height); 
						cmd("SetText",  0, "Adjusting height after recursive call");			
						cmd("SetForegroundColor", tree.heightLabelID, HIGHLIGHT_LABEL_COLOR);
						cmd("Step");
						cmd("SetForegroundColor", tree.heightLabelID, HEIGHT_LABEL_COLOR);						
					}
				}
				else
				{
					cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_COLOR, tree.x, tree.y);
					cmd("Move", highlightID, tree.left.x, tree.left.y);
					cmd("Step");
					cmd("Delete", highlightID);
					insert(elem, tree.left);
					cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_COLOR, tree.left.x, tree.left.y);
					cmd("Move", highlightID, tree.x, tree.y);
					cmd("SetText",  0,"Unwinding Recursion");			
					cmd("Step");
					cmd("Delete", highlightID);

					if (tree.height < tree.left.height + 1)
					{
						tree.height = tree.left.height + 1
						cmd("SetText",tree.heightLabelID,tree.height); 
						cmd("SetText",  0, "Adjusting height after recursive call");			
						cmd("SetForegroundColor", tree.heightLabelID, HIGHLIGHT_LABEL_COLOR);
						cmd("Step");
						cmd("SetForegroundColor", tree.heightLabelID, HEIGHT_LABEL_COLOR);

					}
					if ((tree.right != null && tree.left.height > tree.right.height + 1) ||
						(tree.right == null && tree.left.height > 1))
					{
						if (elem.data < tree.left.data)
						{
							singleRotateRight(tree);
						}
						else
						{
							doubleRotateRight(tree);
						}
					}
				}
			}
			else
			{
				if (tree.right == null)
				{
					cmd("SetText",  0, "Found null tree, inserting element");			
					cmd("SetText", elem.heightLabelID,1); 
					cmd("SetHighlight", elem.graphicID, 0);
					tree.right=elem;
					elem.parent = tree;
					cmd("Connect", tree.graphicID, elem.graphicID, LINK_COLOR);
					elem.x = tree.x + widthDelta/2;
					elem.y = tree.y + heightDelta
					cmd("Move", elem.graphicID, elem.x, elem.y);

					resizeTree();
					
					
					cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_COLOR, tree.right.x, tree.right.y);
					cmd("Move", highlightID, tree.x, tree.y);
					cmd("SetText",  0, "Unwinding Recursion");			
					cmd("Step");
					cmd("Delete", highlightID);
					
					if (tree.height < tree.right.height + 1)
					{
						tree.height = tree.right.height + 1
						cmd("SetText",tree.heightLabelID,tree.height); 
						cmd("SetText",   0, "Adjusting height after recursive call");			
						cmd("SetForegroundColor", tree.heightLabelID, HIGHLIGHT_LABEL_COLOR);
						cmd("Step");
						cmd("SetForegroundColor", tree.heightLabelID, HEIGHT_LABEL_COLOR);						
					}
					
					
					

				}
				else
				{
					cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_COLOR, tree.x, tree.y);
					cmd("Move", highlightID, tree.right.x, tree.right.y);
					cmd("Step");
					cmd("Delete", highlightID);
					insert(elem, tree.right);
					cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_COLOR, tree.right.x, tree.right.y);
					cmd("Move", highlightID, tree.x, tree.y);
					cmd("SetText",  0, "Unwinding Recursion");			
					cmd("Step");
					cmd("Delete", highlightID);
					if (tree.height < tree.right.height + 1)
					{
						tree.height = tree.right.height + 1
						cmd("SetText",tree.heightLabelID,tree.height); 
						cmd("SetText",  0, "Adjusting height after recursive call");			
						cmd("SetForegroundColor", tree.heightLabelID, HIGHLIGHT_LABEL_COLOR);
						cmd("Step");
						cmd("SetForegroundColor", tree.heightLabelID, HEIGHT_LABEL_COLOR);


					}
					if ((tree.left != null && tree.right.height > tree.left.height + 1) ||
						(tree.left == null && tree.right.height > 1))
					{
						if (elem.data >= tree.right.data)
						{
							singleRotateLeft(tree);
						}
						else
						{
							doubleRotateLeft(tree);
						}
					}
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
		
		function treeDelete(tree:AVLNode, valueToDelete:String)
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
					if (tree.left == null && tree.right == null)
					{
					    cmd("SetText",  0, "Node to delete is a leaf.  Delete it.");									
						cmd("Delete", tree.graphicID);
						cmd("Delete", tree.heightLabelID);
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
							cmd("Disconnect", tree.parent.graphicID, tree.graphicID);
							cmd("Connect", tree.parent.graphicID, tree.right.graphicID, LINK_COLOR);
							cmd("Step");
							cmd("Delete", tree.graphicID);
							cmd("Delete", tree.heightLabelID);
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
							cmd("Delete", tree.heightLabelID);
							treeRoot = tree.right;
							treeRoot.parent = null;
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
							cmd("Delete", tree.heightLabelID);
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
					  		cmd("Delete" , tree.graphicID);
							cmd("Delete", tree.heightLabelID);
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
						cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_COLOR, tree.x, tree.y);
						var tmp:AVLNode = tree;
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
							cmd("Delete", tmp.heightLabelID);
							resizeTree();
						}
						else
						{
							cmd("Disconnect", tmp.parent.graphicID, tmp.graphicID);
							cmd("Connect", tmp.parent.graphicID, tmp.left.graphicID, LINK_COLOR);
							cmd("Step");
							cmd("Delete", tmp.graphicID);
							cmd("Delete", tmp.heightLabelID);
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
						tmp = tmp.parent;
						
						if (getHeight(tmp) != Math.max(getHeight(tmp.left), getHeight(tmp.right)) + 1)
						{
							tmp.height = Math.max(getHeight(tmp.left), getHeight(tmp.right)) + 1
							cmd("SetText",tmp.heightLabelID,tmp.height); 
							cmd("SetText",  0, "Adjusting height after recursive call");			
							cmd("SetForegroundColor", tmp.heightLabelID, HIGHLIGHT_LABEL_COLOR);
							cmd("Step");
							cmd("SetForegroundColor", tmp.heightLabelID, HEIGHT_LABEL_COLOR);						
						}
						
						

						while (tmp != tree)
						{
							var tmpPar = tmp.parent;
							// TODO:  Add extra animation here?
							if (getHeight(tmp.left)- getHeight(tmp.right) > 1)
							{
								if (getHeight(tmp.left.right) > getHeight(tmp.left.left))
								{
									doubleRotateRight(tmp);
								}
								else
								{
									singleRotateRight(tmp);
								}
							}
							if (tmpPar.right != null)
							{
								if (tmpPar == tree)
								{
									cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_COLOR, tmpPar.left.x, tmpPar.left.y);
									
								}
								else
								{
									cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_COLOR, tmpPar.right.x, tmpPar.right.y);
								}
								cmd("Move", highlightID, tmpPar.x, tmpPar.y);
								cmd("SetText",  0, "Backing up ...");			

								cmd("Step");
								cmd("Delete", highlightID);
							}
							tmp = tmpPar;
						}
						if (getHeight(tree.right)- getHeight(tree.left) > 1)
						{
							if (getHeight(tree.right.left) > getHeight(tree.right.right))
							{
								doubleRotateLeft(tree);
							}
							else
							{
								singleRotateLeft(tree);
							}					
						}
						
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
					if (tree.left != null)
					{
						cmd("SetText", 0, "Unwinding recursion.");
						cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_COLOR, tree.left.x, tree.left.y);
						cmd("Move", highlightID, tree.x, tree.y);
						cmd("Step");
						cmd("Delete", highlightID);
					}
					if (getHeight(tree.right)- getHeight(tree.left) > 1)
					{
						if (getHeight(tree.right.left) > getHeight(tree.right.right))
						{
							doubleRotateLeft(tree);
						}
						else
						{
							singleRotateLeft(tree);
						}					
					}
					if (getHeight(tree) != Math.max(getHeight(tree.left), getHeight(tree.right)) + 1)
					{
						tree.height = Math.max(getHeight(tree.left), getHeight(tree.right)) + 1
						cmd("SetText",tree.heightLabelID,tree.height); 
						cmd("SetText",  0, "Adjusting height after recursive call");			
						cmd("SetForegroundColor", tree.heightLabelID, HIGHLIGHT_LABEL_COLOR);
						cmd("Step");
						cmd("SetForegroundColor", tree.heightLabelID, HEIGHT_LABEL_COLOR);						
					}
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
					if (tree.right != null)
					{
						cmd("SetText", 0, "Unwinding recursion.");
						cmd("CreateHighlightCircle", highlightID, HIGHLIGHT_COLOR, tree.right.x, tree.right.y);
						cmd("Move", highlightID, tree.x, tree.y);
						cmd("Step");
						cmd("Delete", highlightID);
					}
					
					
					if (getHeight(tree.left)- getHeight(tree.right) > 1)
					{
						if (getHeight(tree.left.right) > getHeight(tree.left.left))
						{
							doubleRotateRight(tree);
						}
						else
						{
							singleRotateRight(tree);
						}					
					}
					if (getHeight(tree) != Math.max(getHeight(tree.left), getHeight(tree.right)) + 1)
					{
						tree.height = Math.max(getHeight(tree.left), getHeight(tree.right)) + 1
						cmd("SetText",tree.heightLabelID,tree.height); 
						cmd("SetText",  0, "Adjusting height after recursive call");			
						cmd("SetForegroundColor", tree.heightLabelID, HIGHLIGHT_LABEL_COLOR);
						cmd("Step");
						cmd("SetForegroundColor", tree.heightLabelID, HEIGHT_LABEL_COLOR);						
					}
					
					
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
					tree.heightLabelX = xPosition - 20;
				}
				else if (side == 1)
				{
					xPosition = xPosition + tree.leftWidth;
					tree.heightLabelX = xPosition + 20;
				}
				else
				{
					tree.heightLabelX = xPosition - 20;
				}
				tree.x = xPosition;
				tree.heightLabelY = tree.y - 20;
				setNewPositions(tree.left, xPosition, yPosition + heightDelta, -1)
				setNewPositions(tree.right, xPosition, yPosition + heightDelta, 1)
			}
			
		}
		function animateNewPositions(tree)
		{
			if (tree != null)
			{
				cmd("Move", tree.graphicID, tree.x, tree.y);
				cmd("Move", tree.heightLabelID, tree.heightLabelX, tree.heightLabelY);
				animateNewPositions(tree.left);
				animateNewPositions(tree.right);
			}
		}
		
		function resizeWidths(tree:AVLNode) : int
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

