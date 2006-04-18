import mx.controls.*;
import mx.utils.Delegate;
import TextField.StyleSheet;

class Forms.Control.ServerControls extends Forms.BaseForm {
	private var start_btn:Button;
	private var stop_btn:Button;
	private var restart_btn:Button;
	private var monitorOutput_ta:TextArea;
	private var serverOutput_ta:TextArea;	
	private var sftpOutput_ta:TextArea;
	private var monitorStatus_mc:MovieClip;
	private var serverStatus_mc:MovieClip;
	private var sftpStatus_mc:MovieClip;		
	private var sftpStatus:Boolean;
	private var monitorStatus:Boolean;
	private var serverStatus:Boolean;
	private var ipAddress_ti:TextInput;
	private var userName_ti:TextInput;
	private var password_ti:TextInput;
	private var serverConnect_btn:Button;
	private var serverDisconnect_btn:Button;	
	private var monitorConnect_btn:Button;
	private var monitorDisconnect_btn:Button;	
	private var sftpConnect_btn:Button;
	private var sftpDisconnect_btn:Button;		
	private var serverConnection:Object;
	private var monitorConnection:Object;	
	private var sftpConnection:Object;		
	private var dataObject:Object;
	private var ipAddress:String;
	private var userName:String;
	private var password:String;
	public function ServerControls() {
		password_ti.password = true;
		ipAddress_ti.restrict = "0-9.";
		ipAddress_ti.maxChars = 15;
		sftpStatus = undefined;
		monitorStatus = undefined;
		serverStatus = undefined;
	}
	public function onLoad():Void {
		password_ti.text = password;
		ipAddress_ti.text = ipAddress;
		userName_ti.text = userName;		
		var listenerObject:Object = new Object();
		listenerObject.change = function(eventObject:Object) {
	    		dataObject.setDetails(new Object({ipAddress:ipAddress_ti.text,userName:userName_ti.text,password:password_ti.text}));
		};
		password_ti.addEventListener("change", Delegate.create(this,listenerObject.change));
		ipAddress_ti.addEventListener("change", Delegate.create(this,listenerObject.change));
		userName_ti.addEventListener("change", Delegate.create(this,listenerObject.change));
		start_btn.addEventListener("click", Delegate.create(this, startServer));
		stop_btn.addEventListener("click", Delegate.create(this, stopServer));
		restart_btn.addEventListener("click", Delegate.create(this, restartServer));
		monitorConnect_btn.addEventListener("click", Delegate.create(this, monitorConnect));
		monitorDisconnect_btn.addEventListener("click", Delegate.create(this, monitorDisconnect));
		serverConnect_btn.addEventListener("click", Delegate.create(this, serverConnect));
		serverDisconnect_btn.addEventListener("click", Delegate.create(this, serverDisconnect));
		sftpConnect_btn.addEventListener("click", Delegate.create(this, sftpConnect));
		sftpDisconnect_btn.addEventListener("click", Delegate.create(this, sftpDisconnect));
		sftpConnection.attachView(this);
		monitorConnection.attachView(this);
		var my_styles = new StyleSheet();
		my_styles.setStyle("time", {fontFamily:'Arial,Helvetica,sans-serif', fontSize:'10px', color:'#000000', textDecoration:'underline'});
		my_styles.setStyle("error", {fontFamily:'Arial,Helvetica,sans-serif', fontSize:'12px', color:'#FF0000'});		
		serverOutput_ta.html = true;
		serverOutput_ta.styleSheet = my_styles;		
		serverOutput_ta.text = "";				
		serverConnection.attachView(this);
	}
	public function onUnload():Void{
		sftpConnection.detachView();
		monitorConnection.detachView();
		serverConnection.detachView();
	}
	public function notifyChange():Void{
		sftpOutput_ta.text = sftpConnection.getOutput();
		monitorOutput_ta.text = monitorConnection.getOutput();
		serverOutput_ta.text = serverConnection.getOutput();
		
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
			sftpStatus_mc._y = 116;
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
			monitorStatus_mc._y = 85;
		}
		var tempServerStatus = serverConnection.getStatus();
		if(tempServerStatus != serverStatus){
			serverStatus = tempServerStatus;
			serverStatus_mc.removeMovieClip();
			if(serverStatus){
				serverStatus_mc = this.attachMovie("on","serverStatus_mc",1);
			} else{
				serverStatus_mc = this.attachMovie("off","serverStatus_mc",1);
			}
			serverStatus_mc.setSize(32,32);
			serverStatus_mc._x = 227;
			serverStatus_mc._y = 55;
		}
	}	
	private function startServer():Void{
		monitorConnection.startServer();
	}
	private function stopServer():Void{
		monitorConnection.stopServer();
	}
	private function restartServer():Void{
		monitorConnection.restartServer();
	}
	private function monitorConnect():Void{
		monitorConnection.connect(ipAddress_ti.text,10002);
	}
	private function monitorDisconnect():Void{
		monitorConnection.disconnect();
	}
	private function serverConnect():Void{
		serverConnection.connect(ipAddress_ti.text,10001);		
	}
	private function serverDisconnect():Void{
		serverConnection.disconnect();
	}
	private function sftpConnect():Void{
		sftpConnection.connect(userName_ti.text,22,ipAddress_ti.text,password_ti.text);
	}
	private function sftpDisconnect():Void{
		sftpConnection.disconnect();		
	}
}
