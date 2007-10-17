package FileAccess
{
	import flash.filesystem.*;
	public class IconFiles
	{
		private var file:File;
		public function IconFiles():void {
		}
		public function getIconNames():Array {
			file = new File();
			
			file = File.applicationResourceDirectory.resolvePath("lib"+File.separator+"icons"+File.separator);
			var files:Array = file.getDirectoryListing();
			var iconFiles:Array= new Array();
			for (f1 in files) {
				var ext:String = files[f1].extension;
				if ( ext == "jpg" | ext == "bmp" | ext == "png" | ext == "ico") {
					iconFiles.push(files[f1]);
				}
			}
			return iconFiles;
		}
	}
}