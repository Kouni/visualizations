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


	public class DijkstraPrim extends Graph
	{
		// Input Controls
		var startButton:Button;
		var enterFieldStart:TextInput;
		
		
		static const TABLE_ENTRY_WIDTH = 50;
		static const TABLE_ENTRY_HEIGHT = 25;
		static const TABLE_START_X = 50;
		static const TABLE_START_Y = 70;
		
		
		static const HIGHLIGHT_CIRCLE_COLOR = 0x000000;
		static const BFS_TREE_COLOR = 0x0000FF;
		static const BFS_QUEUE_HEAD_COLOR = 0xFF0000;
		
		
		static const QUEUE_START_X = 30;
		static const QUEUE_START_Y = 100;
		static const QUEUE_SPACING = 30;
		
		
		var visitedID: Array;
		var visitedIndexID: Array;
		
		
		var vertexID: Array;
		var knownID: Array;
		var distanceID: Array;
		var pathID: Array;
		var known: Array;
		var distance: Array;
		var path: Array;
		var comparisonMessageID: int;
		var messageID:Array;

		
		var runningDijkstra:Boolean;
		
		function DijkstraPrim(am, runDijkstra:Boolean = true )
		{
			runningDijkstra = runDijkstra;
			showEdgeCosts = true;
			directed = false;
			var startLabel:TextField = new TextField();
			startLabel.text = "Start Vertex";
			startLabel.x = 2;
			addChild(startLabel);
			enterFieldStart = addTextInput(75,2,100,20,true);
			startButton = new Button();
			if (runningDijkstra)
			{
				startButton.label = "Run Dijkstra";
			}
			else
			{
				startButton.label = "Run Prim";				
			}
			startButton.x = 175;			
			startButton.y = 2;			
			addChild(startButton);
			
			fieldAcceptsIntegerOnly(enterFieldStart, true);
			
			startButton.addEventListener(MouseEvent.MOUSE_DOWN, startCallback);
			enterFieldStart.addEventListener(ComponentEvent.ENTER, startCallback);
			super(am);
			if (!runningDijkstra)
			{
				removeChild(undirectedGraphButton);
				removeChild(directedGraphButton);
			}
			
		}
		
		
		override function setup() : void
		{
			super.setup();
			commands = new Array();
			
			
			vertexID = new Array(size);
			knownID = new Array(size);
		 	distanceID = new Array(size);
			pathID = new Array(size);
			known = new Array(size);
			distance = new Array(size);
			path = new Array(size);
						
			for (var i:int = 0; i < size; i++)
			{
				vertexID[i] = nextIndex++;
				knownID[i] = nextIndex++;
				distanceID[i] = nextIndex++;
				pathID[i] = nextIndex++;
				cmd("CreateRectangle", vertexID[i], i, TABLE_ENTRY_WIDTH, TABLE_ENTRY_HEIGHT, TABLE_START_X, TABLE_START_Y + i*TABLE_ENTRY_HEIGHT);
				cmd("CreateRectangle", knownID[i], "", TABLE_ENTRY_WIDTH, TABLE_ENTRY_HEIGHT, TABLE_START_X + TABLE_ENTRY_WIDTH, TABLE_START_Y + i*TABLE_ENTRY_HEIGHT);
				cmd("CreateRectangle", distanceID[i], "", TABLE_ENTRY_WIDTH, TABLE_ENTRY_HEIGHT, TABLE_START_X + 2 * TABLE_ENTRY_WIDTH, TABLE_START_Y + i*TABLE_ENTRY_HEIGHT);
				cmd("CreateRectangle", pathID[i], "", TABLE_ENTRY_WIDTH, TABLE_ENTRY_HEIGHT, TABLE_START_X+ 3 * TABLE_ENTRY_WIDTH, TABLE_START_Y + i*TABLE_ENTRY_HEIGHT);
				cmd("SetTextColor",  vertexID[i], VERTEX_INDEX_COLOR);
				
			}
			cmd("CreateLabel", nextIndex++, "Vertex", TABLE_START_X, TABLE_START_Y  - TABLE_ENTRY_HEIGHT);
			cmd("CreateLabel", nextIndex++, "Known", TABLE_START_X + TABLE_ENTRY_WIDTH, TABLE_START_Y  - TABLE_ENTRY_HEIGHT);
			cmd("CreateLabel", nextIndex++, "Cost", TABLE_START_X + 2 * TABLE_ENTRY_WIDTH, TABLE_START_Y  - TABLE_ENTRY_HEIGHT);
			cmd("CreateLabel", nextIndex++, "Path", TABLE_START_X + 3 * TABLE_ENTRY_WIDTH, TABLE_START_Y  - TABLE_ENTRY_HEIGHT);
			
			animationManager.setAllLayers(0, currentLayer);
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			animationManager.clearHistory();
			comparisonMessageID = nextIndex++;
		}
		
		function startCallback(event)
		{
			var insertedValue:String;

			if (enterFieldStart.text != "")
			{
				var startvalue:String = enterFieldStart.text;
				enterFieldStart.text = "";
				if (int(startvalue) < size)
					implementAction(doDijkstraPrim,startvalue);
			}
		}
		
		
		function findCheapestUnknown() : int
		{
			var bestIndex:int = -1;
			for (var i = 0; i < size; i++)
			{
				if (!known[i] && distance[i] != -1 && (bestIndex == -1 ||
								  (distance[i] < distance[bestIndex])))
				{
					bestIndex = i;
				}
			}
			if (bestIndex == -1)
			{
				var x = 3;
				x = x + 2;
			}
			return bestIndex;
		}
	
			
		function doDijkstraPrim(startVertex)
		{
			commands = new Array();
			
			if (!runningDijkstra)
			{
				recolorGraph();
			}
			
			
			var current:int = int(startVertex);
			
			for (var i:int = 0; i < size; i++)
			{
				known[i] = false;
				distance[i] = -1;
				path[i] = -1;
				cmd("SetText", knownID[i], "F");
				cmd("SetText", distanceID[i], "INF");
				cmd("SetText", pathID[i], "-1");
				cmd("SetTextColor", knownID[i], 0x000000);

			}
			if (messageID != null)
			{
				for (i = 0; i < messageID.length; i++)
				{
					cmd("Delete", messageID[i]);
				}				
			}
			messageID = new Array();
			
			distance[current] = 0;
			cmd("SetText", distanceID[current], 0);
			
			for (i = 0; i < size; i++)
			{
				current = findCheapestUnknown();
				if (current < 0)
				{
					break;
				}
				cmd("SetHighlight", circleID[current], 1);
				known[current] = true;
				cmd("SetText", knownID[current], "T");
				cmd("SetTextColor", knownID[current], 0xAAAAAA);
				for (var neighbor:int = 0; neighbor < size; neighbor++)
				{
					if (adj_matrix[current][neighbor] >= 0)
					{
						highlightEdge(current, neighbor, 1);
						if (known[neighbor])
						{

							cmd("CreateLabel",  comparisonMessageID,"Vertex " + String(neighbor) + " known", 
									 TABLE_START_X + 5 * TABLE_ENTRY_WIDTH,TABLE_START_Y + neighbor*TABLE_ENTRY_HEIGHT);
							cmd("SetHighlight", knownID[neighbor], 1);
						}
						else
						{	cmd("SetHighlight", distanceID[current], 1);
							cmd("SetHighlight", distanceID[neighbor], 1);
							var distString:String = String(distance[neighbor]);
							if (distance[neighbor] < 0)
							{
								distString = "INF";
							}

							if (runningDijkstra)
							{
								if (distance[neighbor] < 0 || distance[neighbor] > distance[current] + adj_matrix[current][neighbor])
								{
									cmd("CreateLabel", comparisonMessageID, distString + " > " + String(distance[current]) + " + " + String(adj_matrix[current][neighbor]), 
											 TABLE_START_X + 4.3 * TABLE_ENTRY_WIDTH,TABLE_START_Y + neighbor*TABLE_ENTRY_HEIGHT);
								}
								else
								{
									cmd("CreateLabel",  comparisonMessageID,"!(" + String(distance[neighbor])  + " > " + String(distance[current]) + " + " + String(adj_matrix[current][neighbor]) + ")", 
											 TABLE_START_X + 4.3 * TABLE_ENTRY_WIDTH,TABLE_START_Y + neighbor*TABLE_ENTRY_HEIGHT);							
								}								
								
							}
							else
							{
								if (distance[neighbor] < 0 || distance[neighbor] > adj_matrix[current][neighbor])
								{
									cmd("CreateLabel", comparisonMessageID, distString + " > " + String(adj_matrix[current][neighbor]), 
											 TABLE_START_X + 4.3 * TABLE_ENTRY_WIDTH,TABLE_START_Y + neighbor*TABLE_ENTRY_HEIGHT);
								}
								else
								{
									cmd("CreateLabel",  comparisonMessageID,"!(" + String(distance[neighbor])  + " > " + String(adj_matrix[current][neighbor]) + ")", 
											 TABLE_START_X + 4.3 * TABLE_ENTRY_WIDTH,TABLE_START_Y + neighbor*TABLE_ENTRY_HEIGHT);							
								}
								
								
							}


						}
						
						circleID[i]
						cmd("Step");
						cmd("Delete", comparisonMessageID);
						highlightEdge(current, neighbor, 0);
						if (known[neighbor])
						{
							cmd("SetHighlight", knownID[neighbor], 0);

						}
						else
						{
							cmd("SetHighlight", distanceID[current], 0);
							cmd("SetHighlight", distanceID[neighbor], 0);
							if (runningDijkstra)
							{
								var compare = distance[current] + adj_matrix[current][neighbor];
							}
							else
							{
								compare = adj_matrix[current][neighbor];
							}
							if (distance[neighbor] < 0 || distance[neighbor] > compare)
							{
								distance[neighbor] =  compare;
								path[neighbor] = current;
								cmd("SetText", distanceID[neighbor],distance[neighbor] );
								cmd("SetText", pathID[neighbor],path[neighbor]);
							}
						}

					}
				}
				cmd("SetHighlight", circleID[current], 0);

				
			}
			// Running Dijkstra's algorithm, create the paths
			if (runningDijkstra)
			{
				createPaths();
			}
			// Running Prim's algorithm, highlight the tree
			else
			{
				highlightTree();
			}
			
			return commands
		}
		
		function createPaths()
		{
			for (var vertex:int = 0; vertex < size; vertex++)
			{
				var nextLabelID = nextIndex++;
				if (distance[vertex] < 0)
				{
					cmd("CreateLabel", nextLabelID, "No Path",  TABLE_START_X + 4.3 * TABLE_ENTRY_WIDTH,TABLE_START_Y + vertex*TABLE_ENTRY_HEIGHT);
					messageID.push(nextLabelID);
				}
				else
				{
					cmd("CreateLabel", nextLabelID, vertex,  TABLE_START_X + 4.3 * TABLE_ENTRY_WIDTH,TABLE_START_Y + vertex*TABLE_ENTRY_HEIGHT);
					messageID.push(nextLabelID);
					var pathList:Array = [nextLabelID];
					var nextInPath = vertex;
					while (nextInPath >= 0)
					{
						cmd("SetHighlight", pathID[nextInPath], 1);
						cmd("Step");
						if (path[nextInPath] != -1)
						{
							nextLabelID = nextIndex++;
							cmd("CreateLabel", nextLabelID, path[nextInPath],  TABLE_START_X + 3 * TABLE_ENTRY_WIDTH,TABLE_START_Y + nextInPath*TABLE_ENTRY_HEIGHT);
							cmd("Move", nextLabelID,  TABLE_START_X + 4.3 * TABLE_ENTRY_WIDTH,TABLE_START_Y + vertex*TABLE_ENTRY_HEIGHT);
							messageID.push(nextLabelID);
							for (var i = pathList.length - 1; i >= 0; i--)
							{
								cmd("Move", pathList[i], TABLE_START_X + 4.3 * TABLE_ENTRY_WIDTH + (pathList.length - i) * 17,TABLE_START_Y + vertex*TABLE_ENTRY_HEIGHT)
								
							}
							cmd("Step");
							pathList.push(nextLabelID);
						}
						cmd("SetHighlight", pathID[nextInPath], 0);
						nextInPath = path[nextInPath];
						
					}					
				}
			}
		}
		
		function highlightTree()
		{
			for (var vertex:int = 0; vertex < size; vertex++)
			{
				if (path[vertex] >= 0)
				{
					cmd("SetHighlight", vertexID[vertex], 1)
					cmd("SetHighlight", pathID[vertex], 1);
					highlightEdge(vertex, path[vertex], 1)
					highlightEdge(path[vertex], vertex, 1)
					cmd("Step");
					cmd("SetHighlight", vertexID[vertex], 0)
					cmd("SetHighlight", pathID[vertex], 0);
					highlightEdge(vertex, path[vertex], 0)
					highlightEdge(path[vertex], vertex, 0)
					setEdgeColor(vertex, path[vertex], 0xFF0000);				
					setEdgeColor(path[vertex], vertex, 0xFF0000);				
				}
			}			
		}
		
		override function reset()
		{
			messageID = new Array();
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