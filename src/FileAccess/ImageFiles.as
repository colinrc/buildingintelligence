package FileAccess
{
	import flash.filesystem.*;
	
	import mx.collections.ArrayCollection;
	
	public class ImageFiles
	{
		private var file:File;
		public function ImageFiles():void {
		}
		public function getImageNames():ArrayCollection {
			file = new File();
			
			file = File.applicationResourceDirectory.resolvePath("lib"+File.separator+"maps"+File.separator);
			var files:Array = file.getDirectoryListing();
			var imageFiles:ArrayCollection= new ArrayCollection();
			
			var obj:Object = new Object();
			obj.name = "No Map";
			imageFiles.addItem(obj);
			for (f1 in files) {
				var ext:String = files[f1].extension;
				if ( ext == "jpg" | ext == "bmp" | ext == "png" | ext == "swf") {
					var str:String = files[f1].name;
					//var result:Array = str.split(/\.+/);
					var obj:Object = new Object();
					obj.name = str;
					obj.nativePath = files[f1].nativePath;
					imageFiles.addItem(obj);
				}
			}
			return imageFiles;
		}
		public function getBackgroundImageNames():ArrayCollection {
			file = new File();
			
			file = File.applicationResourceDirectory.resolvePath("lib"+File.separator+"backgrounds"+File.separator);
			var files:Array = file.getDirectoryListing();
			var imageFiles:ArrayCollection= new ArrayCollection();
			
			var obj:Object = new Object();
			obj.name = "No Background";
			imageFiles.addItem(obj);
			for (f1 in files) {
				var ext:String = files[f1].extension;
				if ( ext == "jpg" | ext == "bmp" | ext == "png" | ext == "swf") {
					var str:String = files[f1].name;
					//var result:Array = str.split(/\.+/);
					var obj:Object = new Object();
					obj.name = str;
					obj.nativePath = files[f1].nativePath;
					imageFiles.addItem(obj);
				}
			}
			return imageFiles;
		}
	}
}