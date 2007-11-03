package Events
{
	import flash.events.Event;
	[Event(name="ComboSelectedEvent", type="Events.ComboSelectedEvent")]
	public class ComboSelectedEvent extends Event
	{
		public var label:String;
		public var data:Object;
		public var value:String;
		public static const COMBOSELECTEDEVENT:String = "ComboSelectedEvent";
		public static const CODE:String = "CODE";
		public static const CATALOG:String = "CATALOG";
		public static const CLIENTDESIGN:String = "CLIENTDESIGN";
		
		
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