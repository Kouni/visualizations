package
{
	import flash.events.Event;
	
	public class AnimationStateEvent extends Event
	{
		
		public static const AnimationStarted:String = "AnimationStarted"; 
		public static const AnimationEnded:String = "AnimationEnded"; 
		public static const AnimationUndo:String = "AnimationUndo"; 
		public static const AnimationUndoUnavailable:String = "AnimationUndoUnavailable"; 
		public static const AnimationWaiting:String = "AnimationWaiting"; 
		
		public function AnimationStateEvent(type)
		{
			super(type, true);			
		}
		
	}

}