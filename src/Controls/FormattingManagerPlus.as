package Controls
{
	public class FormattingManagerPlus
	{
		import mx.controls.dataGridClasses.DataGridColumn;
		import mx.formatters.*;
		import Controls.MaskFormatter;

		public static function setFormat(
			dgc:mx.controls.dataGridClasses.DataGridColumn,
			formatData:Object):void {

			var  formatter:Formatter = null;
			var  fs:String;
			if (formatData is String)
				fs = formatData as String;
			else
				fs = formatData.formatString;

			switch (fs.toLowerCase()) {
				case "ssn":
					formatter = new MaskFormatter("###-##-####");
					break;
				case "money":
					formatter = new CurrencyFormatter();
					CurrencyFormatter(formatter).precision=2;		
					break;
				case "phone":
					formatter = new PhoneFormatter();
					break;
				case "shortdate":
					formatter = new DateFormatter();
					break;
				case "zip":
					formatter = new ZipCodeFormatter();			
					break;
				default:
					if (fs.indexOf("#")!=-1) {
						formatter = new MaskFormatter(fs);		
						};
			}
			if (!(formatData is String)) {
				for (var property:String in formatData) {
					try {
						formatter[property] = formatData[property];
					} catch (err:Error) {
						// Property does not match formatter type
					}
				}
			}
			if (formatter) {
				dgc.labelFunction = function (
					item:Object,
					dgc:mx.controls.dataGridClasses.DataGridColumn
				):String {
					return formatter.format(item[dgc.dataField]);
				}
			}
		}

	}
}