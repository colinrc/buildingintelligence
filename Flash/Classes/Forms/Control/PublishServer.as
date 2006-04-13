import mx.controls.*;
import mx.utils.Delegate;
class Forms.Control.PublishServer extends Forms.BaseForm {
	private var dataObject:Object;
	private var sftpConnection:Object;
	private var output_ta:TextArea;
	private var appPath:String;
	private var right_li:List;
	private var left_li:List;
	private var addSelected_btn:Button;
	private var addAll_btn:Button;
	private var removeSelected_btn:Button;
	private var removeAll_btn:Button;
	public function PublishServer() {
	}
	public function onUnload():Void{
		sftpConnection.dettachView();
	}	
	public function onLoad():Void {
		sftpConnection.attachView(this);		
		output_ta.editable = false;
		addSelected_btn.addEventListener("click", Delegate.create(this, addSel));
		addAll_btn.addEventListener("click", Delegate.create(this, addAll));
		removeSelected_btn.addEventListener("click", Delegate.create(this, remSel));
		removeAll_btn.addEventListener("click", Delegate.create(this, remAll));		
	}
	public function SFTPdisconnected():Void{
	}
	public function notifyChange():Void{
		refreshOutput();
	}
	public function needRefresh():Void{
		//refreshLocal();
		//refreshRemote();
	}
	public function localChange(eventObject:Object):Void {
		//sftpConnection.setLocalPath(localDirectory_cmb.text);
	}
	public function remoteChange(eventObject:Object):Void {
		//sftpConnection.setRemotePath(remoteDirectory_cmb.text);
	}
	public function getItem():Void {
		//sftpConnection.getItem(right_li.selectedItem.label);
	}
	public function putItem():Void {
		//sftpConnection.getItem(left_li.selectedItem.label);		
	}
	public function refreshRemote():Void {
		//right_li.dataProvider = sftpConnection.getRemoteList();
	}
	public function refreshLocal():Void {
		//left_li.dataProvider = sftpConnection.getLocalList();
	}
	public function refreshOutput():Void {
		output_ta.text = sftpConnection.getOutput();
	}
	private function addSel() {
		if (left_li.selectedItem != undefined) {
			right_li.addItem(left_li.removeItemAt(left_li.selectedIndex));
			right_li.sortItemsBy("label", "ASC");
		}
	}
	private function addAll() {
		var leftLength = left_li.length;
		for (var leftIndex = 0; leftIndex < leftLength; leftIndex++) {
			right_li.addItem(right_li.removeItemAt(0));
		}
		right_li.sortItemsBy("label", "ASC");
	}
	private function remSel() {
		if (right_li.selectedItem != undefined) {
			left_li.addItem(right_li.removeItemAt(right_li.selectedIndex));
			left_li.sortItemsBy("label", "ASC");
		}
	}
	private function remAll() {
		var rightLength = right_li.length;
		for (var rightIndex = 0; rightIndex < rightLength; rightIndex++) {
			left_li.addItem(right_li.removeItemAt(0));
		}
		left_li.sortItemsBy("label", "ASC");
	}	
}
