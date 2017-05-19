package {
	import flash.display.Sprite;
	import fl.controls.TextInput;

	

	public class AlgorithmDisplay extends Sprite {

		var animationManager:AnimationMainLoop;
		var actionHistory:Array;

		
		public function AlgorithmDisplay(am:AnimationMainLoop)
		{
			animationManager = am;
			
			am.addEventListener(AnimationStateEvent.AnimationStarted, disableUI);
			am.addEventListener(AnimationStateEvent.AnimationEnded, enableUI);
			am.addEventListener(AnimationStateEvent.AnimationUndo, undo);
			
			actionHistory = new Array();
		}
		
		function implementAction(funct, val)
		{
			var nxt:Array = new Array(2);
			nxt[0]= funct;
			nxt[1] = val;
		
			actionHistory.push(nxt);
			animationManager.StartNewAnimation(funct(val));			
		}

		
		function disableUI(event:AnimationStateEvent):void
		{
			// to be overridden in base class
		}
		
		function enableUI(event:AnimationStateEvent):void
		{
			// to be overridden in base class
		}
		
		function reset()
		{
			// to be overriden in base class
			// (Throw exception here?)
		}
		
		function undo(event:AnimationStateEvent):void
		{
			// Remvoe the last action (the one that we are going to undo)
			actionHistory.pop();
			// Clear out our data structure.  Be sure to implement reset in
			//   every algorithm animation!
			reset();
			var len:int = actionHistory.length;
			for (var i:int = 0; i < len; i++)
			{
				actionHistory[i][0](actionHistory[i][1]);
			}
			
		}
		
		
		// Helper method to add text input with nice border.
		//  AS3 probably has a built-in way to do this.   Replace when found.

		function addTextInput(x,y,w,h): TextInput 
		{	
			var enterField : TextInput =  new TextInput();
			enterField.setSize(w, h); 
			enterField.x = x;
			enterField.y = y;
			addChild(enterField);			
			
			graphics.lineStyle(1,0x000000,1.0);
			graphics.moveTo(x,y);
			graphics.lineTo(x+w-1,y);
			graphics.lineTo(x+w-1,y+h-1);
			graphics.lineTo(x,y+h-1);
			graphics.lineTo(x,y);
			return enterField;
		}
		
		
		// Random helper methods ...
		
		function max(a, b): int
		{
			if (a > b)
			{
				return a;
			}
			else
			{
				return b;
			}
		}
		
		public function createCommand(a):String
		{
			return String(a);
		}
		
		public function createCommand2(a,b):String
		{
			return String(a) + "," + String(b);
		}
		
		public function createCommand3(a,b,c):String
		{
			return String(a) + "," + String(b) + "," + String(c);
		}
		
		public function createCommand4(a,b,c, d):String
		{
			return String(a) + "," + String(b) + "," + String(c) + "," + String(d);
		}
	    public function createCommand5(a,b,c, d,e):String
		{
			return String(a) + "," + String(b) + "," + String(c) + "," + String(d) + "," + String(e);
		}
	    public function createCommand6(a,b,c, d,e,f):String
		{
			return String(a) + "," + String(b) + "," + String(c) + "," + String(d) + "," + String(e) + "," + String(f);
		}
		
		
	}
	
	
}