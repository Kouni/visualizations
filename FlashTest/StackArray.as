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
	import fl.controls.RadioButton;
	import fl.controls.RadioButtonGroup;
	import flash.events.Event;




	public class StackArray extends AlgorithmAnimation {
		
		// Input Controls
		var enterFieldPush:TextInput;
		var pushButton:Button;
		var popButton:Button;
		var clearButton:Button;
		
		
		static const ARRAY_START_X:int = 100;
		static const ARRAY_START_Y:int = 200;
		static const ARRAY_ELEM_WIDTH:int = 50;
		static const ARRAY_ELEM_HEIGHT:int = 50;
		
		static const ARRRAY_ELEMS_PER_LINE = 15;
		static const ARRAY_LINE_SPACING = 130;
		
		static const TOP_POS_X = 180;
		static const TOP_POS_Y = 100;
		static const TOP_LABEL_X = 130;
		static const TOP_LABEL_Y =  100;
		
		static const PUSH_LABEL_X = 50;
		static const PUSH_LABEL_Y = 30;
		static const PUSH_ELEMENT_X = 120;
		static const PUSH_ELEMENT_Y = 30;
		
		static const SIZE:int = 30;

		var arrayLabelID:Array;
		var arrayID:Array;
		
		var topID :int;
		var topLabelID :int;
		
		var highlight1ID:int;
		var highlight2ID:int;
		
		var arrayData:Array;
		var top:int;
		
		var leftoverLabelID:int;
		
		
		var nextIndex:int  = 0;
		
		
		const LINK_COLOR = 0x007700;
		const HIGHLIGHT_CIRCLE_COLOR = 0x007700;
		const FOREGROUND_COLOR = 0x007700;
		const BACKGROUND_COLOR = 0xEEFFEE;
		const PRINT_COLOR = FOREGROUND_COLOR;
		
		public function StackArray(am)
		{
			super(am);
			
			
			enterFieldPush = addTextInput(2,2,100,20);
			pushButton = new Button();
			pushButton.label = "Push";
			pushButton.x = 107;
			pushButton.width = 100;
			addChild(pushButton);
			
			popButton = new Button();
			popButton.label = "Pop";
			popButton.x = 212;
			popButton.width = 100;
			addChild(popButton);
			
			clearButton = new Button();
			clearButton.label = "Clear";
			clearButton.x = 317;
			clearButton.width = 100;
			addChild(clearButton);
					
			
			pushButton.addEventListener(MouseEvent.MOUSE_DOWN, pushCallback);
			popButton.addEventListener(MouseEvent.MOUSE_DOWN, popCallback);
			enterFieldPush.addEventListener(ComponentEvent.ENTER, pushCallback);
			clearButton.addEventListener(MouseEvent.MOUSE_DOWN, clearCallback);

			
			nextIndex = 0;
			highlight1ID = nextIndex++;
			highlight2ID = nextIndex++;
			
			arrayID = new Array(SIZE);
			arrayLabelID = new Array(SIZE);
			for (var i = 0; i < SIZE; i++)
			{

				arrayID[i]= nextIndex++;
				arrayLabelID[i]= nextIndex++;
			}
			topID = nextIndex++;
			topLabelID = nextIndex++;
			
			arrayData = new Array(SIZE);
			top = 0;
			leftoverLabelID = nextIndex++;

			setup();
		
		}
		
		function setup()
		{
			commands = new Array();

			for (var i:int = 0; i < SIZE; i++)
			{
				var xpos = (i  % ARRRAY_ELEMS_PER_LINE) * ARRAY_ELEM_WIDTH + ARRAY_START_X;
				var ypos = int(i / ARRRAY_ELEMS_PER_LINE) * ARRAY_LINE_SPACING +  ARRAY_START_Y;
				cmd("CreateRectangle", arrayID[i],"", ARRAY_ELEM_WIDTH, ARRAY_ELEM_HEIGHT,xpos, ypos);
				cmd("CreateLabel",arrayLabelID[i],  i,  xpos, ypos + ARRAY_ELEM_HEIGHT);
				cmd("SetForegroundColor", arrayLabelID[i], 0x0000FF);
				
			}
			cmd("CreateLabel", topLabelID, "Top", TOP_LABEL_X, TOP_LABEL_Y);
			cmd("CreateRectangle", topID, 0, ARRAY_ELEM_WIDTH, ARRAY_ELEM_HEIGHT, TOP_POS_X, TOP_POS_Y);

			cmd("CreateLabel", leftoverLabelID, "", PUSH_LABEL_X, PUSH_LABEL_Y);
			
			animationManager.StartNewAnimation(commands);
			animationManager.skipForward();
			animationManager.clearHistory();		
			
		}
		
		
		override function reset()
		{
			top = 0;

		}
		
		
		override function enableUI(event:AnimationStateEvent):void
		{
			pushButton.enabled = true;
			popButton.enabled = true;
			clearButton.enabled = true;

			enterFieldPush.enabled =true;
			enterFieldPush.addEventListener(ComponentEvent.ENTER, pushCallback);
			
		}
		override function disableUI(event:AnimationStateEvent):void
		{
			pushButton.enabled = false;
			popButton.enabled = false;
			clearButton.enabled = false;

			enterFieldPush.enabled = false;
			enterFieldPush.removeEventListener(ComponentEvent.ENTER, pushCallback);
			
			
		}
		
		
		
		
				
		function pushCallback(event):void
		{
			if (top < SIZE && enterFieldPush.text != "")
			{
				var pushVal = enterFieldPush.text;
				enterFieldPush.text = ""
				implementAction(push, pushVal);
			}
		}
		
		
		function popCallback(event):void
		{
			if (top > 0)
			{
				implementAction(pop, "");
			}
		}
		
		
		function clearCallback(event):void
		{
			implementAction(clearData, "");
		}
		
		function clearData(ignored)
		{
			commands = new Array();
			clearAll();
			return commands;			
		}
		

		function push(elemToPush)
		{
			commands = new Array();
			
			var labPushID = nextIndex++;
			var labPushValID = nextIndex++;
			arrayData[top] = elemToPush;
			
			cmd("SetText", leftoverLabelID, "");
			
			cmd("CreateLabel", labPushID, "Pushing Value: ", PUSH_LABEL_X, PUSH_LABEL_Y);
			cmd("CreateLabel", labPushValID,elemToPush, PUSH_ELEMENT_X, PUSH_ELEMENT_Y);
			
			cmd("Step");			
			cmd("CreateHighlightCircle", highlight1ID, 0x0000FF,  TOP_POS_X, TOP_POS_Y);
			cmd("Step");
			
			var xpos = (top  % ARRRAY_ELEMS_PER_LINE) * ARRAY_ELEM_WIDTH + ARRAY_START_X;
			var ypos = int(top / ARRRAY_ELEMS_PER_LINE) * ARRAY_LINE_SPACING +  ARRAY_START_Y;
			
			cmd("Move", highlight1ID, xpos, ypos + ARRAY_ELEM_HEIGHT); 				
			cmd("Step");
			
			cmd("Move", labPushValID, xpos, ypos);
			cmd("Step");
			
			cmd("Settext", arrayID[top], elemToPush);
			cmd("Delete", labPushValID);
			
			cmd("Delete", highlight1ID);
			
			cmd("SetHighlight", topID, 1);
			cmd("Step");
			top = top + 1;
			cmd("SetText", topID, top)
			cmd("Delete", labPushID);
			cmd("Step");
			cmd("SetHighlight", topID, 0);
			
			return commands;
		}
		
		function pop(ignored = "")
		{
			commands = new Array();
			
			var labPopID = nextIndex++;
			var labPopValID = nextIndex++;
			
			cmd("SetText", leftoverLabelID, "");

			
			cmd("CreateLabel", labPopID, "Popped Value: ", PUSH_LABEL_X, PUSH_LABEL_Y);
			
			
			cmd("SetHighlight", topID, 1);
			cmd("Step");
			top = top - 1;
			cmd("SetText", topID, top)
			cmd("Step");
			cmd("SetHighlight", topID, 0);
			
			cmd("CreateHighlightCircle", highlight1ID, 0x0000FF,  TOP_POS_X, TOP_POS_Y);
			cmd("Step");
			
			var xpos = (top  % ARRRAY_ELEMS_PER_LINE) * ARRAY_ELEM_WIDTH + ARRAY_START_X;
			var ypos = int(top / ARRRAY_ELEMS_PER_LINE) * ARRAY_LINE_SPACING +  ARRAY_START_Y;
			
			cmd("Move", highlight1ID, xpos, ypos + ARRAY_ELEM_HEIGHT); 				
			cmd("Step");
			
			cmd("CreateLabel", labPopValID,arrayData[top], xpos, ypos);
			cmd("Settext", arrayID[top], "");
			cmd("Move", labPopValID,  PUSH_ELEMENT_X, PUSH_ELEMENT_Y);
			cmd("Step");
			cmd("Delete", labPopValID)
			cmd("Delete", labPopID);
			cmd("Delete", highlight1ID);
			cmd("SetText", leftoverLabelID, "Popped Value: " + arrayData[top]);


			
			return commands;
		}

		
	
		function clearAll()
		{
			commands = new Array();
			for (var i:int = 0; i < top; i++)
			{
				cmd("SetText", arrayID[i], "");
			}
			top = 0;
			cmd("SetText", topID, "0");
			return commands;
					
		}
	
				
	}
}

