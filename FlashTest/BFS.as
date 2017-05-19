package 
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.display.DisplayObjectContainer;
	import fl.controls.Button;
	import fl.controls.TextInput;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import fl.events.ComponentEvent;
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;

	import flash.events.Event;


	public class BFS extends Graph
	{
		// Input Controls
		var startButton:Button;
		var enterFieldStart:TextInput;
		
		static const AUX_ARRAY_WIDTH = 25;
		static const AUX_ARRAY_HEIGHT = 25;
		static const AUX_ARRAY_START_Y = 100;
		
		static const VISITED_START_X = 475;
		static const PARENT_START_X = 400;
		
		static const HIGHLIGHT_CIRCLE_COLOR = 0x000000;
		static const BFS_TREE_COLOR = 0x0000FF;
		static const BFS_QUEUE_HEAD_COLOR = 0xFF0000;
		
		
		static const QUEUE_START_X = 30;
		static const QUEUE_START_Y = 100;
		static const QUEUE_SPACING = 30;
		
		
		var visitedID: Array;
		var visitedIndexID: Array;
		
		var parentID: Array;
		var parentIndexID: Array;
		var visited:Array;
		var messageID:Array;
		
		var highlightCircleL:int;
		var highlightCircleAL:int;
		var highlightCircleAM:int;
		var messageY:int;
		var queue:Array;
		
		
		function BFS(am)
		{
			showEdgeCosts = false;
			var startLabel:TextField = new TextField();
			startLabel.text = "Start Vertex";
			startLabel.x = 2;
			addChild(startLabel);
			enterFieldStart = addTextInput(75,2,100,20,true);
			startButton = new Button();
			startButton.label = "Run BFS";
			startButton.x = 175;			
			startButton.y = 2;			
			addChild(startButton);
			
			fieldAcceptsIntegerOnly(enterFieldStart, true);
			
			startButton.addEventListener(MouseEvent.MOUSE_DOWN, startCallback);
			enterFieldStart.addEventListener(ComponentEvent.ENTER, startCallback);
			super(am);
			
		}
		
		
		override function setup() : void
		{
			super.setup();
			messageID = new Array();
			commands = new Array();
			visitedID = new Array(size);
			visitedIndexID = new Array(size);
			parentID = new Array(size);
			parentIndexID = new Array(size);
			
			for (var i:int = 0; i < size; i++)
			{
				visitedID[i] = nextIndex++;
				visitedIndexID[i] = nextIndex++;
				parentID[i] = nextIndex++;
				parentIndexID[i] = nextIndex++;
				cmd("CreateRectangle", visitedID[i], "f", AUX_ARRAY_WIDTH, AUX_ARRAY_HEIGHT, VISITED_START_X, AUX_ARRAY_START_Y + i*AUX_ARRAY_HEIGHT);
				cmd("CreateLabel", visitedIndexID[i], i, VISITED_START_X - AUX_ARRAY_WIDTH , AUX_ARRAY_START_Y + i*AUX_ARRAY_HEIGHT);
				cmd("SetForegroundColor",  visitedIndexID[i], VERTEX_INDEX_COLOR);
				cmd("CreateRectangle", parentID[i], "", AUX_ARRAY_WIDTH, AUX_ARRAY_HEIGHT, PARENT_START_X, AUX_ARRAY_START_Y + i*AUX_ARRAY_HEIGHT);
				cmd("CreateLabel", parentIndexID[i], i, PARENT_START_X - AUX_ARRAY_WIDTH , AUX_ARRAY_START_Y + i*AUX_ARRAY_HEIGHT);
				cmd("SetForegroundColor",  parentIndexID[i], VERTEX_INDEX_COLOR);
				
			}
			cmd("CreateLabel", nextIndex++, "Parent", PARENT_START_X - AUX_ARRAY_WIDTH, AUX_ARRAY_START_Y - AUX_ARRAY_HEIGHT * 1.5, 0);
			cmd("CreateLabel", nextIndex++, "Visited", VISITED_START_X - AUX_ARRAY_WIDTH, AUX_ARRAY_START_Y - AUX_ARRAY_HEIGHT * 1.5, 0);
			cmd("CreateLabel", nextIndex++, "BFS Queue", QUEUE_START_X, QUEUE_START_Y - 30, 0);
			animationManager.setAllLayers(0, currentLayer);
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			animationManager.clearHistory();
			highlightCircleL = nextIndex++;
		   	highlightCircleAL = nextIndex++;
			highlightCircleAM= nextIndex++
		}
		
		function startCallback(event)
		{
			var insertedValue:String;

			if (enterFieldStart.text != "")
			{
				var startvalue:String = enterFieldStart.text;
				enterFieldStart.text = "";
				if (int(startvalue) < size)
					implementAction(doBFS,startvalue);
			}
		}
		
		
			
		function doBFS(startVetex)
		{
			visited = new Array(size);
			commands = new Array();
			queue = new Array(size);
			var head:int = 0;
			var tail:int = 0;
			var queueID = new Array(size);
			var queueSize:int = 0;

			if (messageID != null)
			{
				for (var i:int = 0; i < messageID.length; i++)
				{
					cmd("Delete", messageID[i]);
				}
			}
						
			rebuildEdges();
			messageID = new Array();
			for (i = 0; i < size; i++)
			{
				cmd("SetText", visitedID[i], "f");
				cmd("SetText", parentID[i], "");
				visited[i] = false;
				queueID[i] = nextIndex++;
				
			}
			var vertex:int = int(startVetex);
			visited[vertex] = true;
			queue[tail] = vertex;			
			cmd("CreateLabel", queueID[tail],  vertex, QUEUE_START_X + queueSize * QUEUE_SPACING, QUEUE_START_Y);
			queueSize = queueSize + 1;
			tail = (tail + 1) % (size);
			
			
			while (queueSize > 0)
			{
				vertex = queue[head];
				cmd("CreateHighlightCircle", highlightCircleL, HIGHLIGHT_CIRCLE_COLOR, x_pos_logical[vertex], y_pos_logical[vertex]);
				cmd("SetLayer", highlightCircleL, 1);
				cmd("CreateHighlightCircle", highlightCircleAL, HIGHLIGHT_CIRCLE_COLOR,adj_list_x_start - adj_list_width, adj_list_y_start + vertex*adj_list_height);
				cmd("SetLayer", highlightCircleAL, 2);
				cmd("CreateHighlightCircle", highlightCircleAM, HIGHLIGHT_CIRCLE_COLOR,adj_matrix_x_start  - adj_matrix_width, adj_matrix_y_start + vertex*adj_matrix_height);
				cmd("SetLayer", highlightCircleAM, 3);
				
				cmd("SetTextColor", queueID[head], BFS_QUEUE_HEAD_COLOR);
				

				for (var neighbor:int = 0; neighbor < size; neighbor++)
				{
					if (adj_matrix[vertex][neighbor] > 0)
					{
						highlightEdge(vertex, neighbor, 1);
						cmd("SetHighlight", visitedID[neighbor], 1);
						cmd("Step");
						if (!visited[neighbor])
						{
							visited[neighbor] = true;
							cmd("SetText", visitedID[neighbor], "T");
							cmd("SetText", parentID[neighbor], vertex);
							highlightEdge(vertex, neighbor, 0);
							cmd("Disconnect", circleID[vertex], circleID[neighbor]);
							cmd("Connect", circleID[vertex], circleID[neighbor], BFS_TREE_COLOR, curve[vertex][neighbor], 1, "");
							queue[tail] = neighbor;
							cmd("CreateLabel", queueID[tail],  neighbor, QUEUE_START_X + queueSize * QUEUE_SPACING, QUEUE_START_Y);
							tail = (tail + 1) % (size);
							queueSize = queueSize + 1;
						}
						else
						{
							highlightEdge(vertex, neighbor, 0);
						}
						cmd("SetHighlight", visitedID[neighbor], 0);
						cmd("Step");						
					}

				}
				cmd("Delete", queueID[head]);
				head = (head + 1) % (size);
				queueSize = queueSize - 1;
				for (i = 0; i < queueSize; i++)
				{
					var nextQueueIndex = (i + head) % size;
					cmd("Move", queueID[nextQueueIndex], QUEUE_START_X + i * QUEUE_SPACING, QUEUE_START_Y);
				}

				cmd("Delete", highlightCircleL);
				cmd("Delete", highlightCircleAM);
				cmd("Delete", highlightCircleAL);
				
			}
			
			return commands

		}
		
		
		
		// NEED TO OVERRIDE IN PARENT
		override function reset()
		{
			// Throw an error?
		}
		
		
		
		
		override function enableUI(event:AnimationStateEvent):void
		{			
			startButton.enabled = true;
			enterFieldStart.addEventListener(ComponentEvent.ENTER, startCallback);
			enterFieldStart.enabled = true;

			super.enableUI(event);
		}
		override function disableUI(event:AnimationStateEvent):void
		{
			startButton.enabled = false;
			enterFieldStart.removeEventListener(ComponentEvent.ENTER, startCallback);
			enterFieldStart.enabled = false;

			super.disableUI(event);
		}
	}
}