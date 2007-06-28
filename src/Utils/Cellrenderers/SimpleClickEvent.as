package Utils.Cellrenderers
{
	import flash.events.Event;

    public class SimpleClickEvent extends Event
    {
        public static var CLICK:String = "SIMPLE_CLICK";
        
        public var vo:*;
        
        public function SimpleClickEvent(a_vo:*)
        {
            // pass type and set bubbles (2nd param) to true
            super(CLICK, true, true);
            vo = a_vo;
        }
    }
}
