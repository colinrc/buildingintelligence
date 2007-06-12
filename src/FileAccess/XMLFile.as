package FileAccess
{
	import flash.filesystem.*;
    import mx.events.*;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.events.FileStream;
	import flash.net.FileReference;
	import mx.utils.ObjectProxy;
	import mx.core.Application;
		
	public class XMLFile
	{
		private var stream:FileStream;
		private var detail:String;
		private var file:File;
		
		public function getXMLFile(name:String):XML {
			detail= null;
			file = new File();
			file = File.appResourceDirectory.resolve(name);
			
			if (stream != null)	{
				stream.close();
			}
			stream = new FileStream();
	        stream.open(file, FileMode.READ);
	        detail = stream.readUTFBytes(stream.bytesAvailable);
			
			return XML(detail);
		}
		
		public function saveXMLFile(fileName:String, myDetail:String):void {
			file = new File();
			file = File.appResourceDirectory.resolve(fileName);
			
			if (stream != null)	{
				stream.close();
			}
			stream = new FileStream();
	        stream.open(file, FileMode.WRITE);
	        stream.position = 0;
	        stream.writeUTFBytes(myDetail);
	        stream.close()
			
			return;
		}
		
		public function saveProjectFile(file:File, myDetail:String):void {
			
			if (stream != null)	{
				stream.close();
			}
			stream = new FileStream();
	        stream.open(file, FileMode.WRITE);
	        stream.position = 0;
	        stream.writeUTFBytes(myDetail);
	        stream.close()
			
			return;
		}
		
        /**
        * Handles I/O errors that may come about when opening the currentFile.
        */
        private function readIOErrorHandler(event:Event):void 
        {
            Alert.show("The specified currentFile cannot be opened.", "Error", Alert.OK, this);
        }
        /**
        * Handles I/O errors that may come about when writing the currentFile.
        */
        private function writeIOErrorHandler(event:Event):void 
        {
            Alert.show("The specified currentFile cannot be saved.", "Error", Alert.OK, this);
        }
	}
}