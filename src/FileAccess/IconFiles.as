package FileAccess
{
	import flash.filesystem.*;
	
	import mx.collections.ArrayCollection;
	
	public class IconFiles
	{
		private var file:File;
		public function IconFiles():void {
		}
		public function getIconNames():ArrayCollection {
			file = new File();
			
			file = File.applicationStorageDirectory.resolvePath("lib"+File.separator+"icons"+File.separator);
			var files:Array = file.getDirectoryListing();
			var iconFiles:ArrayCollection= new ArrayCollection();
			for (f1 in files) {
				var ext:String = files[f1].extension;
				if ( ext == "jpg" | ext == "bmp" | ext == "png" | ext == "ico") {
					var str:String = files[f1].name;
					var result:Array = str.split(/\.+/);
					var obj:Object = new Object();
					obj.name = result[0];
					obj.nativePath = files[f1].nativePath;
					iconFiles.addItem(obj);
				}
			}
			return iconFiles;
		}
	}
}