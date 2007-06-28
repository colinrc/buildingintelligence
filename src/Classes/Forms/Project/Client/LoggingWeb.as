import mx.controls.*;
class Forms.Project.Client.LoggingWeb extends Forms.BaseForm {
	private var url_ti:TextInput;
	private var url:String;
	public function onLoad() {
		var changeListener:Object = new Object();
		changeListener.change = function(eventObject:Object) {
			_global.unSaved = true;
		};
		url_ti.addEventListener("change", changeListener);
		if (url.length) {
			url_ti.text = url;
		}
	}
}
