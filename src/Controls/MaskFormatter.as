package Controls
{
	import mx.formatters.Formatter;
	import mx.formatters.SwitchSymbolFormatter;

	public class MaskFormatter extends  Formatter {
		private var formatString:String;
		private var sf:SwitchSymbolFormatter;
		public function MaskFormatter( fs:String) {
			formatString = fs;
			sf = new SwitchSymbolFormatter();
		}
		public override function format(val:Object):String {
			return sf.formatValue( formatString, val);
		}
	}
}