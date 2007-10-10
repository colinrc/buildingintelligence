package Objects
{
	dynamic public class MyListNode
	{
		public var object:Object;
		public var myXMLnode:XML;
		
		
		public function MyListNode(myXML:XML, obj:Object)
		{
			object = obj;
			myXMLnode = myXML;
		}
		public function getObject():Object {
			return object;
		}
		public function setObject(obj:Object):void {
			object= obj;
		}	
		public function getXML():XML {
			return myXMLnode;
		}	
		public function setXML(obj:XML):void {
			myXMLnode = obj;
		}

	}
}