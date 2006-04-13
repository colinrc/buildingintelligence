import mx.controls.*;
import mx.utils.Delegate;
class Forms.Control.SFTP extends Forms.BaseForm {
	private var dataObject:Object;
	private var left_li:List;
	private var right_li:List;
	private var getSelected_btn:Button;
	private var putSelected_btn:Button;
	private var output_ta:TextArea;
	private var localDirectory_cmb:ComboBox;
	private var remoteDirectory_cmb:ComboBox;
	private var sftpConnection:Object;

	public function SFTP() {
	}
	public function onUnload():Void{
		sftpConnection.detachView();
	}
	public function onLoad():Void {
		output_ta.editable = false;
		sftpConnection.attachView(this);
		if (sftpConnection.isServer()) {
			localDirectory_cmb.dataProvider = ["/", "/script", "/config", "/log", "/datafiles"];
			remoteDirectory_cmb.dataProvider = ["/", "/script", "/config", "/log", "/datafiles"];
		} else {
			localDirectory_cmb.dataProvider = ["/", "/lib/maps", "/lib/backgrounds", "/lib/icons", "/lib/sounds"];
			remoteDirectory_cmb.dataProvider = ["/", "/lib/maps", "/lib/backgrounds", "/lib/icons", "/lib/sounds"];
		}
		right_li.iconFunction = function(item:Object):String  {
			return "Icon:file";
		};
		right_li.iconField = "icon";
		left_li.iconFunction = function(item:Object):String  {
			return "Icon:file";
		};
		left_li.iconField = "icon";
		getSelected_btn.addEventListener("click", Delegate.create(this, getItem));
		putSelected_btn.addEventListener("click", Delegate.create(this, putItem));
		localDirectory_cmb.addEventListener("change", Delegate.create(this, localChange));
		remoteDirectory_cmb.addEventListener("change", Delegate.create(this, remoteChange));
	}
	public function SFTPdisconnected():Void{
		right_li.removeAll();
		remoteDirectory_cmb.selectedIndex = 0;		
	}
	public function notifyChange():Void{
		refreshOutput();
	}
	public function needRefresh():Void{
		refreshLocal();
		refreshRemote();
	}
	public function localChange(eventObject:Object):Void {
		sftpConnection.setLocalPath(localDirectory_cmb.text);
		refreshLocal();
	}
	public function remoteChange(eventObject:Object):Void {
		sftpConnection.setRemotePath(remoteDirectory_cmb.text);
		refreshRemote();
	}
	public function getItem():Void {
		sftpConnection.getItem(right_li.selectedItem.label);
	}
	public function putItem():Void {
		sftpConnection.getItem(left_li.selectedItem.label);		
	}
	public function refreshRemote():Void {
		right_li.dataProvider = sftpConnection.getRemoteList();
	}
	public function refreshLocal():Void {
		left_li.dataProvider = sftpConnection.getLocalList();
	}
	public function refreshOutput():Void {
		output_ta.text = sftpConnection.getOutput();
	}
}
