import mx.controls.*;
import mx.utils.Delegate;
class Forms.Publish extends Forms.BaseForm {
	private var publish_btn:Button;
	private var dir_btn:Button;
	private var dir_ti:TextInput;
	private var serverName_ti:TextInput;
	private var clientName_ti:TextInput;	
	public function init():Void {
		dir_ti.text = _global.project.path;
		dir_btn.addEventListener("click", Delegate.create(this, setDir));
		publish_btn.addEventListener("click", Delegate.create(this, publishServer));		
	}
	public function publishServer():Void {
		mdm.FileSystem.saveFile(dir_ti.text+"\\"+serverName_ti.text, _global.writeXMLFile(_global.server_test.toXML(), 0));
		mdm.FileSystem.saveFile(dir_ti.text+"\\"+clientName_ti.text, _global.writeXMLFile(_global.client_test.toXML(), 0));
	}
	public function setDir():Void {
		mdm.Dialogs.BrowseFolder.title = "Please select a Folder";
		dir_ti.text =mdm.Dialogs.BrowseFolder.show();
	}
}
