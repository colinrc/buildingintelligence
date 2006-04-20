import mx.controls.*;
import mx.utils.Delegate;

class Forms.Control.ClientControls extends Forms.BaseForm {
	private var restartClient_btn:Button;
	private var monitorOutput_ta:TextArea;
	private var sftpOutput_ta:TextArea;
	private var monitorStatus_mc:MovieClip;
	private var sftpStatus_mc:MovieClip;		
	private var sftpStatus:Boolean;
	private var monitorStatus:Boolean;
	private var ipAddress_ti:TextInput;
	private var userName_ti:TextInput;
	private var password_ti:TextInput;
	private var monitorConnect_btn:Button;
	private var monitorDisconnect_btn:Button;	
	private var sftpConnect_btn:Button;
	private var sftpDisconnect_btn:Button;		
	private var monitorConnection:Object;	
	private var sftpConnection:Object;		
	private var dataObject:Object;
	private var ipAddress:String;
	private var userName:String;
	private var password:String;
	private var name_ti:TextInput;
	private var design_cmb:ComboBox;
	public function ClientControls() {
	}
	public function onLoad():Void {
		password_ti.password = true;
		ipAddress_ti.restrict = "0-9.";
		ipAddress_ti.maxChars = 15;
		sftpStatus = undefined;
		monitorStatus = undefined;		
		name_ti.text = dataObject.description;
		for(var design in dataObject.serverParent.serverDesign.clients){
			design_cmb.addItem(dataObject.serverParent.serverDesign.clients[design].description);
		}
		if(dataObject.clientDesign.description != undefined){
			design_cmb.text = dataObject.clientDesign.description;
		} else{
			dataObject.setDetails(new Object({ipAddress:ipAddress_ti.text,userName:userName_ti.text,password:password_ti.text,description:name_ti.text,clientDesign:design_cmb.text}));
		}
		password_ti.text = password;
		ipAddress_ti.text = ipAddress;
		userName_ti.text = userName;		
		var listenerObject:Object = new Object();
		listenerObject.change = function(eventObject:Object) {
	    	dataObject.setDetails(new Object({ipAddress:ipAddress_ti.text,userName:userName_ti.text,password:password_ti.text,description:name_ti.text,clientDesign:design_cmb.text}));
		};
		password_ti.addEventListener("change", Delegate.create(this,listenerObject.change));
		ipAddress_ti.addEventListener("change", Delegate.create(this,listenerObject.change));
		userName_ti.addEventListener("change", Delegate.create(this,listenerObject.change));
		restartClient_btn.addEventListener("click", Delegate.create(this, restartClient));
		monitorConnect_btn.addEventListener("click", Delegate.create(this, monitorConnect));
		monitorDisconnect_btn.addEventListener("click", Delegate.create(this, monitorDisconnect));
		sftpConnect_btn.addEventListener("click", Delegate.create(this, sftpConnect));
		sftpDisconnect_btn.addEventListener("click", Delegate.create(this, sftpDisconnect));
		sftpConnection.attachView(this);
		monitorConnection.attachView(this);
	}
	public function onUnload():Void{
		sftpConnection.detachView();
		monitorConnection.detachView();
	}
	public function notifyChange():Void{
		sftpOutput_ta.text = sftpConnection.getOutput();
		monitorOutput_ta.text = monitorConnection.getOutput();
		var tempSftpStatus = sftpConnection.getStatus();
		if(tempSftpStatus != sftpStatus){
			sftpStatus = tempSftpStatus;
			sftpStatus_mc.removeMovieClip();
			if(sftpStatus){
				sftpStatus_mc = this.attachMovie("on","sftpStatus_mc",3);
			} else{
				sftpStatus_mc = this.attachMovie("off","sftpStatus_mc",3);
			}
			sftpStatus_mc.setSize(32,32);
			sftpStatus_mc._x = 573;
			sftpStatus_mc._y = 146;
		}
		var tempMonitorStatus = monitorConnection.getStatus();
		if(tempMonitorStatus != monitorStatus){
			monitorStatus = tempMonitorStatus;
			monitorStatus_mc.removeMovieClip();
			if(monitorStatus){
				monitorStatus_mc = this.attachMovie("on","monitorStatus_mc",2);
			} else{
				monitorStatus_mc = this.attachMovie("off","monitorStatus_mc",2);
			}
			monitorStatus_mc.setSize(32,32);
			monitorStatus_mc._x = 227;
			monitorStatus_mc._y = 115;
		}
	}
	private function restartClient():Void{
		monitorConnection.restartClient();
	}
	private function monitorConnect():Void{
		monitorConnection.connect(ipAddress_ti.text,10002);
	}
	private function monitorDisconnect():Void{
		monitorConnection.disconnect();
	}
	private function sftpConnect():Void{
		sftpConnection.connect(userName_ti.text,22,ipAddress_ti.text,password_ti.text);
	}
	private function sftpDisconnect():Void{
		sftpConnection.disconnect();		
	}
}
