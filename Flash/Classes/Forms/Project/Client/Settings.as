import mx.controls.*;
import mx.utils.Delegate;
class Forms.Project.Client.Settings extends Forms.BaseForm {
	private var save_btn:Button;
	private var form_mc:MovieClip;
	private var dataObject:Object;
	private var adminPin:String;
	private var adminPin_ti:TextInput;
	private var applicationXML:String;
	private var applicationXML_ti:TextInput;
	private var integratorHtml:String;
	private var integratorHtml_ti:TextInput;
	public function onLoad():Void {
		adminPin_ti.restrict = "0-9";
		if (adminPin.length) {
			adminPin_ti.text = adminPin;
		}
		if (applicationXML.length) {
			applicationXML_ti.text = applicationXML;
		}
		if (integratorHtml.length) {
			integratorHtml_ti.text = integratorHtml;
		}
		save_btn.addEventListener("click", Delegate.create(this, save));
		setAdvanced();
	}
	public function setAdvanced() {
	}
	private function save() {
		dataObject.setData({adminPin:adminPin_ti.text, applicationXML:applicationXML_ti.text, integratorHtml:integratorHtml_ti.text});
		_global.saveFile("Project");
	}
}
