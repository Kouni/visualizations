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


	public class Graph extends AlgorithmAnimation
	{
		// Input Controls
		var logicalRepButton:RadioButton;
		var adjListRepButton:RadioButton;
		var adjMatrixRepButton:RadioButton;
		var graphRepGroup:RadioButtonGroup;
		var newGraphButton:Button;
		var smallGraphButton:RadioButton;
		var largeGraphButton:RadioButton;
		var graphSizeGroup:RadioButtonGroup;
		var directedGraphButton:RadioButton;
		var undirectedGraphButton:RadioButton;
		var directedGroup:RadioButtonGroup;
		
		var nextIndex = 0;
		var logicalRepresentation:Boolean = true;
		
		
		static const LARGE_ALLOWED:Array = [[false, true, true, false, true, false, false, true, false, false, false, false, false, false, true, false, false, false],
										    [true, false, true, false, true, true,  false, false, false, false, false, false, false, false, false, false, false, false],
											[true, true, false, true,  false, true, true,  false, false, false, false, false, false, false, false, false, false, false],
											[false, false, true, false, false,false, true, false, false, false, true, false, false,  false, false, false, false, true],
											[true, true, false, false,  false, true, false, true, true, false, false, false, false, false, false, false,  false,  false],
											[false, true, true, false, true, false, true,   false, true, true, false, false, false, false, false, false,  false,  false],
											[false, false, true, true, false, true, false, false, false, true, true, false, false, false, false, false,  false,  false],
											[true, false, false, false, true, false, false, false, true, false, false, true, false, false, true, false, false, false],
											[false, false, false, false, true, true, false, true, false, true, false, true, true, false,   false, false, false, false],
											[false, false, false, false, false, true, true, false, true, false, true, false, true, true,  false,  false, false, false],
											[false, false, false, true, false,  false, true, false, false, true, false, false, false, true, false, false, false, true],
											[false, false, false, false, false, false, false, true, true, false, false, false, true, false, true, true, false, false],
											[false, false, false, false, false, false, false, false, true, true, false, true, false, true, false, true, true, false],
											[false, false, false, false, false, false, false, false, false, true, true, false, true, false, false, false, true, true],
											[false, false, false, false, false, false, false, true, false, false, false, true, false, false, false, true, false, false],
											[false, false, false, false, false, false, false, false, false, false, false, true, true, false, true, false, true, true],
											[false, false, false, false, false, false, false, false, false, false, false, false, true, true, false, true, false, true],
											[false, false, false, false, false, false, false, false, false, false, true, false, false, true, false, true, true, false]];
		
		static const LARGE_CURVE:Array  = [[0, 0, -0.4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.25, 0, 0, 0],
										   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
										   [0.4, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
										   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.25],
										   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
										   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
										   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
										   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
										   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
										   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
										   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
										   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
										   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
										   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
										   [-0.25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
										   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0.4],
										   [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0],
										   [0, 0, 0, 0.25, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, -0.4, 0, 0]]
		

		
		static const LARGE_X_POS_LOGICAL:Array = [600, 700, 800, 900,
												    650, 750, 850,
												  600, 700, 800, 900,
												    650, 750, 850,
												  600, 700, 800, 900];
		
		
		static const LARGE_Y_POS_LOGICAL:Array = [125, 125, 125, 125,
												      225, 225, 225,
												  325, 325, 325, 325, 
												      425, 425, 425, 
												  525,  525, 525, 525];

		
		static const SMALL_ALLLOWED:Array = [[false, true,  true,  true,  true,  false, false, false],
					                         [true,  false, true,  true,  false, true,  true,  false],
		                                     [true,  true,  false, false, true,  true,  true,  false],
									         [true,  true,  false, false, false, true,  false, true],
									         [true,  false, true,  false, false,  false, true,  true],
							         		 [false, true,  true,  true,  false, false, true,  true],
								         	 [false, true,  true,  false, true,  true,  false, true],
								         	 [false, false, false, true,  true,  true,  true,  false]];
		
		static const SMALL_CURVE:Array = [[0, 0.001, 0, 0.5, -0.5, 0, 0, 0],
								         [0, 0, 0, 0.001, 0, 0.001, -0.2, 0],
								         [0, 0.001, 0, 0, 0, 0.2, 0, 0],
		        						 [-0.5, 0, 0, 0, 0, 0.001, 0, 0.5],
								         [0.5, 0, 0, 0, 0, 0, 0, -0.5],
								         [0, 0, -0.2, 0, 0, 0, 0.001, 0.001],
        								 [0, 0.2, 0, 0, 0, 0, 0, 0],
								         [0, 0, 0, -0.5, 0.5, 0, 0, 0]]
		
		static const SMALL_X_POS_LOGICAL:Array = [800, 725, 875, 650, 950, 725, 875, 800];
		static const SMALL_Y_POS_LOGICAL:Array = [125, 225, 225, 325, 325, 425, 425, 525];
		
		
		static const SMALL_ADJ_MATRIX_X_START = 700;
		static const SMALL_ADJ_MATRIX_Y_START = 150;
		static const SMALL_ADJ_MATRIX_WIDTH = 30;
		static const SMALL_ADJ_MATRIX_HEIGHT = 30;
		
		static const SMALL_ADJ_LIST_X_START = 600;
		static const SMALL_ADJ_LIST_Y_START = 150;
		
		static const SMALL_ADJ_LIST_ELEM_WIDTH = 50;
		static const SMALL_ADJ_LIST_ELEM_HEIGHT = 30;

		static const SMALL_ADJ_LIST_HEIGHT = 36;
		static const SMALL_ADJ_LIST_WIDTH = 36;

		static const SMALL_ADJ_LIST_SPACING = 10;
		
		
		static const LARGE_ADJ_MATRIX_X_START = 575;
		static const LARGE_ADJ_MATRIX_Y_START = 150;
		static const LARGE_ADJ_MATRIX_WIDTH = 23;
		static const LARGE_ADJ_MATRIX_HEIGHT = 23;
		
		static const LARGE_ADJ_LIST_X_START = 600;
		static const LARGE_ADJ_LIST_Y_START = 100;
		
		static const LARGE_ADJ_LIST_ELEM_WIDTH = 50;
		static const LARGE_ADJ_LIST_ELEM_HEIGHT = 26;

		static const LARGE_ADJ_LIST_HEIGHT = 30;
		static const LARGE_ADJ_LIST_WIDTH = 30;

		static const LARGE_ADJ_LIST_SPACING = 10;

		
		
		static const VERTEX_INDEX_COLOR = 0x0000FF;
		static const EDGE_COLOR = 0x000000;
		
		static const SMALL_SIZE = 8;
		static const LARGE_SIZE = 18;
		
		var size;
		
		
		var circleID:Array;
		
		var adj_matrix:Array;
		var adj_matrixID:Array;
		
		var adj_matrix_index_x:Array;
		var adj_matrix_index_y:Array;
		
		var adj_list_index:Array;
		var adj_list_list:Array;
		var adj_list_edges:Array;
		
		var currentLayer;
		
				
		var allowed:Array;
		var curve:Array;
		var x_pos_logical:Array;		
		var y_pos_logical:Array;
		var adj_matrix_x_start:int;
		var adj_matrix_y_start:int;
		var adj_matrix_width:int;
		var adj_matrix_height:int;
		var adj_list_x_start:int;
		var adj_list_y_start:int;
		var adj_list_elem_width:int;
		var adj_list_elem_height:int;
		var adj_list_height:int;
		var adj_list_width:int;
		var adj_list_spacing:int;
		
		var directed:Boolean;
		var showEdgeCosts:Boolean ;
		
		var isDAG:Boolean;
		
		var HIGHLIGHT_COLOR = 0x0000FF;
		
		public function Graph(am)
		{
			super(am);

			commands = new Array();
			
			
			newGraphButton = new Button();
			newGraphButton.label = "New Graph";
			newGraphButton.x = 360;
			newGraphButton.addEventListener(MouseEvent.MOUSE_DOWN, newGraphCallback);

			addChild(newGraphButton);
			

			
			directedGroup = new RadioButtonGroup("DirectedGraph");

			directedGraphButton = new RadioButton();
			directedGraphButton.x = 500;
			directedGraphButton.label = "Directed Graph"
			directedGraphButton.width = 150;
			directedGraphButton.selected = directed;
			directedGraphButton.addEventListener(Event.CHANGE, graphDirectionChangedHandler);
			directedGraphButton.group = directedGroup;
			addChild(directedGraphButton);
			
			undirectedGraphButton = new RadioButton();
			undirectedGraphButton.x = 500;
			undirectedGraphButton.y = 20;
			undirectedGraphButton.label = "Undirected Graph";
			undirectedGraphButton.width = 150;
			undirectedGraphButton.selected = !directed;
			undirectedGraphButton.addEventListener(Event.CHANGE, graphDirectionChangedHandler);
			undirectedGraphButton.group = directedGroup;
			addChild(undirectedGraphButton);
			
					
			
			graphSizeGroup = new RadioButtonGroup("GraphSize");

			smallGraphButton = new RadioButton();
			smallGraphButton.x = 630;
			smallGraphButton.label = "Small Graph"
			smallGraphButton.width = 100;
			smallGraphButton.selected = true;
			smallGraphButton.addEventListener(Event.CHANGE, graphSizeChangedHandler);
			smallGraphButton.group = graphSizeGroup;
			addChild(smallGraphButton);
			
			largeGraphButton = new RadioButton();
			largeGraphButton.x = 630;
			largeGraphButton.y = 20;
			largeGraphButton.label = "Large Graph";
			largeGraphButton.width = 100;
			largeGraphButton.addEventListener(Event.CHANGE, graphSizeChangedHandler);
			largeGraphButton.group = graphSizeGroup;
			addChild(largeGraphButton);

			
			
			
			graphRepGroup = new RadioButtonGroup("GraphRepresentation");

			logicalRepButton = new RadioButton();
			logicalRepButton.x = 725;
			logicalRepButton.label = "Logical Representation"
			logicalRepButton.width = 250;
			logicalRepButton.selected = true;
			logicalRepButton.addEventListener(Event.CHANGE, graphRepChangedHandler);
			logicalRepButton.group = graphRepGroup;
			addChild(logicalRepButton);
			
			adjListRepButton = new RadioButton();
			adjListRepButton.x = 725;
			adjListRepButton.y = 20;
			adjListRepButton.label = "Adjacency List Representation";
			adjListRepButton.width = 250;
			adjListRepButton.addEventListener(Event.CHANGE, graphRepChangedHandler);
			adjListRepButton.group = graphRepGroup;
			addChild(adjListRepButton);
			
			adjMatrixRepButton = new RadioButton();	
			adjMatrixRepButton.x = 725;
			adjMatrixRepButton.y = 40;
			adjMatrixRepButton.label = "Adjacency Matrix Representation"
			adjMatrixRepButton.width = 250;
			adjMatrixRepButton.addEventListener(Event.CHANGE, graphRepChangedHandler);
			adjMatrixRepButton.group = graphRepGroup;
			addChild(adjMatrixRepButton);			
			
			currentLayer = 1;
			setup_small();
			
		}
				
		
		
		private function newGraphCallback(event:Event):void
		{
			animationManager.resetAll();
			setup();			
		}
		
		
		
		

		private function graphDirectionChangedHandler(event:Event):void 
		{
			if ( event.currentTarget.selected )
			{
				if (event.currentTarget == directedGraphButton && !directed)
				{
					directed = true;
					animationManager.resetAll();
					setup();
				}
				else if (event.currentTarget == undirectedGraphButton && directed)
				{
					directed = false;
					animationManager.resetAll();
					setup();
				}
			}
		}
		
		
		
		function graphSizeChangedHandler(event:Event):void 
		{
			if ( event.currentTarget.selected )
			{
				if (event.currentTarget == smallGraphButton && size != SMALL_SIZE)
				{
					animationManager.resetAll();
					setup_small();
				}
				else if (event.currentTarget == largeGraphButton && size != LARGE_SIZE)
				{
					animationManager.resetAll();
					setup_large();
				}
			}
		}
		
		private function graphRepChangedHandler(event:Event):void 
		{
			if ( event.currentTarget.selected )
			{
				
				if (event.currentTarget == logicalRepButton)
				{
					animationManager.setAllLayers(0,1);
					currentLayer = 1;
				}
				else if (event.currentTarget == adjListRepButton)
				{
					animationManager.setAllLayers(0,2);
					currentLayer = 2;
				}
				else if (event.currentTarget == adjMatrixRepButton)
				{
					animationManager.setAllLayers(0,3);
					currentLayer = 3;
				}
			}
		}
		
		
		function recolorGraph()
		{
			for (var i:int = 0; i < size; i++)
			{
				for (var j:int = 0; j < size; j++)
				{
					if (adj_matrix[i][j] >= 0)
					{
						setEdgeColor(i, j, EDGE_COLOR);				
					}
				}
			}
		}		
				
		function highlightEdge(i,j, highlightVal)
		{
			cmd("SetHighlight", adj_list_edges[i][j], highlightVal);
			cmd("SetHighlight", adj_matrixID[i][j], highlightVal);
			cmd("SetEdgeHighlight", circleID[i], circleID[j], highlightVal);		
			if (!directed)
			{
				cmd("SetEdgeHighlight", circleID[j], circleID[i], highlightVal);
			}
		}
		
		function setEdgeColor(i,j, color)
		{
			cmd("SetForegroundColor", adj_list_edges[i][j], color);
			cmd("SetTextColor", adj_matrixID[i][j], color);
			cmd("SetEdgeColor", circleID[i], circleID[j], color);		
			if (!directed)
			{
				cmd("SetEdgeColor", circleID[j], circleID[i], color);
			}
		}

		
		
		function clearEdges()
		{
			for (var i:int = 0; i < size; i++)
			{
				for (var j:int = 0; j < size; j++)
				{
					if (adj_matrix[i][j] >= 0)
					{
						cmd("Disconnect", circleID[i], circleID[j]);
					}
				}
			}
		}
		
		
		function rebuildEdges()
		{
			clearEdges();
			buildEdges();
		}

		
		
		function buildEdges()
		{
			
			for (var i:int = 0; i < size; i++)
			{
				for (var j:int = 0; j < size; j++)
				{
					if (adj_matrix[i][j] >= 0)
					{
						var edgeLabel:String;
						if (showEdgeCosts)
						{
							edgeLabel = String(adj_matrix[i][j]);
						}
						else
						{
							edgeLabel = "";
						}
						if (directed)
						{
							cmd("Connect", circleID[i], circleID[j], EDGE_COLOR, adjustCurveForDirectedEdges(curve[i][j], adj_matrix[j][i] >= 0), 1, edgeLabel);
						}
						else if (i < j)
						{
							cmd("Connect", circleID[i], circleID[j], EDGE_COLOR, curve[i][j], 0, edgeLabel);							
						}
					}
				}
			}
		
		}
		
		function setup_small()
		{
			allowed = SMALL_ALLLOWED;
			curve = SMALL_CURVE;
			x_pos_logical = SMALL_X_POS_LOGICAL;
			y_pos_logical = SMALL_Y_POS_LOGICAL;
			adj_matrix_x_start = SMALL_ADJ_MATRIX_X_START;
			adj_matrix_y_start = SMALL_ADJ_MATRIX_Y_START;
			adj_matrix_width = SMALL_ADJ_MATRIX_WIDTH;
			adj_matrix_height = SMALL_ADJ_MATRIX_HEIGHT;
			adj_list_x_start = SMALL_ADJ_LIST_X_START;
			adj_list_y_start = SMALL_ADJ_LIST_Y_START;
			adj_list_elem_width = SMALL_ADJ_LIST_ELEM_WIDTH;
			adj_list_elem_height = SMALL_ADJ_LIST_ELEM_HEIGHT;
			adj_list_height = SMALL_ADJ_LIST_HEIGHT;
			adj_list_width = SMALL_ADJ_LIST_WIDTH;
			adj_list_spacing = SMALL_ADJ_LIST_SPACING;
			size = SMALL_SIZE;
			setup();
		}
		
		function setup_large()
		{
			allowed = LARGE_ALLOWED;
			curve = LARGE_CURVE;
			x_pos_logical = LARGE_X_POS_LOGICAL;
			y_pos_logical = LARGE_Y_POS_LOGICAL;
			adj_matrix_x_start = LARGE_ADJ_MATRIX_X_START;
			adj_matrix_y_start = LARGE_ADJ_MATRIX_Y_START;
			adj_matrix_width = LARGE_ADJ_MATRIX_WIDTH;
			adj_matrix_height = LARGE_ADJ_MATRIX_HEIGHT;
			adj_list_x_start = LARGE_ADJ_LIST_X_START;
			adj_list_y_start = LARGE_ADJ_LIST_Y_START;
			adj_list_elem_width = LARGE_ADJ_LIST_ELEM_WIDTH;
			adj_list_elem_height = LARGE_ADJ_LIST_ELEM_HEIGHT;
			adj_list_height = LARGE_ADJ_LIST_HEIGHT;
			adj_list_width = LARGE_ADJ_LIST_WIDTH;
			adj_list_spacing = LARGE_ADJ_LIST_SPACING;
			size = LARGE_SIZE;
			setup();		
		}

		function adjustCurveForDirectedEdges(curve, bidirectional)
		{
			if (!bidirectional || Math.abs(curve) > 0.01)
			{
				return curve;
			}
			else
			{
				return 0.1;
			}
			
		}
		function setup() : void
		{
			commands = new Array();
			circleID = new Array(size);
			for (var i:int = 0; i < size; i++)
			{
				circleID[i] = nextIndex++;
				cmd("CreateCircle", circleID[i], i, x_pos_logical[i], y_pos_logical[i]);
				cmd("SetTextColor", circleID[i], VERTEX_INDEX_COLOR, 0);

				cmd("SetLayer", circleID[i], 1);
			}
			
			adj_matrix = new Array(size);
			adj_matrixID = new Array(size);
			for (i = 0; i < size; i++)
			{
				adj_matrix[i] = new Array(size);
				adj_matrixID[i] = new Array(size);
			}
			
			var edgePercent;
			if (size == SMALL_SIZE)
			{
				if (directed)
				{
					edgePercent = 0.4;
				}
				else
				{
					edgePercent = 0.5;					
				}
				
			}
			else
			{
				if (directed)
				{
					edgePercent = 0.35;
				}
				else
				{
					edgePercent = 0.6;					
				}
				
			}
			
			var lowerBound = 0;
			
			if (directed)
			{
				for (i = 0; i < size; i++)
				{
					for (var j = 0; j < size; j++)
					{
						adj_matrixID[i][j] = nextIndex++;
						if ((allowed[i][j]) && Math.random() <= edgePercent && (i < j || Math.abs(curve[i][j]) < 0.01 || adj_matrixID[j][i] == -1) && (!isDAG || (i < j)))
						{
							if (showEdgeCosts)
							{
								adj_matrix[i][j] = Math.floor(Math.random()* 9) + 1;
							}
							else
							{
								adj_matrix[i][j] = 1;
							}
							    
						}
						else
						{
							adj_matrix[i][j] = -1;
						}
						
					}				
				}
				buildEdges();
				
			}
			else
			{
				for (i = 0; i < size; i++)
				{
					for (j = i+1; j < size; j++)
					{
						
						adj_matrixID[i][j] = nextIndex++;
						adj_matrixID[j][i] = nextIndex++;

						if ((allowed[i][j]) && Math.random() <= edgePercent)
						{
							if (showEdgeCosts)
							{
								adj_matrix[i][j] = Math.floor(Math.random()* 9) + 1;
							}
							else
							{
								adj_matrix[i][j] = 1;
							}
							adj_matrix[j][i] = adj_matrix[i][j];
							if (showEdgeCosts)
							{
								var edgeLabel:String  = String(adj_matrix[i][j]);
							}
							else
							{
								edgeLabel = "";
							}
								cmd("Connect", circleID[i], circleID[j], EDGE_COLOR, curve[i][j], 0, edgeLabel);
							}
						else
						{
							adj_matrix[i][j] = -1;
							adj_matrix[j][i] = -1;
						}
						
					}				
				}
				
				buildEdges();
				
							
				for (i=0; i < size; i++)
				{
					adj_matrix[i][i] = -1;
				}
				
			}


			
			// Craate Adj List
			
			

			
			buildAdjList();
			
			
			// Create Adj Matrix
			
			buildAdjMatrix();
			
			
			animationManager.setAllLayers(0, currentLayer);
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			animationManager.clearHistory();
		}
		
		function resetAll()
		{
			
		}
		
		
		function buildAdjMatrix()
		{

			adj_matrix_index_x = new Array(size);
			adj_matrix_index_y = new Array(size);
			for (var i:int = 0; i < size; i++)
			{
				adj_matrix_index_x[i] = nextIndex++;
				adj_matrix_index_y[i] = nextIndex++;
				cmd("CreateLabel", adj_matrix_index_x[i], i,   adj_matrix_x_start + i*adj_matrix_width, adj_matrix_y_start - adj_matrix_height);
				cmd("SetForegroundColor", adj_matrix_index_x[i], VERTEX_INDEX_COLOR);
				cmd("CreateLabel", adj_matrix_index_y[i], i,   adj_matrix_x_start  - adj_matrix_width, adj_matrix_y_start + i* adj_matrix_height);
				cmd("SetForegroundColor", adj_matrix_index_y[i], VERTEX_INDEX_COLOR);
				cmd("SetLayer", adj_matrix_index_x[i], 3);
				cmd("SetLayer", adj_matrix_index_y[i], 3);

				for (var j:int = 0; j < size; j++)
				{
					adj_matrixID[i][j] = nextIndex++;
					if (adj_matrix[i][j] < 0)
					{
						var lab:String = ""						
					}
					else
					{
						lab = String(adj_matrix[i][j])
					}
					cmd("CreateRectangle", adj_matrixID[i][j], lab, adj_matrix_width, adj_matrix_height, 
				         adj_matrix_x_start + j*adj_matrix_width,adj_matrix_y_start + i * adj_matrix_height);
					cmd("SetLayer", adj_matrixID[i][j], 3);
					
					
				}				
			}
		}

		
		
		function removeAdjList()
		{
			for (var i:int = 0; i < size; i++)
			{
				cmd("Delete", adj_list_list[i]);
				cmd("Delete", adj_list_index[i]);
				for (var j:int = 0; j < size; j++)
				{
					if (adj_matrix[i][j] > 0)
					{
						cmd("Delete", adj_list_edges[i][j]);
					}	
				}
			}
			
		}
		
		
		function buildAdjList()
		{					
			adj_list_index = new Array(size);
			adj_list_list = new Array(size);
			adj_list_edges = new Array(size);
			
			for (var i:int = 0; i < size; i++)
			{
				adj_list_index[i] = nextIndex++;
				adj_list_edges[i] = new Array(size);
				adj_list_index[i] = nextIndex++;
				adj_list_list[i] = nextIndex++;
				cmd("CreateRectangle", adj_list_list[i], "", adj_list_width, adj_list_height, adj_list_x_start, adj_list_y_start + i*adj_list_height);
				cmd("SetLayer", adj_list_list[i], 2);
				cmd("CreateLabel", adj_list_index[i], i, adj_list_x_start - adj_list_width , adj_list_y_start + i*adj_list_height);
				cmd("SetForegroundColor",  adj_list_index[i], VERTEX_INDEX_COLOR);
				cmd("SetLayer", adj_list_index[i], 2);
				var lastElem:int = adj_list_list[i];
				var nextXPos:int = adj_list_x_start + adj_list_width + adj_list_spacing;
				var hasEdges = false;
				for (var j:int = 0; j < size; j++)
				{
					if (adj_matrix[i][j] > 0)
					{
						hasEdges = true;
						adj_list_edges[i][j] = nextIndex++;
						cmd("CreateLinkedList",adj_list_edges[i][j], j,adj_list_elem_width, adj_list_elem_height, 
											   nextXPos, adj_list_y_start + i*adj_list_height, 0.25, 0, 1, 2);
						cmd("SetNull", adj_list_edges[i][j], 1);
						cmd("SetText", adj_list_edges[i][j], adj_matrix[i][j], 1); 
						cmd("SetTextColor", adj_list_edges[i][j], VERTEX_INDEX_COLOR, 0);
						cmd("SetLayer", adj_list_edges[i][j], 2);

						nextXPos = nextXPos + adj_list_elem_width + adj_list_spacing;
						cmd("Connect", lastElem, adj_list_edges[i][j]);
						cmd("SetNull", lastElem, 0);
						lastElem = adj_list_edges[i][j];						
					}	
				}
				if (!hasEdges)
				{
					cmd("SetNull", adj_list_list[i], 1);					
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
			
			newGraphButton.enabled = true;
			smallGraphButton.enabled = true;
			largeGraphButton.enabled = true;
			directedGraphButton.enabled = true;
			undirectedGraphButton.enabled = true;
		}
		override function disableUI(event:AnimationStateEvent):void
		{
			newGraphButton.enabled = false;
			smallGraphButton.enabled = false;
			largeGraphButton.enabled = false;
			directedGraphButton.enabled = false;
			undirectedGraphButton.enabled = false;
		}
	}
}