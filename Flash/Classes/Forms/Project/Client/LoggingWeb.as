import mx.controls.*;
class Forms.Project.Client.LoggingWeb extends Forms.BaseForm {
	private var url_ti:TextInput;
	private var url:String;
	public function onLoad() {
		if (url.length) {
			url_ti.text = url;
		}
	}
}
