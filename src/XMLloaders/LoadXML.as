package XMLloaders
{
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class LoadXML
	{
		private var urlLoader:URLLoader;
		private var myObj:Object;
		static private var sync:Boolean = false;
		
	    private var data:XML;
	    
		public function LoadXML():void {}
		
		public function load(url:String):XML {
			var urlRequest:URLRequest = new URLRequest(url);
			urlLoader = new URLLoader();
			urlLoader.addEventListener("complete", onXMLcompleted);
			urlLoader.addEventListener("ioerror", onXMLfailed);
			urlLoader.load(urlRequest);
			var i:int= 0;
			//while (LoadXML.sync == false) {
				i=i+1;
				trace(i.toString()+sync.toString());
				//wait for event to run
			//}
			return data;
			
			//now wait for load
		}
		private function onXMLcompleted(event:Event):void {
			data = XML(urlLoader.data);
			sync = true;	
		}
		public function getData():XML {
			return data;
		}
		private function onXMLfailed(errorEvent:ErrorEvent):void {
			trace(errorEvent);
			data = null;
			sync = true;
		}
	}
}