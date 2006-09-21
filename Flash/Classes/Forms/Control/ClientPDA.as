import mx.controls.*;
import mx.utils.Delegate;
class Forms.Control.ClientPDA extends Forms.BaseForm {
	private var clean_chk:mx.controls.CheckBox;
	private var deploy_chk:mx.controls.CheckBox;
	private var key_cmb:ComboBox;
	private var publish_btn:Button;
	private var dataObject:Object;
	public function onLoad():Void {
		for(int index=0;index<256;index++){
			key_cmb.addItem({label:""+index});
		}
	}
	public function doPublish():Void{
	var windowTitle = "";
	var xPos = 0;
	var yPos = 0;
	var width = 0;
	var height = 0;
	var DontEditMe = "";
	var applicationNameAndParameterString = "";
	var pathToExe = "";
	//priority:Number 1 = Idle, 2 = Normal, 3 = High, 4 = Realtime
	var priority = 2;
	//windowStatus:Number 1 = Hidden, 2 = Minimized, 3 = Maximized, 4 = Normal
	var windowStatus = 1;
		mdm.Process.create(windowTitle, xPos, yPos, width, height, DontEditMe, applicationNameAndParameterString, pathToExe, priority, windowStatus);
	}		
}
