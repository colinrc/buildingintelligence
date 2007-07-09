package Events
{
	import flash.events.Event;

	public class ComboSelectedEvent extends Event
	{
		public var label:String;
		public var data:Object;
		public var value:String;
		public static const COMBOSELECTEDEVENT:String = "ComboSelectedEvent";
		public function ComboSelectedEvent(myLabel:String, myData:Object, myValue:String)
		{
			super(COMBOSELECTEDEVENT, true, true);
			label = myLabel;
			data = myData;
			value = myValue;
		}
		override public function clone():Event {
			return new ComboSelectedEvent(label, data, value);
		}
		
	}
}