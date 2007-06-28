package XMLloaders {
    import flash.display.Sprite;
    import flash.events.*;
    import flash.net.FileReference;
    import flash.net.URLRequest;
    import flash.net.FileFilter;
    import mx.core.Application;

    public class LoadMyFile extends Sprite {
        private var uploadURL:URLRequest;
        private var file:FileReference = new FileReference();
        public var loader:XLoader;

        public function LoadMyFile() {
           // uploadURL = new URLRequest();
           // uploadURL.url = "file:projects";
           // file = new FileReference();
            
            file.addEventListener(Event.SELECT, selectHandler);
            file.addEventListener(IOErrorEvent.IO_ERROR, ioErrorHandler);
            file.addEventListener(ProgressEvent.PROGRESS, progressHandler);
            file.addEventListener(Event.COMPLETE, completeHandler);
            var ff:FileFilter = new FileFilter("eLifeAdmin Projects (*.elp)", "*.elp");
            var ffArray:Array = new Array(ff);
            file.browse(ffArray);
        }

        private function selectHandler(event:Event):void {
            var file:FileReference = FileReference(event.target);
            trace("selectHandler: name=" + file.name );
            loadFile(file);
        }

		public function loadFile(file:FileReference):void {
			
		    loader = XLoader.getInstance();
		    loader.setURLandLoad("projects/"+file.name);
		    loader.addEventListener("onInit", fileLoaded);
		 
		}
		public function fileLoaded(event:Event):void {
			var proj:XML = loader.data;
			Application.application.setProjectWithXML(proj);
			trace(proj.toXMLString());
			
		    
		}





        private function ioErrorHandler(event:IOErrorEvent):void {
            trace("ioErrorHandler: " + event);
        }

        private function progressHandler(event:ProgressEvent):void {
            var file:FileReference = FileReference(event.target);
            
            trace("progressHandler: name=" + file.name + " bytesLoaded=" + event.bytesLoaded + " bytesTotal=" + event.bytesTotal);
        }

        private function completeHandler(event:Event):void {
            trace("completeHandler: " + event);
        }
    }
}