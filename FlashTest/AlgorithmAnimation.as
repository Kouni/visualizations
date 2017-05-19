package {
	import flash.display.Sprite;
	import fl.controls.TextInput;
	import flash.events.Event;
	
	// TODO:  This probably doesn't need to be a Sprite -- any visual container should do.
	public class AlgorithmAnimation extends Sprite {

		var animationManager:AnimationManager;
		var actionHistory:Array;
		var commands:Array;
		var recordAnimation:Boolean;


		
		public function AlgorithmAnimation(am:AnimationManager)
		{
			animationManager = am;
			
			am.addEventListener(AnimationStateEvent.AnimationStarted, disableUI);
			am.addEventListener(AnimationStateEvent.AnimationEnded, enableUI);
			am.addEventListener(AnimationStateEvent.AnimationUndo, undo);
			
			actionHistory = new Array();
			recordAnimation = true;
			
		}
		
		function implementAction(funct, val)
		{
			var nxt:Array = new Array(2);
			nxt[0]= funct;
			nxt[1] = val;
		
			actionHistory.push(nxt);
			var retVal = funct(val);
			animationManager.StartNewAnimation(retVal);			
		}

		
		function isAllDigits(str:String):Boolean
		{
			for (var i:int = str.length - 1; i >= 0; i--)
			{
				if (str.charAt(i) < "0" || str.charAt(i) > "9")
					return false;
			}
			return true;
		}
		
		
		function normalizeNumber(input:String, maxLen:int):String
		{
			if (!isAllDigits(input) || input == "")
			{
				return input;
			}
			else
			{
				return ("OOO0000" +input).substr(-maxLen, maxLen);
			}
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
			//   every AlgorithmAnimation subclass!
			reset();
			//  Redo all actions from the beginning, throwing out the animation
			//  commands (the animation manager will update the animation on its own).
			//  Note that if you do something non-deterministic, you might cause problems!
			//  Be sure if you do anything non-deterministic (that is, calls to a random
			//  number generator) you clear out the undo stack here and in the animation
			//  manager.
			//
			//  If this seems horribly inefficient -- it is! However, it seems to work well
			//  in practise, and you get undo for free for all algorithms, which is a non-trivial
			//  gain.
			var len:int = actionHistory.length;
			recordAnimation = false;
			for (var i:int = 0; i < len; i++)
			{
				actionHistory[i][0](actionHistory[i][1]);
			}
			recordAnimation = true;
			
		}
		
		
		// Helper method to add text input with nice border.
		//  AS3 probably has a built-in way to do this.   Replace when found.

		function addTextInput(x,y,w,h, integerOnly = false, restrictSize = true): TextInput 
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
			if (restrictSize)
			{
				enterField.addEventListener(Event.CHANGE, restrictLength4);
			}
			if (integerOnly)
			{
				enterField.addEventListener(Event.CHANGE, restrictToInt);
			}
			return enterField;
		}
		

		function fieldAcceptsIntegerOnly(field: TextInput, integerOnly : Boolean = true)
		{
			if (integerOnly)
			{
				field.addEventListener(Event.CHANGE, restrictToInt);				
			}
			else
			{
				
				field.removeEventListener(Event.CHANGE, restrictToInt);								
			}
			
		}
		
		private function restrictToInt(event:Event):void
		{
			var lastInput = event.target.text.charAt(event.target.text.length-1);
			if (lastInput < "0" || lastInput > "9")
				event.target.text = event.target.text.substr(0, event.target.text.length - 1);
			
		}
		
		private function restrictLength4(event:Event):void 
		{
			if ( event.target.text.length > 4 ) 
			{
				event.target.text = event.target.text.substr(0, 4);
			}
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
		
		
		// Helper method to create a command string from a bunch of arguments
		public function cmd(command, ... args):void
		{
			if (recordAnimation)
			{
				for(var i:uint = 0; i < args.length; i++)
				{
					command = command + ";" + String(args[i]);
				}
				commands.push(command);
			}
		}		
		
	}
	
	
}