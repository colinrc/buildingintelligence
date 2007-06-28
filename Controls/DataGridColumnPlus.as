package Controls
{
	import mx.controls.dataGridClasses.DataGridColumn;

	public class DataGridColumnPlus  extends mx.controls.dataGridClasses.DataGridColumn {
 		public function set extendedProperties(val:Object) :void {
				this.itemRenderer["properties"] = val;
		}

		public function  set formatString( fs :String ) : void{
			FormattingManager.setFormat(this, fs);
		}

		public function  set formatData( fd :Object ) : void{
			FormattingManager.setFormat(this, fd);
		}
	}
}