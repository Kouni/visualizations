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


	public class DFS extends Graph
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
		static const DFS_TREE_COLOR = 0x0000FF;
		
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
		
		function DFS(am)
		{
			showEdgeCosts = false;
			var startLabel:TextField = new TextField();
			startLabel.text = "Start Vertex";
			startLabel.x = 2;
			addChild(startLabel);
			enterFieldStart = addTextInput(75,2,100,20,true);
			startButton = new Button();
			startButton.label = "Run DFS";
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
					implementAction(doDFS,startvalue);
			}
		}
		
		
			
		function doDFS(startVetex)
		{
			visited = new Array(size);
			commands = new Array();
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
			}
			var vertex:int = int(startVetex);
			cmd("CreateHighlightCircle", highlightCircleL, HIGHLIGHT_CIRCLE_COLOR, x_pos_logical[vertex], y_pos_logical[vertex]);
			cmd("SetLayer", highlightCircleL, 1);
			cmd("CreateHighlightCircle", highlightCircleAL, HIGHLIGHT_CIRCLE_COLOR,adj_list_x_start - adj_list_width, adj_list_y_start + vertex*adj_list_height);
			cmd("SetLayer", highlightCircleAL, 2);
							
			cmd("CreateHighlightCircle", highlightCircleAM, HIGHLIGHT_CIRCLE_COLOR,adj_matrix_x_start  - adj_matrix_width, adj_matrix_y_start + vertex*adj_matrix_height);
			cmd("SetLayer", highlightCircleAM, 3);

			messageY = 30;
			dfsVisit(vertex, 10);
			cmd("Delete", highlightCircleL);
			cmd("Delete", highlightCircleAL);
			cmd("Delete", highlightCircleAM);
			return commands

		}
		
		
		function dfsVisit(startVertex, messageX)
		{
			var nextMessage:int = nextIndex++;
			messageID.push(nextMessage);
			
			cmd("CreateLabel",nextMessage, "DFS(" +  String(startVertex) +  ")", messageX, messageY, 0);
			messageY = messageY + 20;
			if (!visited[startVertex])
			{
				visited[startVertex] = true;
				cmd("SetText", visitedID[startVertex], "T");
				cmd("Step");
				for (var neighbor:int = 0; neighbor < size; neighbor++)
				{
					if (adj_matrix[startVertex][neighbor] > 0)
					{
						highlightEdge(startVertex, neighbor, 1);
						cmd("SetHighlight", visitedID[neighbor], 1);
						if (visited[neighbor])
						{
							nextMessage = nextIndex;
							cmd("CreateLabel", nextMessage, "Vertex " + String(neighbor) + " already visited.", messageX, messageY, 0);
						}
						cmd("Step");
						highlightEdge(startVertex, neighbor, 0);
						cmd("SetHighlight", visitedID[neighbor], 0);
						if (visited[neighbor])
						{
							cmd("Delete", nextMessage);
						}

						if (!visited[neighbor])
						{
							cmd("Disconnect", circleID[startVertex], circleID[neighbor]);
							cmd("Connect", circleID[startVertex], circleID[neighbor], DFS_TREE_COLOR, curve[startVertex][neighbor], 1, "");
							cmd("Move", highlightCircleL, x_pos_logical[neighbor], y_pos_logical[neighbor]);
							cmd("Move", highlightCircleAL, adj_list_x_start - adj_list_width, adj_list_y_start + neighbor*adj_list_height);
							cmd("Move", highlightCircleAM, adj_matrix_x_start - adj_matrix_width, adj_matrix_y_start + neighbor*adj_matrix_height);

							cmd("SetText", parentID[neighbor], startVertex);
							cmd("Step");
							dfsVisit(neighbor, messageX + 20);							
							nextMessage = nextIndex;
							cmd("CreateLabel", nextMessage, "Returning from recursive call: DFS(" + String(neighbor) + ")", messageX + 20, messageY, 0);

							cmd("Move", highlightCircleAL, adj_list_x_start - adj_list_width, adj_list_y_start + startVertex*adj_list_height);
							cmd("Move", highlightCircleL, x_pos_logical[startVertex], y_pos_logical[startVertex]);
							cmd("Move", highlightCircleAM, adj_matrix_x_start - adj_matrix_width, adj_matrix_y_start + startVertex*adj_matrix_height);
							cmd("Step");
							cmd("Delete", nextMessage);
						}
						cmd("Step");

						
						
					}
					
				}
				
			}
			
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