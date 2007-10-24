package FileAccess
{
	import flash.events.Event;
	import flash.filesystem.*;
	
	import mx.events.*;
		
	public class XMLFile
	{
		private var stream:FileStream;
		private var detail:String;
		private var file:File;
		
		public function getXMLFile(name:String):XML {
			detail= null;
			file = new File();
			file = File.applicationResourceDirectory.resolvePath(name);
			
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
			file = File.applicationResourceDirectory.resolvePath(fileName);
			
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
		public function saveFile(fileName:String, myXMLString:String):void {
			file = new File(fileName);
			
			if (stream != null)	{
				stream.close();
			}
			stream = new FileStream();
	        stream.open(file, FileMode.WRITE);
	        stream.position = 0;
	        stream.writeUTFBytes(myXMLString);
	        stream.close()
			
			return;
		}
		
		public function copyFile(fileNameFrom:String, fileNameTo:String):void {
			var fromFile:File = new File(fileNameFrom);
			var detail:String = null;
			
			if (stream != null)	{
				stream.close();
			}
			stream = new FileStream();
	        stream.open(fromFile, FileMode.READ);
	        detail = stream.readUTFBytes(stream.bytesAvailable);
			
			
			file = new File(fileNameTo);
			
			if (stream != null)	{
				stream.close();
			}
			stream = new FileStream();
	        stream.open(file, FileMode.WRITE);
	        stream.position = 0;
	        stream.writeUTFBytes(detail);
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