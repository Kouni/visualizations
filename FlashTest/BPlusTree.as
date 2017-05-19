package {
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.display.DisplayObjectContainer;
	import fl.controls.Button;
	import fl.controls.CheckBox;
	import fl.controls.TextInput;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import fl.events.ComponentEvent;
	import flash.events.Event;
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;


	public class BPlusTree extends AlgorithmAnimation {
		
		// Input Controls
		var enterFieldInsert:TextInput;
		var enterFieldDelete:TextInput;
		var enterFieldFind:TextInput;
		var insertButton:Button;
		var deleteButton:Button;
		var findButton:Button;
		var printButton:Button;
		var clearButton:Button;
	
		var maxDegreeButtonArray:Array;
		var maxDegreeGroup:RadioButtonGroup;
		

		
		const FIRST_PRINT_POS_X:int = 50;
		const FIRST_PRINT_POS_Y:int = 500;
		const PRINT_VERTICAL_GAP:int = 20;
		const PRINT_MAX:int = 990;
		const PRINT_HORIZONTAL_GAP = 50;
		
		var nextIndex:int  = 0;

		static const MIN_MAX_DEGREE = 3;
		static const MAX_MAX_DEGREE = 7;
		
		// Size constants

		static const HEIGHT_DELTA:int  = 50;
		static const NODE_SPACING:int = 15; 
		static const STARTING_X:int = 500;
		static const STARTING_Y:int = 150;
		static const WIDTH_PER_ELEM = 40;
		static const NODE_HEIGHT = 20;
		
		
		
		
		var max_keys = 2;
		var min_keys = 1;
		var split_index = 1;
		
		var max_degree:int = 3;
		
		
		static const MESSAGE_X = 5;
		static const MESSAGE_Y = 50;
		
		// For printing (a bit hacky ...)
		var xPosOfNextLabel:int;
		var yPosOfNextLabel:int;
		
		// For resuing highlight ID (a bit hacky ...)
		var highlightID:int;
		var messageID:int;
		var moveLabel1ID:int;
		var moveLabel2ID:int;
		
		var ignoreInputs = false;
		
		var treeRoot:BTreeNode = null;

		
		const LINK_COLOR = 0x007700;
		const HIGHLIGHT_CIRCLE_COLOR = 0x007700;
		const FOREGROUND_COLOR = 0x007700;
		const BACKGROUND_COLOR = 0xEEFFEE;
		const PRINT_COLOR = FOREGROUND_COLOR;
		
		public function BPlusTree(am)
		{
			super(am);
			
			commands = new Array();
			
			enterFieldInsert = addTextInput(2,2,50,20);
			insertButton = new Button();
			insertButton.label = "Insert";
			insertButton.width = 80;
			insertButton.x = 55;			
			addChild(insertButton);
					
			enterFieldDelete = addTextInput(140,2,50,20);
			deleteButton = new Button();
			deleteButton.label = "Delete";
			deleteButton.width = 80;
			deleteButton.x = 195;			
			addChild(deleteButton);
			
			enterFieldFind = addTextInput(280,2,50,20);
			findButton = new Button();
			findButton.label = "Find";
			findButton.width = 80;
			findButton.x = 335;			
			addChild(findButton);
			
			printButton = new Button();
			printButton.label = "Print";
			printButton.width = 80;
			printButton.x = 420;			
			addChild(printButton);
			

			clearButton = new Button();
			clearButton.label = "Clear";
			clearButton.width = 80;
			clearButton.x = 505;			
			addChild(clearButton);

			
			maxDegreeGroup = new RadioButtonGroup("MaxDegree");
			maxDegreeButtonArray = new Array();
			
			for (var i = MIN_MAX_DEGREE; i <= MAX_MAX_DEGREE; i++)
			{
				maxDegreeButtonArray[i] = new RadioButton();
				maxDegreeButtonArray[i].label = "Max. Degree = " + String(i);
				maxDegreeButtonArray[i].width = 150;
				
				maxDegreeButtonArray[i].x = 595;
				maxDegreeButtonArray[i].y = (i - MIN_MAX_DEGREE) * 20;
				maxDegreeButtonArray[i].selected = false;
				maxDegreeButtonArray[i].addEventListener(Event.CHANGE, maxDegreeChangedHandler);
				maxDegreeButtonArray[i].group = maxDegreeGroup;
				addChild(maxDegreeButtonArray[i]);				
			}
			maxDegreeButtonArray[MIN_MAX_DEGREE].selected = true;
			

			
			
			insertButton.addEventListener(MouseEvent.MOUSE_DOWN, insertCallback);
			deleteButton.addEventListener(MouseEvent.MOUSE_DOWN, deleteCallback);
			findButton.addEventListener(MouseEvent.MOUSE_DOWN, findCallback);
			printButton.addEventListener(MouseEvent.MOUSE_DOWN, printCallback);
			clearButton.addEventListener(MouseEvent.MOUSE_DOWN, clearCallback);
			enterFieldDelete.addEventListener(ComponentEvent.ENTER, deleteCallback);
			enterFieldInsert.addEventListener(ComponentEvent.ENTER, insertCallback);			
			enterFieldFind.addEventListener(ComponentEvent.ENTER, findCallback);

			nextIndex = 0;
			
			
			messageID = nextIndex++;
			cmd("CreateLabel", messageID, "", MESSAGE_X, MESSAGE_Y, 0);
			moveLabel1ID = nextIndex++;
			moveLabel2ID = nextIndex++;
			
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			animationManager.clearHistory();
			commands = new Array();
			
			xPosOfNextLabel = 100;
			yPosOfNextLabel = 200;
			 
		}
		
		override function reset()
		{
			nextIndex = 3;
			max_degree = 3;
			max_keys = 2;
			min_keys = 1;
			split_index = 1;
			// NOTE: The order of these last two commands matters!
			treeRoot = null;
			ignoreInputs = true;
			maxDegreeButtonArray[max_degree].selected = true;
			ignoreInputs = false;
		}
		
		
		override function enableUI(event:AnimationStateEvent):void
		{
			deleteButton.enabled = true;
			insertButton.enabled = true;
			findButton.enabled = true;
			printButton.enabled = true;
			clearButton.enabled = true;
			enterFieldInsert.enabled = true;
			enterFieldDelete.enabled = true;
			enterFieldFind.enabled =true;

			enterFieldDelete.addEventListener(ComponentEvent.ENTER, deleteCallback);
			enterFieldInsert.addEventListener(ComponentEvent.ENTER, insertCallback);
			enterFieldFind.addEventListener(ComponentEvent.ENTER, findCallback);
			for (var i:int = MIN_MAX_DEGREE; i <= MAX_MAX_DEGREE; i++)
			{
				maxDegreeButtonArray[i].enabled = true;
			}
			
			
		}
		override function disableUI(event:AnimationStateEvent):void
		{
			insertButton.enabled = false;
			deleteButton.enabled = false;
			findButton.enabled = false;
		    printButton.enabled = false;
			clearButton.enabled = false;
			enterFieldDelete.removeEventListener(ComponentEvent.ENTER, deleteCallback);
			enterFieldInsert.removeEventListener(ComponentEvent.ENTER, insertCallback);
			enterFieldFind.removeEventListener(ComponentEvent.ENTER, findCallback);
			enterFieldInsert.enabled = false;
			enterFieldDelete.enabled = false;
			enterFieldFind.enabled = false;
			for (var i:int = MIN_MAX_DEGREE; i <= MAX_MAX_DEGREE; i++)
			{
				maxDegreeButtonArray[i].enabled = false;
			}			
		}

		
		function maxDegreeChangedHandler(event:Event):void 
		{
			if ( event.currentTarget.selected && !ignoreInputs )
			{
				for (var i:int = MIN_MAX_DEGREE; i <= MAX_MAX_DEGREE; i++)
				{
					if (event.currentTarget == maxDegreeButtonArray[i] && max_degree != i)
					{
						implementAction(changeDegree, String(i));
						break;
					}
				}
			}
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
		
		function clearCallback(event):void
		{
			implementAction(clearTree, "");
		}
			
				
		function printCallback(event):void
		{
			implementAction(printTree,"");						
		}
		
		function printTree(unused:String)
		{

			commands = new Array();
			cmd("SetText", messageID, "Printing tree");
			var firstLabel:int = nextIndex;

			if (treeRoot != null)
			{
			xPosOfNextLabel = FIRST_PRINT_POS_X;
			yPosOfNextLabel = FIRST_PRINT_POS_Y;

			var tmp = treeRoot;

			cmd("SetHighlight", tmp.graphicID, 1);
			cmd("Step");
			while (!tmp.isLeaf)
			{
				cmd("SetEdgeHighlight", tmp.graphicID, tmp.children[0].graphicID, 1);
				cmd("Step");
				cmd("SetHighlight", tmp.graphicID, 0);
				cmd("SetHighlight", tmp.children[0].graphicID, 1);
				cmd("SetEdgeHighlight", tmp.graphicID, tmp.children[0].graphicID, 0);
				cmd("Step");
				tmp = tmp.children[0];				
			}
			
			while (tmp!= null)
			{
				cmd("SetHighlight", tmp.graphicID, 1);
				for (i = 0; i < tmp.numKeys; i++)
				{
					var nextLabelID:int = nextIndex++;
					cmd("CreateLabel", nextLabelID, tmp.keys[i], getLabelX(tmp, i), tmp.y);
					cmd("SetForegroundColor", nextLabelID, PRINT_COLOR);
					cmd("Move", nextLabelID, xPosOfNextLabel, yPosOfNextLabel);
					cmd("Step");			
					xPosOfNextLabel +=  PRINT_HORIZONTAL_GAP;
					if (xPosOfNextLabel > PRINT_MAX)
					{
						xPosOfNextLabel = FIRST_PRINT_POS_X;
						yPosOfNextLabel += PRINT_VERTICAL_GAP;
					}
				}
				if (tmp.next != null)
				{
					cmd("SetEdgeHighlight", tmp.graphicID, tmp.next.graphicID, 1);
					cmd("Step");
					cmd("SetEdgeHighlight", tmp.graphicID, tmp.next.graphicID, 0);
				}
				cmd("SetHighlight", tmp.graphicID, 0);
				tmp = tmp.next;
			}
			cmd("Step");
			for (var i:int = firstLabel; i < nextIndex; i++)
			{
				cmd("Delete", i);
			}
			nextIndex = firstLabel;
			}
			cmd("SetText", messageID, "");
			return commands;
		}
		
		function printTreeRec(tree)
		{
			// NEEDS TO CHANGE COMPLETELY!!
			cmd("SetHighlight", tree.graphicID, 1);
			if (tree.isLeaf)
			{
				for (var i:int = 0; i < tree.numKeys;i++)
				{
				}
				cmd("SetHighlight", tree.graphicID, 0);
			}
			else
			{
				cmd("SetEdgeHighlight", tree.graphicID, tree.children[0].graphicID, 1);
				cmd("Step");
				cmd("SetHighlight", tree.graphicID, 0);
				cmd("SetEdgeHighlight", tree.graphicID, tree.children[0].graphicID, 0);
				printTreeRec(tree.children[0]);
				for (i = 0; i < tree.numKeys; i++)
				{
					cmd("SetHighlight", tree.graphicID, 1);
					var nextLabelID:int  = nextIndex++;
					cmd("CreateLabel", nextLabelID, tree.keys[i], getLabelX(tree, i), tree.y);
					cmd("SetForegroundColor", nextLabelID, PRINT_COLOR);
					cmd("Move", nextLabelID, xPosOfNextLabel, yPosOfNextLabel);
					cmd("Step");			
					xPosOfNextLabel +=  PRINT_HORIZONTAL_GAP;
					if (xPosOfNextLabel > PRINT_MAX)
					{
						xPosOfNextLabel = FIRST_PRINT_POS_X;
						yPosOfNextLabel += PRINT_VERTICAL_GAP;
					}
					cmd("SetEdgeHighlight", tree.graphicID, tree.children[i+1].graphicID, 1);
					cmd("Step");
					cmd("SetHighlight", tree.graphicID, 0);
					cmd("SetEdgeHighlight", tree.graphicID, tree.children[i+1].graphicID, 0);
					printTreeRec(tree.children[i+1]);
				}
				cmd("SetHighlight", tree.graphicID, 1);
				cmd("Step");
				cmd("SetHighlight", tree.graphicID, 0);

			}
			
			
		}
		
		function clearTree(ignored)
		{
			commands = new Array();
			deleteTree(treeRoot);
			treeRoot = null;
			nextIndex = 3;		
			return commands;
		}
		
		function deleteTree(tree)
		{
			if (tree != null)
			{
				if (!tree.isLeaf)
				{
					for (var i:int = 0; i <= tree.numKeys; i++)
					{
						cmd("Disconnect", tree.graphicID, tree.children[i].graphicID);
						deleteTree(tree.children[i]);
						tree.children[i] == null;
					}
				}
				cmd("Delete", tree.graphicID);
			}
		}
		
		
		function changeDegree(degree):Array
		{
			commands = new Array();
			deleteTree(treeRoot);
			treeRoot = null;
			nextIndex = 3;
			var newDegree = int(degree);
			ignoreInputs = true;
			maxDegreeButtonArray[newDegree].selected = true;
			ignoreInputs = false;
			max_degree = newDegree;
			max_keys = newDegree - 1;
			min_keys = int((newDegree + 1) / 2) - 1;
			split_index = int((newDegree) / 2);
			//split_index = int((newDegree - 1) / 2);
			if (commands.length == 0)
			{
				cmd("Step");
			}
			return commands;
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
				
				cmd("SetText", messageID, "Finding " + findValue);
				findInTree(treeRoot, findValue);
			
			return commands;
		}
				
		function findInTree(tree:BTreeNode, val:String)
		{
			if (tree != null)
			{
				cmd("SetHighlight", tree.graphicID, 1);
				cmd("Step");
				for (var i:int = 0; i < tree.numKeys && tree.keys[i] < val; i++);
				if (i == tree.numKeys)
				{
					if (!tree.isLeaf)
					{
						cmd("SetEdgeHighlight", tree.graphicID, tree.children[tree.numKeys].graphicID, 1);
						cmd("Step");
						cmd("SetHighlight", tree.graphicID, 0);
						cmd("SetEdgeHighlight", tree.graphicID, tree.children[tree.numKeys].graphicID, 0);
						findInTree(tree.children[tree.numKeys], val);
					}
					else
					{
						cmd("SetHighlight", tree.graphicID, 0);
						cmd("SetText", messageID, "Element " + val + " is not in the tree");
					}
				}
				else if (tree.keys[i] > val)
				{
					if (!tree.isLeaf)
					{
						cmd("SetEdgeHighlight", tree.graphicID, tree.children[i].graphicID, 1);
						cmd("Step");
						cmd("SetHighlight", tree.graphicID, 0);
						cmd("SetEdgeHighlight", tree.graphicID, tree.children[i].graphicID, 0);					
						findInTree(tree.children[i], val);
					}
					else
					{
						cmd("SetHighlight", tree.graphicID, 0);
						cmd("SetText", messageID, "Element " + val + " is not in the tree");
					}
				}
				else
				{
					cmd("SetTextColor", tree.graphicID, 0xFF0000, i);
					cmd("SetText", messageID, "Element " + val + " found");
					cmd("Step");
					cmd("SetTextColor", tree.graphicID, FOREGROUND_COLOR, i);
					cmd("SetHighlight", tree.graphicID, 0);

					cmd("Step");
				}
			}
			else
			{
				cmd("SetText", messageID, "Element " + val + " is not in the tree");
			}
		}
				
		
		function insertElement(insertedValue:String):Array
		{
			commands = new Array();
			
			cmd("SetText", messageID, "Inserting " + insertedValue);
			cmd("Step");

			if (treeRoot == null)
			{
				treeRoot = new BTreeNode(nextIndex++, STARTING_X, STARTING_Y);
				cmd("CreateBTreeNode",treeRoot.graphicID, WIDTH_PER_ELEM, NODE_HEIGHT, 1, STARTING_X, STARTING_Y, BACKGROUND_COLOR,  FOREGROUND_COLOR);
				treeRoot.keys[0] = insertedValue;
				cmd("SetText", treeRoot.graphicID, insertedValue, 0);
			}
			else
			{
				insert(treeRoot, insertedValue);					
				if (!treeRoot.isLeaf)
				{
					resizeTree();
				}
			}
			
			cmd("SetText", messageID, "");
			
			return commands;
			
		}
		

	
		
		function insert(tree, insertValue)
		{
			cmd("SetHighlight", tree.graphicID, 1);
			cmd("Step");
			if (tree.isLeaf)
			{
				cmd("SetText", messageID, "Inserting " + insertValue + ".  Inserting into a leaf");
				tree.numKeys++;
				cmd("SetNumElements", tree.graphicID, tree.numKeys);
				var insertIndex = tree.numKeys - 1;
				while (insertIndex > 0 && tree.keys[insertIndex - 1] > insertValue)
				{
					tree.keys[insertIndex] = tree.keys[insertIndex - 1];
					cmd("SetText", tree.graphicID, tree.keys[insertIndex], insertIndex);
					insertIndex--;
				}
				tree.keys[insertIndex] = insertValue;
				cmd("SetText", tree.graphicID, tree.keys[insertIndex], insertIndex);
				cmd("SetHighlight", tree.graphicID, 0);
				if (tree.next != null)
				{
					cmd("Disconnect", tree.graphicID, tree.next.graphicID);
					cmd("Connect", tree.graphicID, 
						           tree.next.graphicID,
								   FOREGROUND_COLOR,
								   0, // Curve
								   1, // Directed
								   "", // Label
								   tree.numKeys);

					
				}
				resizeTree();
				insertRepair(tree);
			}
			else
			{
				var findIndex = 0;
				while (findIndex < tree.numKeys && tree.keys[findIndex] < insertValue)
				{
					findIndex++;					
				}				
				cmd("SetEdgeHighlight", tree.graphicID, tree.children[findIndex].graphicID, 1);
				cmd("Step");
				cmd("SetEdgeHighlight", tree.graphicID, tree.children[findIndex].graphicID, 0);
				cmd("SetHighlight", tree.graphicID, 0);
				insert(tree.children[findIndex], insertValue);				
			}
		}
		
		function insertRepair(tree) : void
		{
			if (tree.numKeys <= max_keys)
			{
				return;
			}
			else if (tree.parent == null)
			{
				treeRoot = split(tree);
				return;
			}
			else
			{
				var newNode :BTreeNode = split(tree);
				insertRepair(newNode);
			}			
		}
		
		function split(tree:BTreeNode): BTreeNode
		{
			cmd("SetText", messageID, "Node now contains too many keys.  Splittig ...");
			cmd("SetHighlight", tree.graphicID, 1);
			cmd("Step");
			cmd("SetHighlight", tree.graphicID, 0);
			var rightNode:BTreeNode = new BTreeNode(nextIndex++, tree.x + 100, tree.y);
			
			var risingNode = tree.keys[split_index];

			
			if (tree.parent != null)
			{
				var currentParent = tree.parent;
				for (var parentIndex = 0; parentIndex < currentParent.numKeys + 1 && currentParent.children[parentIndex] != tree; parentIndex++);
				if (parentIndex == currentParent.numKeys + 1)
				{
					throw new Error("Couldn't find which child we were!");
				}
				cmd("SetNumElements", currentParent.graphicID, currentParent.numKeys + 1);
				for (i = currentParent.numKeys; i > parentIndex; i--)
				{
					currentParent.children[i+1] = currentParent.children[i];
					cmd("Disconnect", currentParent.graphicID, currentParent.children[i].graphicID);
					cmd("Connect", currentParent.graphicID,  currentParent.children[i].graphicID, FOREGROUND_COLOR, 
					           0, // Curve
							   0, // Directed
							   "", // Label
								i+1);

					currentParent.keys[i] = currentParent.keys[i-1];
				    cmd("SetText", currentParent.graphicID, currentParent.keys[i] ,i);
				}
				currentParent.numKeys++;
				currentParent.keys[parentIndex] = risingNode;
				cmd("SetText", currentParent.graphicID, "", parentIndex);
				cmd("CreateLabel", moveLabel1ID, risingNode, getLabelX(tree, split_index),  tree.y)
				cmd("Move", moveLabel1ID,  getLabelX(currentParent, parentIndex),  currentParent.y)

				
				
				
				currentParent.children[parentIndex+1] = rightNode;
				rightNode.parent = currentParent;
				
			}
							
			

			var rightSplit:int;
			
			if (tree.isLeaf)
			{
				rightSplit = split_index;
				rightNode.next = tree.next;
				tree.next = rightNode;
			}
			else
			{
				rightSplit = split_index + 1;
			}
			
			rightNode.numKeys = tree.numKeys - rightSplit;

			cmd("CreateBTreeNode",rightNode.graphicID, WIDTH_PER_ELEM, NODE_HEIGHT, tree.numKeys -rightSplit, tree.x, tree.y,  BACKGROUND_COLOR, FOREGROUND_COLOR);

			if (tree.isLeaf)
			{
				if (rightNode.next != null)
				{
					
					cmd("Disconnect", tree.graphicID, rightNode.next.graphicID);
					cmd("Connect", rightNode.graphicID, 
						           rightNode.next.graphicID,
								   FOREGROUND_COLOR,
								   0, // Curve
								   1, // Directed
								   "", // Label
								   rightNode.numKeys);

				
				}
					cmd("Connect", tree.graphicID, 
						           rightNode.graphicID,
								   FOREGROUND_COLOR,
								   0, // Curve
								   1, // Directed
								   "", // Label
								   split_index);				
			}
			
			
			for (var i:int = rightSplit; i < tree.numKeys + 1; i++)
			{
				rightNode.children[i - rightSplit] = tree.children[i];
				if (tree.children[i] != null)
				{
					rightNode.isLeaf = false;
					cmd("Disconnect", tree.graphicID, tree.children[i].graphicID);
					
					cmd("Connect", rightNode.graphicID, 
						           rightNode.children[i - rightSplit].graphicID,
								   FOREGROUND_COLOR,
								   0, // Curve
								   0, // Directed
								   "", // Label
								   i - rightSplit);
					if (tree.children[i] != null)
					{
						tree.children[i].parent = rightNode;
					}
					tree.children[i] = null;
					
				}
			}
			for (i =rightSplit; i < tree.numKeys; i++)
			{
				rightNode.keys[i - rightSplit] = tree.keys[i];
				cmd("SetText", rightNode.graphicID, rightNode.keys[i -rightSplit], i - rightSplit);
			}
			var leftNode:BTreeNode = tree;
			leftNode.numKeys = split_index;
			// TO MAKE UNDO WORK -- CAN REMOVE LATER VV
			for (i = split_index; i < tree.numKeys; i++)
			{
				cmd("SetText", tree.graphicID, "", i); 
			}
			// TO MAKE UNDO WORK -- CAN REMOVE LATER ^^
			cmd("SetNumElements", tree.graphicID, split_index);
			
			if (tree.parent != null)
			{
				cmd("Connect", currentParent.graphicID, rightNode.graphicID, FOREGROUND_COLOR, 
					           0, // Curve
							   0, // Directed
							   "", // Label
								parentIndex + 1);
				resizeTree();
				cmd("Step")
				cmd("Delete", moveLabel1ID);				
				cmd("SetText", currentParent.graphicID, risingNode, parentIndex);
				return tree.parent;
			}
			else //			if (tree.parent == null)
			{
				treeRoot = new BTreeNode(nextIndex++, STARTING_X, STARTING_Y);
				cmd("CreateBTreeNode",treeRoot.graphicID, WIDTH_PER_ELEM, NODE_HEIGHT, 1, STARTING_X, STARTING_Y,BACKGROUND_COLOR,  FOREGROUND_COLOR);
				treeRoot.keys[0] = risingNode;
				cmd("SetText", treeRoot.graphicID, risingNode, 0);
				treeRoot.children[0] = leftNode;
				treeRoot.children[1] = rightNode;
				leftNode.parent = treeRoot;
				rightNode.parent = treeRoot;
				cmd("Connect", treeRoot.graphicID, leftNode.graphicID, FOREGROUND_COLOR, 
					               0, // Curve
								   0, // Directed
								   "", // Label
								   0);	// Connection Point
			    cmd("Connect", treeRoot.graphicID, rightNode.graphicID, FOREGROUND_COLOR, 
					               0, // Curve
								   0, // Directed
								   "", // Label
								   1); // Connection Point
				treeRoot.isLeaf = false;
				return treeRoot;
			}
			
			
			
		}
		
		function deleteElement(deletedValue:String):Array
		{
			commands = new Array();
			cmd("SetText", 0, "Deleting "+deletedValue);
			cmd("Step");
			cmd("SetText", 0, "");
			highlightID = nextIndex++;
			cmd("SetText", 0, "");
				doDelete(treeRoot, deletedValue);
			if (treeRoot.numKeys == 0)
			{
				cmd("Delete", treeRoot.graphicID);
				treeRoot = treeRoot.children[0];
				treeRoot.parent = null;
				resizeTree();
			}
			return commands;						
		}
		

		
		
		function doDelete(tree:BTreeNode, val:String):void
		{
			if (tree != null)
			{
				cmd("SetHighlight", tree.graphicID, 1);
				cmd("Step");
				for (var i:int = 0; i < tree.numKeys && tree.keys[i] < val; i++);
				if (i == tree.numKeys)
				{
					if (!tree.isLeaf)
					{
						cmd("SetEdgeHighlight", tree.graphicID, tree.children[tree.numKeys].graphicID, 1);
						cmd("Step");
						cmd("SetHighlight", tree.graphicID, 0);
						cmd("SetEdgeHighlight", tree.graphicID, tree.children[tree.numKeys].graphicID, 0);
						doDelete(tree.children[tree.numKeys], val);
					}
					else
					{
						cmd("SetHighlight", tree.graphicID, 0);
					}
				}
				else if (!tree.isLeaf && tree.keys[i] == val)
				{
						cmd("SetEdgeHighlight", tree.graphicID, tree.children[i+1].graphicID, 1);
						cmd("Step");
						cmd("SetHighlight", tree.graphicID, 0);
						cmd("SetEdgeHighlight", tree.graphicID, tree.children[i+1].graphicID, 0);					
						doDelete(tree.children[i+1], val);
				}
				else if (!tree.isLeaf)
				{
						cmd("SetEdgeHighlight", tree.graphicID, tree.children[i].graphicID, 1);
						cmd("Step");
						cmd("SetHighlight", tree.graphicID, 0);
						cmd("SetEdgeHighlight", tree.graphicID, tree.children[i].graphicID, 0);					
						doDelete(tree.children[i], val);			
				}
				else if (tree.isLeaf && tree.keys[i] == val)
				{
					cmd("SetTextColor", tree.graphicID, 0xFF0000, i);
					cmd("Step");
					cmd("SetTextColor", tree.graphicID, FOREGROUND_COLOR, i);
					for (var j:int = i; j < tree.numKeys - 1; j++)
					{
						tree.keys[j] = tree.keys[j+1];
						cmd("SetText", tree.graphicID, tree.keys[j], j);
					}
					tree.numKeys--;
					cmd("SetText", tree.graphicID, "", tree.numKeys);
					cmd("SetNumElements", tree.graphicID, tree.numKeys);
					cmd("SetHighlight", tree.graphicID, 0);
					
					if (tree.next != null)
					{
						cmd("Disconnect", tree.graphicID, tree.next.graphicID);
						cmd("Connect", tree.graphicID, 
									   tree.next.graphicID,
									   FOREGROUND_COLOR,
									   0, // Curve
									   1, // Directed
									   "", // Label
									   tree.numKeys);
					}
					
					// Bit of a hack -- if we remove the smallest element in a leaf, then find the *next* smallest element
					//  (somewhat tricky if the leaf is now empty!), go up our parent stack, and fix index keys
					if (i == 0 && tree.parent != null)
					{
						var nextSmallest:String = "";
						var parentNode:BTreeNode = tree.parent;
						for (var parentIndex:int = 0; parentNode.children[parentIndex] != tree; parentIndex++);
						if (tree.numKeys == 0)
						{
							if (parentIndex == parentNode.numKeys)
							{
								nextSmallest == "";
							}
							else
							{
								nextSmallest = parentNode.children[parentIndex+1].keys[0];			
							}
						}
						else
						{
							nextSmallest = tree.keys[0];
						}
						while (parentNode != null)
						{
							if (parentIndex > 0 && parentNode.keys[parentIndex - 1] == val)
							{
								parentNode.keys[parentIndex - 1] = nextSmallest;
								cmd("SetText", parentNode.graphicID, parentNode.keys[parentIndex - 1], parentIndex - 1);								
							}
							var grandParent = parentNode.parent;
							for (parentIndex = 0; grandParent != null && grandParent.children[parentIndex] != parentNode; parentIndex++);
							parentNode = grandParent;
							
						}
						
					}
					
					
					repairAfterDelete(tree);

				}
				else
				{
					cmd("SetHighlight", tree.graphicID, 0);
				}
			
			}
		}

		
		
		function mergeRight(tree:BTreeNode) :BTreeNode
		{
			cmd("SetText", messageID, "Merging node");

			var parentNode:BTreeNode = tree.parent;
			var parentIndex:int = 0;
			for (parentIndex = 0; parentNode.children[parentIndex] != tree; parentIndex++);
			var rightSib:BTreeNode = parentNode.children[parentIndex+1];
			cmd("SetHighlight", tree.graphicID, 1);
			cmd("SetHighlight", parentNode.graphicID, 1);
			cmd("SetHighlight", rightSib.graphicID, 1);

			cmd("Step");
			if (tree.isLeaf)
			{
				cmd("SetNumElements", tree.graphicID, tree.numKeys + rightSib.numKeys);
			}
			else
			{
				cmd("SetNumElements", tree.graphicID, tree.numKeys + rightSib.numKeys + 1);
				cmd("SetText", tree.graphicID, "", tree.numKeys);
				cmd("CreateLabel", moveLabel1ID, parentNode.keys[parentIndex],  getLabelX(parentNode, parentIndex),  parentNode.y);
				tree.keys[tree.numKeys] = parentNode.keys[parentIndex];
			}
			tree.x = (tree.x + rightSib.x) / 2
			cmd("SetPosition", tree.graphicID, tree.x,  tree.y);
			
			
			var fromParentIndex = tree.numKeys;
																	
		
			for (var i:int = 0; i < rightSib.numKeys; i++)
			{
				var insertIndex:int =  tree.numKeys + 1 + i;
				if (tree.isLeaf)
				{
					insertIndex -= 1;
				}
				tree.keys[insertIndex] = rightSib.keys[i];
				cmd("SetText", tree.graphicID, tree.keys[insertIndex], insertIndex);
				cmd("SetText", rightSib.graphicID, "", i);
			}
			if (!tree.isLeaf)
			{
				for (i = 0; i <= rightSib.numKeys; i++)
				{
					cmd("Disconnect", rightSib.graphicID, rightSib.children[i].graphicID);
					tree.children[tree.numKeys + 1 + i] = rightSib.children[i];
					tree.children[tree.numKeys + 1 + i].parent = tree;
					cmd("Connect", tree.graphicID, 
								   tree.children[tree.numKeys + 1 + i].graphicID,
								   FOREGROUND_COLOR,
								   0, // Curve
								   0, // Directed
								   "", // Label
								   tree.numKeys + 1 + i);
				}
				tree.numKeys = tree.numKeys + rightSib.numKeys + 1;

			}
			else
			{
				tree.numKeys = tree.numKeys + rightSib.numKeys;

				tree.next = rightSib.next;
				if (rightSib.next != null)
				{
					cmd("Connect", tree.graphicID, 
							   tree.next.graphicID,
							   FOREGROUND_COLOR,
							   0, // Curve
							   1, // Directed
							   "", // Label
							   tree.numKeys);				
					
				}
			}
			cmd("Disconnect", parentNode.graphicID, rightSib.graphicID);
			for (i = parentIndex+1; i < parentNode.numKeys; i++)
			{
				cmd("Disconnect", parentNode.graphicID, parentNode.children[i+1].graphicID);
				parentNode.children[i] = parentNode.children[i+1];
				cmd("Connect", parentNode.graphicID, 
							   parentNode.children[i].graphicID,
							   FOREGROUND_COLOR,
							   0, // Curve
							   0, // Directed
							   "", // Label
							   i);
				parentNode.keys[i-1] = parentNode.keys[i];
				cmd("SetText", parentNode.graphicID, parentNode.keys[i-1], i-1);					
			}
			cmd("SetText", parentNode.graphicID, "", parentNode.numKeys - 1);
			parentNode.numKeys--;
			cmd("SetNumElements", parentNode.graphicID, parentNode.numKeys);
			cmd("SetHighlight", tree.graphicID, 0);
			cmd("SetHighlight", parentNode.graphicID, 0);
			cmd("SetHighlight", rightSib.graphicID, 0);

			cmd("Delete", rightSib.graphicID);
			if (!tree.isLeaf)
			{
				cmd("Move", moveLabel1ID, getLabelX(tree, fromParentIndex), tree.y);
				cmd("Step");
				cmd("Delete", moveLabel1ID);
				cmd("SetText", tree.graphicID, tree.keys[fromParentIndex], fromParentIndex);
			}
			// resizeTree();

			cmd("SetText", messageID, "");
			return tree;
		}

		
		function stealFromRight(tree, parentIndex) :BTreeNode
		{
			// Steal from right sibling
			var parentNode:BTreeNode = tree.parent;

			cmd("SetNumElements", tree.graphicID, tree.numKeys+1);					
	
			cmd("SetText", messageID, "Stealing from right sibling");
	
			var rightSib:BTreeNode = parentNode.children[parentIndex + 1];
			tree.numKeys++;
			
			cmd("SetNumElements", tree.graphicID, tree.numKeys);
			
			if (tree.isLeaf)
			{
				cmd("Disconnect", tree.graphicID, tree.next.graphicID);
				cmd("Connect", tree.graphicID, 
							   tree.next.graphicID,
							   FOREGROUND_COLOR,
							   0, // Curve
							   1, // Directed
							   "", // Label
							   tree.numKeys);
			}
			
			
			cmd("SetText", tree.graphicID, "",  tree.numKeys - 1);
			cmd("SetText", parentNode.graphicID, "", parentIndex);
			cmd("SetText", rightSib.graphicID, "", 0);
			
			if (tree.isLeaf)
			{
				cmd("CreateLabel", moveLabel1ID, rightSib.keys[1], getLabelX(rightSib, 1),  rightSib.y)
				cmd("CreateLabel", moveLabel2ID, rightSib.keys[0], getLabelX(rightSib, 0),  rightSib.y)
				tree.keys[tree.numKeys - 1] = rightSib.keys[0];
				parentNode.keys[parentIndex] = rightSib.keys[1];
				
			}
			else
			{
				cmd("CreateLabel", moveLabel1ID, rightSib.keys[0], getLabelX(rightSib, 0),  rightSib.y)
				cmd("CreateLabel", moveLabel2ID, parentNode.keys[parentIndex], getLabelX(parentNode, parentIndex),  parentNode.y)
				tree.keys[tree.numKeys - 1] = parentNode.keys[parentIndex];
				parentNode.keys[parentIndex] = rightSib.keys[0];
			}
			
	
			cmd("Move", moveLabel1ID, getLabelX(parentNode, parentIndex),  parentNode.y);
			cmd("Move", moveLabel2ID, getLabelX(tree, tree.numKeys - 1), tree.y);
	
			cmd("Step")
			cmd("Delete", moveLabel1ID);
			cmd("Delete", moveLabel2ID);
			
			
			
			
			cmd("SetText", tree.graphicID, tree.keys[tree.numKeys - 1], tree.numKeys - 1);
			cmd("SetText", parentNode.graphicID, parentNode.keys[parentIndex], parentIndex);
			if (!tree.isLeaf)
			{
				tree.children[tree.numKeys] = rightSib.children[0];
				tree.children[tree.numKeys].parent = tree;
				cmd("Disconnect", rightSib.graphicID, rightSib.children[0].graphicID);
				cmd("Connect", tree.graphicID, 
					   tree.children[tree.numKeys].graphicID,
					   FOREGROUND_COLOR,
					   0, // Curve
					   0, // Directed
					   "", // Label
					   tree.numKeys);	
				// TODO::CHECKME!
				
				for (var i = 1; i < rightSib.numKeys + 1; i++)
				{
					cmd("Disconnect", rightSib.graphicID, rightSib.children[i].graphicID);
					rightSib.children[i-1] = rightSib.children[i];
					cmd("Connect", rightSib.graphicID, 
					   rightSib.children[i-1].graphicID,
					   FOREGROUND_COLOR,
					   0, // Curve
					   0, // Directed
					   "", // Label
					   i-1);								
				}
				
			}
			for (i = 1; i < rightSib.numKeys; i++)
			{
				rightSib.keys[i-1] = rightSib.keys[i];
				cmd("SetText", rightSib.graphicID, rightSib.keys[i-1], i-1);
			}
			cmd("SetText", rightSib.graphicID, "", rightSib.numKeys-1);
			rightSib.numKeys--;
			cmd("SetNumElements", rightSib.graphicID, rightSib.numKeys);
			resizeTree();
			cmd("SetText", messageID, "");
			
			if (tree.isLeaf)
			{

				if (rightSib.next != null)
				{
					cmd("Disconnect", rightSib.graphicID, rightSib.next.graphicID);
					cmd("Connect", rightSib.graphicID, 
								   rightSib.next.graphicID,
								   FOREGROUND_COLOR,
								   0, // Curve
								   1, // Directed
								   "", // Label
								   rightSib.numKeys);					
				}

			}
			return tree;
			
		}
		
		
		function stealFromLeft(tree, parentIndex) :BTreeNode
		{
			var parentNode:BTreeNode = tree.parent;
			// Steal from left sibling
			tree.numKeys++;
			cmd("SetNumElements", tree.graphicID, tree.numKeys);
			
			if (tree.isLeaf && tree.next != null)
			{
				
				cmd("Disconnect", tree.graphicID, tree.next.graphicID);
				cmd("Connect", tree.graphicID, 
							   tree.next.graphicID,
							   FOREGROUND_COLOR,
							   0, // Curve
							   1, // Directed
							   "", // Label
							   tree.numKeys);					
			}
			
			
			cmd("SetText", messageID, "Node has too few keys.  Stealing from left sibling.");
									
			for (i = tree.numKeys - 1; i > 0; i--)
			{
				tree.keys[i] = tree.keys[i-1];
				cmd("SetText", tree.graphicID, tree.keys[i], i);
			}
			var leftSib:BTreeNode = parentNode.children[parentIndex -1];
	
			cmd("SetText", tree.graphicID, "", 0);
			cmd("SetText", parentNode.graphicID, "", parentIndex - 1);
			cmd("SetText", leftSib.graphicID, "", leftSib.numKeys - 1);
			
			
			if (tree.isLeaf)
			{
				cmd("CreateLabel", moveLabel1ID, leftSib.keys[leftSib.numKeys - 1], getLabelX(leftSib, leftSib.numKeys - 1),  leftSib.y)
				cmd("CreateLabel", moveLabel2ID,leftSib.keys[leftSib.numKeys - 1], getLabelX(leftSib, leftSib.numKeys - 1),  leftSib.y)
				tree.keys[0] = leftSib.keys[leftSib.numKeys - 1];
				parentNode.keys[parentIndex-1] = leftSib.keys[leftSib.numKeys - 1];
			}
			else
			{
				cmd("CreateLabel", moveLabel1ID, leftSib.keys[leftSib.numKeys - 1], getLabelX(leftSib, leftSib.numKeys - 1),  leftSib.y)
				cmd("CreateLabel", moveLabel2ID, parentNode.keys[parentIndex - 1], getLabelX(parentNode, parentIndex - 1),  parentNode.y)
				tree.keys[0] = parentNode.keys[parentIndex - 1];
				parentNode.keys[parentIndex-1] = leftSib.keys[leftSib.numKeys - 1];				
			}
			cmd("Move", moveLabel1ID, getLabelX(parentNode, parentIndex - 1),  parentNode.y);
			cmd("Move", moveLabel2ID, getLabelX(tree, 0), tree.y);
	
			cmd("Step")
			cmd("Delete", moveLabel1ID);
			cmd("Delete", moveLabel2ID);
			
			
			if (!tree.isLeaf)
			{
				for (var i:int = tree.numKeys; i > 0; i--)
				{
					cmd("Disconnect", tree.graphicID, tree.children[i-1].graphicID);
					tree.children[i] =tree.children[i-1];
					cmd("Connect", tree.graphicID, 
						   tree.children[i].graphicID,
						   FOREGROUND_COLOR,
						   0, // Curve
						   0, // Directed
						   "", // Label
						   i);
				}
				tree.children[0] = leftSib.children[leftSib.numKeys];
				cmd("Disconnect", leftSib.graphicID, leftSib.children[leftSib.numKeys].graphicID);
				cmd("Connect", tree.graphicID, 
					   tree.children[0].graphicID,
					   FOREGROUND_COLOR,
					   0, // Curve
					   0, // Directed
					   "", // Label
					   0);
				leftSib.children[leftSib.numKeys] = null;
				tree.children[0].parent = tree;
	
			}
	
			cmd("SetText", tree.graphicID, tree.keys[0], 0);						
			cmd("SetText", parentNode.graphicID, parentNode.keys[parentIndex - 1], parentIndex - 1);
			cmd("SetText", leftSib.graphicID,"", leftSib.numKeys - 1);
	
			leftSib.numKeys--;
			cmd("SetNumElements", leftSib.graphicID, leftSib.numKeys);
			resizeTree();
			cmd("SetText", messageID, "");
			
			
			if (tree.isLeaf)
			{
				cmd("Disconnect", leftSib.graphicID, tree.graphicID);
				cmd("Connect", leftSib.graphicID, 
							   tree.graphicID,
							   FOREGROUND_COLOR,
							   0, // Curve
							   1, // Directed
							   "", // Label
							   leftSib.numKeys);

			}
			
			
			return tree;
		}
		
		
		function repairAfterDelete(tree:BTreeNode)
		{
			if (tree.numKeys < min_keys)
			{
				if (tree.parent == null)
				{
					if (tree.numKeys == 0)
					{
						cmd("Delete", tree.graphicID);
						treeRoot = tree.children[0];
						if (treeRoot != null)
							treeRoot.parent = null;
						resizeTree();
					}
				}
				else 
				{
					var parentNode:BTreeNode = tree.parent;
					for (var parentIndex:int = 0; parentNode.children[parentIndex] != tree; parentIndex++);
					
					
					if (parentIndex > 0 && parentNode.children[parentIndex - 1].numKeys > min_keys)
					{
						stealFromLeft(tree, parentIndex);

					}
					else if (parentIndex < parentNode.numKeys && parentNode.children[parentIndex + 1].numKeys > min_keys)
					{
						stealFromRight(tree,parentIndex);

					}
					else if (parentIndex == 0)
					{
						// Merge with right sibling
						var nextNode = mergeRight(tree);
						repairAfterDelete(nextNode.parent);			
					}
					else
					{
						// Merge with left sibling
						nextNode = mergeRight(parentNode.children[parentIndex-1]);
						repairAfterDelete(nextNode.parent);			

					}
					
					
				}
			}
			else if (tree.parent != null)
			{
				
				
			}
		}
		
		function getLabelX(tree:BTreeNode, index:int) : Number
		{
			return tree.x - WIDTH_PER_ELEM * tree.numKeys / 2 + WIDTH_PER_ELEM / 2 + index * WIDTH_PER_ELEM;
		}
			
		function resizeTree()
		{
			resizeWidths(treeRoot);
			setNewPositions(treeRoot, STARTING_X, STARTING_Y);
			animateNewPositions(treeRoot);
		}
			
		function setNewPositions(tree, xPosition, yPosition)
		{
			if (tree != null)
			{
				tree.y = yPosition;
				tree.x = xPosition;
				if (!tree.isLeaf)
				{
					var leftEdge = xPosition - tree.width / 2;
					var priorWidth = 0;
					for (var i:int = 0; i < tree.numKeys+1; i++)
					{
						setNewPositions(tree.children[i], leftEdge + priorWidth + tree.widths[i] / 2, yPosition+HEIGHT_DELTA);
						priorWidth += tree.widths[i];
					}
				}				
			}			
		}
		
		function animateNewPositions(tree)
		{
			if (tree == null)
			{
				return;
			}
			for (var i:int = 0; i < tree.numKeys + 1; i++)
			{
				animateNewPositions(tree.children[i]);
			}
			cmd("Move", tree.graphicID, tree.x, tree.y);
		}
		
		function resizeWidths(tree:BTreeNode) : int
		{
			if (tree == null)
			{
				return 0;
			}
			if (tree.isLeaf)
			{
				for (var i:int = 0; i < tree.numKeys + 1; i++)
				{
					tree.widths[i] = 0;
				}
				tree.width = tree.numKeys * WIDTH_PER_ELEM + NODE_SPACING;
				return tree.width;				
			}
			else
			{
				var treeWidth:int = 0;
				for (i = 0; i < tree.numKeys+1; i++)
				{
					tree.widths[i] = resizeWidths(tree.children[i]);
					treeWidth = treeWidth + tree.widths[i];
				}
				treeWidth = Math.max(treeWidth, tree.numKeys * WIDTH_PER_ELEM + NODE_SPACING);
				tree.width = treeWidth;
				return treeWidth;
			}
		}
	}
}

