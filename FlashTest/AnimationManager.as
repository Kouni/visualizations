package 
{
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.display.DisplayObjectContainer;
	import Objects.*;

	public class AnimationManager extends Sprite
	{

		// Holder for all animated objects.
		// All animation is done by manipulating objects in\
		// this container
		private var animatedObjects : ObjectManager;


		// Control variables for stopping / starting animation

		private var animationPaused : Boolean;
		private var doNextStep : Boolean;
		private var awaitingStep : Boolean;
		private var currentlyAnimating:Boolean;

		// Array holding the code for the animation.  This is 
		// an array of strings, each of which is an animation command
		// currentAnimation is an index into this array
		private var AnimationSteps:Array;
		private var currentAnimation:int;
		
		private var previousAnimationSteps:Array;

		// Control variables for where we are in the current animation block.
		//  currFrame holds the frame number of the current animation block,
		//  while animationBlockLength holds the length of the current animation
		//  block (in frame numbers).  
		private var currFrame:Number;
		private var animationBlockLength:Number;

		//  The animation block that is currently running.  Array of singleAnimations
		private var currentBlock:Array;

		/////////////////////////////////////
		// Variables for handling undo. 
		//////////////////////////////////// already implemented animations. 
		//  A stack of UndoBlock objects (subclassed, UndoBlock is an abstract base class)
		//  each of which can undo a single animation element
		private var undoStack:Array;
		private var doingUndo:Boolean = false;

		// A stack containing the beginning of each animation block, as an index
		// into the AnimationSteps array
		private var undoAnimationStepIndices:Array;
		private var undoAnimationStepIndicesStack:Array;


		/////////////////////////////////////////////////////
		// Public Methods
		/////////////////////////////////////////////////////

		function AnimationManager():void
		{
			animatedObjects = new ObjectManager();
			addChild(animatedObjects);
			currentBlock = null;
			currentlyAnimating = false;
			animationPaused = true;
			animationBlockLength = 60;
			currFrame = 0;
			awaitingStep = false;
			undoStack = new Array();
			undoAnimationStepIndices = null;
			previousAnimationSteps = new Array();
			AnimationSteps = null;
			undoAnimationStepIndicesStack = new Array();
		}
		// Pause / unpause animation
		public function SetPaused(pausedValue)
		{
			animationPaused = pausedValue;
			if (!animationPaused)
			{
				step();
			}
		}

		// Set the speed of the animation, from 0 (slow) to 100 (fast)
		public function SetSpeed(newSpeed)
		{
			animationBlockLength = 100-newSpeed + 1;
		}
		//  Start a new animation.  The input parameter commands is an array of strings,
		//  which represents the animation
		public function StartNewAnimation(commands)
		{
			if (AnimationSteps != null)
			{
				previousAnimationSteps.push(AnimationSteps);
				undoAnimationStepIndicesStack.push(undoAnimationStepIndices);
			}
			if (commands.length != 0)
			{
				AnimationSteps = commands;
			}
			else
			{
				AnimationSteps = ["Step"];
			}
			undoAnimationStepIndices = new Array();
			currentAnimation = 0;
			startNextBlock();
			currentlyAnimating = true;
			dispatchEvent(new AnimationStateEvent(AnimationStateEvent.AnimationStarted));

		}
		
		

		// Step backwards one step.  A no-op if the animation is not currently paused
		public function stepBack()
		{
			if (awaitingStep && undoStack != null && undoStack.length != 0)
			{
				dispatchEvent(new AnimationStateEvent(AnimationStateEvent.AnimationStarted));				
				awaitingStep = false;
				undoLastBlock();

			}
			else if (!currentlyAnimating && animationPaused && undoAnimationStepIndices != null)
			{
				dispatchEvent(new AnimationStateEvent(AnimationStateEvent.AnimationStarted));			
				currentlyAnimating = true;
				undoLastBlock();
			}

		}
		// Step forwards one step.  A no-op if the animation is not currently paused
		public function step()
		{
			if (awaitingStep)
			{
				startNextBlock();
				dispatchEvent(new AnimationStateEvent(AnimationStateEvent.AnimationStarted));				
				currentlyAnimating = true;
			}
		}

		
		
		// Implement one step of the animation.  Must be called on each frame.
		public function oneIteration():void
		{
			if (currentlyAnimating)
			{
				currFrame = currFrame + 1;
				var i:int;
				for (i = 0; i < currentBlock.length; i++)
				{
					if (currFrame >= animationBlockLength)
					{
						animatedObjects.setNodePosition(currentBlock[i].objectID,
						                                currentBlock[i].toX,
						                                currentBlock[i].toY);
					}
					else
					{
						var objectID:int = currentBlock[i].objectID;
						var percent:Number =  1 / (animationBlockLength - currFrame);
						var oldX:Number = animatedObjects.nodeX(objectID);
						var oldY:Number = animatedObjects.nodeY(objectID);
						var targetX: Number = currentBlock[i].toX;
						var targety: Number = currentBlock[i].toY;						
						var newX:Number = lerp(animatedObjects.nodeX(objectID), currentBlock[i].toX, percent);
						var newY:Number = lerp(animatedObjects.nodeY(objectID), currentBlock[i].toY, percent);
						animatedObjects.setNodePosition(objectID,
						                                newX,
						                                newY);
					}
				}
				if (currFrame >= animationBlockLength)
				{
					if (doingUndo)
					{
						if (finishUndoBlock(undoStack.pop()))
						{
							awaitingStep = true;
							dispatchEvent(new AnimationStateEvent(AnimationStateEvent.AnimationWaiting));							
						}

					}
					else
					{
						if (animationPaused && (currentAnimation < AnimationSteps.length))
						{
							awaitingStep = true;
							dispatchEvent(new AnimationStateEvent(AnimationStateEvent.AnimationWaiting));
							currentBlock = new Array();
						}
						else
						{
							startNextBlock();
						}
					}
				}
			}
			animatedObjects.update();
		}
		
		
		
		/// WARNING:  Could be dangerous to call while an animation is running ...
		public function clearHistory():void
		{
			undoStack = new Array();
			undoAnimationStepIndices = null;
			previousAnimationSteps = new Array();
			undoAnimationStepIndicesStack = new Array();
			AnimationSteps = null;
			dispatchEvent(new AnimationStateEvent(AnimationStateEvent.AnimationUndoUnavailable));
		}
		
		public function skipBack()
		{
			var keepUndoing:Boolean = undoAnimationStepIndices != null && undoAnimationStepIndices.length != 0;
			if (keepUndoing)
			{
				for (var i:int = 0; currentBlock != null && i < currentBlock.length; i++)
				{
					var objectID:int = currentBlock[i].objectID;
					animatedObjects.setNodePosition(objectID,
													currentBlock[i].toX,
													currentBlock[i].toY);
				}
				if (doingUndo)
				{
					finishUndoBlock(undoStack.pop())
				}
				while (keepUndoing)
				{
					undoLastBlock();
					for (i = 0; i < currentBlock.length; i++)
					{
						objectID = currentBlock[i].objectID;
						animatedObjects.setNodePosition(objectID,
						                                currentBlock[i].toX,
						                                currentBlock[i].toY);
					}
					keepUndoing = finishUndoBlock(undoStack.pop());

				}
				animatedObjects.update();
				if (undoStack == null || undoStack.length == 0)
				{
					dispatchEvent(new AnimationStateEvent(AnimationStateEvent.AnimationUndoUnavailable));
				}
			}			
		}
		
		public function resetAll()
		{
			clearHistory();
			animatedObjects.clearAllObjects();			
		}
		
		public function skipForward()
		{
			if (currentlyAnimating)
			{
				animatedObjects.runFast = true;
				while (AnimationSteps != null && currentAnimation < AnimationSteps.length)
				{
						for (var i:int = 0; currentBlock != null && i < currentBlock.length; i++)
						{
							var objectID:int = currentBlock[i].objectID;
							animatedObjects.setNodePosition(objectID,
															currentBlock[i].toX,
															currentBlock[i].toY);
						}
						if (doingUndo)
						{
							finishUndoBlock(undoStack.pop())
						}
						startNextBlock();
						for (i= 0; i < currentBlock.length; i++)
						{
							objectID = currentBlock[i].objectID;
							animatedObjects.setNodePosition(objectID,
															currentBlock[i].toX,
															currentBlock[i].toY);
						}		
					
				}
				animatedObjects.update();
				currentlyAnimating = false;
				awaitingStep = false;
				doingUndo = false;
				
				animatedObjects.runFast = false;

				dispatchEvent(new AnimationStateEvent(AnimationStateEvent.AnimationEnded));
			}
		}
	
		
		private function finishUndoBlock(undoBlock) : Boolean
		{
			for (var i:int = undoBlock.length - 1; i >= 0; i--)
			{
				undoBlock[i].undoInitialStep(animatedObjects);

			}
			doingUndo = false;

			// If we are at the final end of the animation ...
			if (undoAnimationStepIndices.length == 0)
			{
				awaitingStep = false;
				currentlyAnimating = false;
				undoAnimationStepIndices = undoAnimationStepIndicesStack.pop();
				AnimationSteps = previousAnimationSteps.pop();
				dispatchEvent(new AnimationStateEvent(AnimationStateEvent.AnimationEnded));				
				dispatchEvent(new AnimationStateEvent(AnimationStateEvent.AnimationUndo));				
				currentBlock = new Array();
				if (undoStack == null || undoStack.length == 0)
				{
					currentlyAnimating = false;
					awaitingStep = false;
					dispatchEvent(new AnimationStateEvent(AnimationStateEvent.AnimationUndoUnavailable));
				}

				return false;
			}
			return true;
		}
		
		
		private function undoLastBlock()
		{
			
			if (undoAnimationStepIndices.length == 0)
			{

				// Nothing on the undo stack.  Return
				return;
				
			}
			if (undoAnimationStepIndices.length > 0)
			{
				doingUndo = true;
				var anyAnimations:Boolean = false;
				currentAnimation = undoAnimationStepIndices.pop();
				currentBlock= new Array();
				var undo : Array = undoStack[undoStack.length - 1];
				var i:int;
				for (i = undo.length - 1; i >= 0; i--)
				{
					var animateNext : Boolean =  undo[i].addUndoAnimation(currentBlock);
					anyAnimations = anyAnimations || animateNext;

				}
				currFrame = 0;

				// Hack:  If there are not any animations, and we are currently paused,
				// then set the current frame to the end of the animation, so that we will
				// advance immediagely upon the next step button.  If we are not paused, then
				// animate as normal.
				if (!anyAnimations && animationPaused  )
				{
					currFrame = animationBlockLength;
				}
				currentlyAnimating = true;				
			}
			
		}
		private function parseBool(str):Boolean
		{
			var uppercase:String = str.toUpperCase();
			var returnVal:Boolean =  ! (uppercase == "False" || uppercase == "f" || uppercase == " 0" || uppercase == "0");
			return returnVal;

		}
		
		public function setLayer(shown, ...args)
		{
			animatedObjects.setLayer(shown, args)
		}
		
		
		public function setAllLayers(...args)
		{
			animatedObjects.setAllLayers(args);
		}
		
		private function startNextBlock()
		{
			awaitingStep = false;
			currentBlock = new Array();
			var undoBlock : Array = new Array();
			if (currentAnimation == AnimationSteps.length )
			{
				currentlyAnimating = false;
				awaitingStep = false;
				dispatchEvent(new AnimationStateEvent(AnimationStateEvent.AnimationEnded));
				return;
			}
			undoAnimationStepIndices.push(currentAnimation);

			var foundBreak:Boolean = false;

			var anyAnimations:Boolean = false;
			while (currentAnimation < AnimationSteps.length && !foundBreak)
			{

				
				var nextCommand:Array = AnimationSteps[currentAnimation].split(";");
				if (nextCommand[0].toUpperCase() == "CREATECIRCLE")
				{
					animatedObjects.addCircleObject(int(nextCommand[1]), nextCommand[2]);
					if (nextCommand.length > 4)
					{
						animatedObjects.setNodePosition(int(nextCommand[1]), int(nextCommand[3]), int(nextCommand[4]));
						undoBlock.push(new UndoCreate(int(nextCommand[1])));
					}

				}
				else if (nextCommand[0].toUpperCase() == "CREATELINKEDLIST")
				{
					if (nextCommand.length == 11)
					{
						animatedObjects.addLinkedListObject(int(nextCommand[1]), nextCommand[2], int(nextCommand[3]), int(nextCommand[4]), Number(nextCommand[7]), parseBool(nextCommand[8]), parseBool(nextCommand[9]),int(nextCommand[10]));
					}
					else
					{
						animatedObjects.addLinkedListObject(int(nextCommand[1]), nextCommand[2], int(nextCommand[3]), int(nextCommand[4]));
					}
					if (nextCommand.length > 6)
					{
						animatedObjects.setNodePosition(int(nextCommand[1]), int(nextCommand[5]), int(nextCommand[6]));
						undoBlock.push(new UndoCreate(int(nextCommand[1])));
					}

				}
				else if (nextCommand[0].toUpperCase() == "CREATEBTREENODE")
				{

					animatedObjects.addBTreeNode(int(nextCommand[1]), Number(nextCommand[2]), Number(nextCommand[3]), int(nextCommand[4]), uint(nextCommand[7]), uint(nextCommand[8]));
					animatedObjects.setNodePosition(int(nextCommand[1]), int(nextCommand[5]), int(nextCommand[6]));
					undoBlock.push(new UndoCreate(int(nextCommand[1])));
				}
				else if (nextCommand[0].toUpperCase() == "CREATERECTANGLE")
				{
					if (nextCommand.length == 9)
					{
						animatedObjects.addRectangleObject(int(nextCommand[1]), nextCommand[2], int(nextCommand[3]), int(nextCommand[4]), nextCommand[7], nextCommand[8]);
					}
					else
					{
						animatedObjects.addRectangleObject(int(nextCommand[1]), nextCommand[2], int(nextCommand[3]), int(nextCommand[4]));
					}
					if (nextCommand.length > 6)
					{
						animatedObjects.setNodePosition(int(nextCommand[1]), int(nextCommand[5]), int(nextCommand[6]));
						undoBlock.push(new UndoCreate(int(nextCommand[1])));
					}

				}
				else if (nextCommand[0].toUpperCase() == "CREATEHIGHLIGHTCIRCLE")
				{
					if (nextCommand.length > 5)
					{
						animatedObjects.addHighlightCircleObject(int(nextCommand[1]), int(nextCommand[2]), Number(nextCommand[5]));
					}
					else
					{
						animatedObjects.addHighlightCircleObject(int(nextCommand[1]), int(nextCommand[2]));						
					}
					if (nextCommand.length > 4)
					{
						animatedObjects.setNodePosition(int(nextCommand[1]), int(nextCommand[3]), int(nextCommand[4]));
					}
					undoBlock.push(new UndoCreate(int(nextCommand[1])));


				}
				else if (nextCommand[0].toUpperCase() == "CREATELABEL")
				{
					if (nextCommand.length == 6)
					{
						animatedObjects.addLabelObject(int(nextCommand[1]), nextCommand[2], parseBool(nextCommand[5]));						
					}
					else
					{
						animatedObjects.addLabelObject(int(nextCommand[1]), nextCommand[2]);
					}
					if (nextCommand.length >= 5)
					{

						animatedObjects.setNodePosition(int(nextCommand[1]), int(nextCommand[3]), int(nextCommand[4]));
					}
					undoBlock.push(new UndoCreate(int(nextCommand[1])));
				}
				else if (nextCommand[0].toUpperCase() == "DELETE")
				{
					var objectID : int  = int(nextCommand[1]);

					var i : int;
					var removedEdges = animatedObjects.deleteIncident(objectID);
					if (removedEdges.length > 0)
					{
						undoBlock = undoBlock.concat(removedEdges);
					}
					var obj:AnimatedObject = animatedObjects.getObject(objectID);
					if (obj)
					{
						undoBlock.push(obj.createUndoDelete());
						animatedObjects.removeObject(objectID);
					}
				}
				else if (nextCommand[0].toUpperCase() == "MOVE")
				{
					var nextAnim:SingleAnimation = new SingleAnimation();
					nextAnim.objectID = int(nextCommand[1]);
					nextAnim.fromX = animatedObjects.nodeX(nextAnim.objectID);
					nextAnim.fromY = animatedObjects.nodeY(nextAnim.objectID);
					nextAnim.toX = int(nextCommand[2]);
					nextAnim.toY = int(nextCommand[3]);
					currentBlock.push(nextAnim);

					undoBlock.push(new UndoMove(nextAnim.objectID, nextAnim.toX, nextAnim.toY, nextAnim.fromX, nextAnim.fromY));

					anyAnimations = true;
				}
				else if (nextCommand[0].toUpperCase() == "CONNECT")
				{
					
					if (nextCommand.length > 7)
					{
						animatedObjects.connectEdge(int(nextCommand[1]), int(nextCommand[2]), int(nextCommand[3]), Number(nextCommand[4]), parseBool(nextCommand[5]), nextCommand[6], int(nextCommand[7]));
					}
					else if (nextCommand.length > 6)
					{
						animatedObjects.connectEdge(int(nextCommand[1]), int(nextCommand[2]), int(nextCommand[3]), Number(nextCommand[4]), parseBool(nextCommand[5]), nextCommand[6]);
					}
					else if (nextCommand.length > 5)
					{
						animatedObjects.connectEdge(int(nextCommand[1]), int(nextCommand[2]), int(nextCommand[3]), Number(nextCommand[4]), parseBool(nextCommand[5]));
					}
					else if (nextCommand.length > 4)
					{
						animatedObjects.connectEdge(int(nextCommand[1]), int (nextCommand[2]), int(nextCommand[3]), Number(nextCommand[4]));
					}
					else if (nextCommand.length > 3)
					{
						animatedObjects.connectEdge(int(nextCommand[1]), int (nextCommand[2]), int(nextCommand[3]));						
					}
					else
					{
						animatedObjects.connectEdge(int(nextCommand[1]), int (nextCommand[2]));
						
					}
					undoBlock.push(new UndoConnect(int(nextCommand[1]), int (nextCommand[2]), false));
				}
				else if (nextCommand[0].toUpperCase() == "SETFOREGROUNDCOLOR")
				{
					var id:int = int(nextCommand[1]);
					var oldColor = animatedObjects.foregroundColor(id);
					animatedObjects.setForegroundColor(id, int (nextCommand[2]));
					undoBlock.push(new UndoSetForegroundColor(id, oldColor));
				}
				else if (nextCommand[0].toUpperCase() == "SETBACKGROUNDCOLOR")
				{
					id = int(nextCommand[1]);
					oldColor = animatedObjects.backgroundColor(id);
					animatedObjects.setBackgroundColor(id, int (nextCommand[2]));
					undoBlock.push(new UndoSetBackgroundColor(id, oldColor));
				}
				else if (nextCommand[0].toUpperCase() == "SETHEIGHT")
				{
					id = int(nextCommand[1]);
					animatedObjects.setHeight(id, int (nextCommand[2]));
					var oldHeight = animatedObjects.getHeight(id);
					undoBlock.push(new UndoSetHeight(id, oldHeight));
				}
				else if (nextCommand[0].toUpperCase() == "SETWIDTH")
				{
					id = int(nextCommand[1]);
					animatedObjects.setWidth(id, int (nextCommand[2]));
					var oldWidth = animatedObjects.getWidth(id);
					undoBlock.push(new UndoSetHeight(id, oldWidth));
				}

				else if (nextCommand[0].toUpperCase() == "DISCONNECT")
				{
					var undoConnect = animatedObjects.disconnect(int(nextCommand[1]), int (nextCommand[2]));
					if (undoConnect != null)
					{
						undoBlock.push(undoConnect);
					}
				}
				else if (nextCommand[0].toUpperCase() == "SETTEXT")
				{
					if (nextCommand.length > 2)
					{
						var oldText:String = animatedObjects.getText(int(nextCommand[1]), int(nextCommand[3]));
						animatedObjects.setText(int(nextCommand[1]), nextCommand[2], int(nextCommand[3]));
						undoBlock.push(new UndoSetText(int(nextCommand[1]), oldText, int(nextCommand[3]) ));					
					}
					else
					{
						oldText = animatedObjects.getText(int(nextCommand[1]), 0);
						animatedObjects.setText(int(nextCommand[1]), nextCommand[2], 0);
						undoBlock.push(new UndoSetText(int(nextCommand[1]), oldText, 0));					
					}
				}
				else if (nextCommand[0].toUpperCase() == "SETTEXTCOLOR")
				{
					if (nextCommand.length > 3)
					{
						oldColor = animatedObjects.getTextColor(int(nextCommand[1]), int(nextCommand[3]));
						animatedObjects.setTextColor(int(nextCommand[1]), uint(nextCommand[2]), int(nextCommand[3]));
						undoBlock.push(new UndoSetTextColor(int(nextCommand[1]), oldColor, int(nextCommand[3]) ));					
					}
					else
					{
						oldColor = animatedObjects.getTextColor(int(nextCommand[1]), 0);
						animatedObjects.setTextColor(int(nextCommand[1]),uint(nextCommand[2]), 0);
						undoBlock.push(new UndoSetTextColor(int(nextCommand[1]), oldColor, 0));					
					}
				}			
				else if (nextCommand[0].toUpperCase() == "SETALPHA")
				{
					var oldAlpha:Number = animatedObjects.getAlpha(int(nextCommand[1]));
					animatedObjects.setAlpha(int(nextCommand[1]), Number(nextCommand[2]));
					undoBlock.push(new UndoSetAlpha(int(nextCommand[1]), oldAlpha));					
				}
				else if (nextCommand[0].toUpperCase() == "STEP")
				{
					foundBreak = true;
				}
				else if (nextCommand[0].toUpperCase() == "SETHIGHLIGHT")
				{
					var newHighlight:Boolean = parseBool(nextCommand[2]);
					animatedObjects.setHighlight( int(nextCommand[1]), newHighlight);
					undoBlock.push(new UndoHighlight( int(nextCommand[1]), !newHighlight));
				}
				else if (nextCommand[0].toUpperCase() == "SETEDGEHIGHLIGHT")
				{
					newHighlight = parseBool(nextCommand[3]);
					var oldHighlight = animatedObjects.setEdgeHighlight( int(nextCommand[1]), int(nextCommand[2]), newHighlight);
					undoBlock.push(new UndoHighlightEdge(int(nextCommand[1]), int(nextCommand[2]), oldHighlight));
				}
				else if (nextCommand[0].toUpperCase() == "SETEDGECOLOR")
				{
					var newColor = uint(nextCommand[3]);
					oldColor = animatedObjects.setEdgeColor( int(nextCommand[1]), int(nextCommand[2]), newColor);				
					// TODO:  ADD UNDO INFORMATION HERE!!
				}

				else if (nextCommand[0].toUpperCase() == "SETLAYER")
				{
					animatedObjects.setLayer(int(nextCommand[1]), int(nextCommand[2]));
					//TODO: Add undo information here
				}
				else if (nextCommand[0].toUpperCase() == "SETNUMELEMENTS")
				{
					var oldElem = animatedObjects.getObject(int(nextCommand[1]));
					undoBlock.push(new UndoSetNumElements(oldElem, int(nextCommand[2])));
					animatedObjects.setNumElements(int(nextCommand[1]), int(nextCommand[2]));
					//TODO:  Decreasing the number of elements doesn't save the old one yet ...
				}
				else if (nextCommand[0].toUpperCase() == "SETPOSITION")
				{
					var nodeID:int = int(nextCommand[1]);
					var oldX:Number = animatedObjects.getNodeX(nodeID);
					var oldY:Number = animatedObjects.getNodeY(nodeID);
					undoBlock.push(new UndoSetPosition(nodeID, oldX, oldY));
					animatedObjects.setNodePosition(nodeID, Number(nextCommand[2]), Number(nextCommand[3]));
					//TODO:  Decreasing the number of elements doesn't save the old one yet ...
				}
				else if (nextCommand[0].toUpperCase() == "SETNULL")
				{
					var oldNull:Boolean = animatedObjects.getNull(int(nextCommand[1]));
					animatedObjects.setNull(int(nextCommand[1]), parseBool(nextCommand[2]));
					undoBlock.push(new UndoSetNull(int(nextCommand[1]), oldNull));					
				}
				else
				{
					throw new Error("Unknown command: " + nextCommand[0]);					
				}
				currentAnimation = currentAnimation+1;
			}
			currFrame = 0;

			// Hack:  If there are not any animations, and we are currently paused,
			// then set the current frame to the end of the anumation, so that we will
			// advance immediagely upon the next step button.  If we are not paused, then
			// animate as normal.

			if (!anyAnimations && animationPaused || (!anyAnimations && currentAnimation == AnimationSteps.length) )
			{
				currFrame = animationBlockLength;
			}

			undoStack.push(undoBlock);
		}
		public function lerp(from:Number, to:Number, percent:Number):Number
		{
			var delta:Number = to - from;
			var deltaDiff:Number = delta*percent;
			var returnVal:Number = from + deltaDiff;
			var returnVal2:int = returnVal;
			return returnVal;
			// STOP CHANGING ME!
			//var returnVal : int = (to - from) * percent + from;
			//return returnVal;
			// STOP CHANGING ME!
		}

	}
}