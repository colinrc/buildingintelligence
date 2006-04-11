import mx.controls.*;
import mx.utils.Delegate;
class Forms.Control.Publish extends Forms.BaseForm {
	private var dataObject:Object;
	private var myActiveX:Object;
	private var output_ta:TextArea;
	private var user:String;
	private var port:Number;
	private var hostname:String;
	private var password:String;
	private var localPath:String;
	private var remotePath:String;
	private var isServer:Boolean = false;
	private var localDirectory_cmb:ComboBox;
	private var remoteDirectory_cmb:ComboBox;
	private var lastCode:String = "0";
	private var intervalId:Number;
	private var duration:Number = 100;
	private var port_ti:TextInput;
	private var address_ti:TextInput;
	private var userName_ti:TextInput;
	private var password_ti:TextInput;
	private var connect_btn:Button;
	private var disconnect_btn:Button;
	private var appPath:String;
	
	public function checkStatus():Void {
		var tempCode;
		tempCode = myActiveX.getProperty("State");
		if(tempCode != lastCode){
			lastCode = tempCode;
			appendOutput(connectionStatus(tempCode));
			if(lastCode == "0"){
				right_li.removeAll();
				remoteDirectory_cmb.selectedIndex = 0;							
			}
		}
	}
	
	public function Publish() {
		appPath = mdm.Application.path.substring(0,mdm.Application.path.length-1)
		intervalId = setInterval(this, "checkStatus", duration);
	}
	public function onLoad():Void {
		output_ta.editable = false;
		password_ti.password = true;
		port_ti.restrict = "0-9";
		port_ti.maxChars = 5;
		address_ti.restrict = "0-9.";
		address_ti.maxChars = 15;
		myActiveX = new mdm.ActiveX(0, 0, 0, 0, "WeOnlyDo.wodSFTP.1");		
		myActiveX.setProperty("LocalPath", "string", localPath);
		myActiveX.setProperty("RemotePath", "string", remotePath);		
		user = "test1";
		port = 22;
		hostname = "172.16.3.52";
		password = "password";
		userName_ti.text = user;
		port_ti.text = port.toString();
		address_ti.text = hostname;
		password_ti.text = password;
		/*getSelected_btn.addEventListener("click", Delegate.create(this, getItem));
		putSelected_btn.addEventListener("click", Delegate.create(this, putItem));*/
		connect_btn.addEventListener("click", Delegate.create(this, connect));
		disconnect_btn.addEventListener("click", Delegate.create(this, disconnect));
	}
	public function connect():Void{
		myActiveX.setProperty("Hostname", "string", address_ti.text);
		myActiveX.setProperty("Port", "integer", parseInt(port_ti.text));
		myActiveX.setProperty("Blocking", "integer", 1);
		myActiveX.setProperty("Login", "string", userName_ti.text);
		myActiveX.setProperty("Password", "string", password_ti.text);
		myActiveX.runMethod("Connect", 0);
		var lastError = myActiveX.getProperty("LastError");
		if (lastError != "0") {
			appendOutput(processError(lastError));
		} else {
			appendOutput("connected as: " + user + ", at:" + hostname);
		}		
	}
	public function disconnect():Void{
		myActiveX.runMethod("Disconnect", 0);
		var lastError = myActiveX.getProperty("LastError");		
		if (lastError != "0") {
			appendOutput(processError(lastError));
		}		
	}
	public function getItem(file:String):Void {
		if(right_li.selectedIndex != undefined){
			if(lastCode != "0"){			
			myActiveX.addMethodParam(1, "string", localPath + right_li.selectedItem.label);
			myActiveX.addMethodParam(2, "string", remotePath + right_li.selectedItem.label);
			myActiveX.runMethod("GetFile", 2);
			var lastError = myActiveX.getProperty("LastError");
			if (lastError != "0") {
				appendOutput(processError(lastError));
			} else {
				appendOutput("File Transfer Successful!");
				appendOutput("Downloaded file: " + right_li.selectedItem.label + ", from: " + remotePath + right_li.selectedItem.label);
			}
			} else{
				appendOutput("Error: No Connection Present");
			}			
		} else{
			appendOutput("Error: Please Select File to Download!");
		}
	}
	public function putItem():Void {
		if(left_li.selectedIndex != undefined){
			if(lastCode != "0"){
				myActiveX.addMethodParam(1, "string", localPath + left_li.selectedItem.label);
				myActiveX.addMethodParam(2, "string", remotePath + left_li.selectedItem.label);
				myActiveX.runMethod("PutFile", 2);
				var lastError = myActiveX.getProperty("LastError");
				if (lastError != "0") {
					appendOutput(processError(lastError));
				} else {
					appendOutput("File Transfer Successful!");
					appendOutput("Uploaded file: " + left_li.selectedItem.label + ", from: " + localPath + left_li.selectedItem.label);
				}
			} else{
				appendOutput("Error: No Connection Present");
			}
		} else{
			appendOutput("Error: Please Select File to Upload!");
		}
	}
	public function appendOutput(inString:String):Void {
		output_ta.text += inString + "\n";
	}
	public function connectionStatus(inCode:String):String {
		switch (inCode) {
		case "0" :
			return "Disconnected from server.";
			break;
		case "1" :
			return "Connecting to server.";
			break;
		case "2" :
			return "Sending authentication data.";
			break;
		case "3" :
			return "Connected to server - idle.";
			break;
		case "4" :
			return "Receiving data from server.";
			break;
		case "5" :
			return "Sending data to server.";
			break;
		case "6" :
			return "Executing command on server.";
			break;
		}
	}
	public function processError(inCode:String):String {
		switch (inCode) {
		case "10004" :
			return "Interrupted function call. A blocking operation was interrupted by a call to WSACancelBlockingCall.";
			break;
		case "10009" :
			return "Generic error for invalid format, bad format.";
			break;
		case "10013" :
			return 'Permission denied. An attempt was made to access a socket in a way forbidden by its access permissions. An example is using a broadcast address for "sendto" without broadcast permission being set using setsockopt (SO_BROADCAST).';
			break;
		case "10014" :
			return "Bad address. The system detected an invalid pointer address in attempting to use a pointer argument of a call. This error occurs if an program passes an invalid pointer value, or if the length of the buffer is too small. For instance, if the length of an argument which is a struct sockaddr is smaller than sizeof(struct sockaddr).";
			break;
		case "10022" :
			return "Invalid argument. Some invalid argument was supplied (for example, specifying an invalid level to the setsockopt function). In some instances, it also refers to the current state of the socket - for instance, calling accept on a socket that is not listening.";
			break;
		case "10024" :
			return "Too many open files. Too many open sockets. Each implementation may have a maximum number of socket handles available, either globally, per process or per thread.";
			break;
		case "10025" :
			return "The IP address provided is not valid or the host specified by the IP does not exist.";
			break;
		case "10038" :
			return "Socket operation on a non-socket. An operation was attempted on something that is not a socket. Either the socket handle parameter did not reference a valid socket, or for select, a member of an fd_set was not valid.";
			break;
		case "10048" :
			return "Address already in use. Only one usage of each socket address (protocol/IP address/port) is normally permitted. This error occurs if a program attempts to bind a socket to an IP address/port that has already been used for an existing socket, or a socket that wasn't closed properly, or one that is still in the process of closing. For server programs that need to bind multiple sockets to the same port number, consider using setsockopt(SO_REUSEADDR). Client programs usually need not call bind at all - connect will choose an unused port automatically.";
			break;
		case "10049" :
			return "Cannot assign requested address. The requested address is not valid in its context. Normally results from an attempt to bind to an address that is not valid for the local machine, or connect/sendto an address or port that is not valid for a remote machine (e.g. port 0).";
			break;
		case "10050" :
			return "Network is down. A socket operation encountered a dead network. This could indicate a serious failure of the network system (the protocol stack that the WinSock DLL runs over), the network interface, or the local network itself.";
			break;
		case "10051" :
			return "Network is unreachable. A socket operation was attempted to an unreachable network. This usually means the local software knows no route to reach the remote host.";
			break;
		case "10052" :
			return "Network dropped connection on reset. The host you were connected to crashed and rebooted. May also be returned by setsockopt if an attempt is made to set SO_KEEPALIVE on a connection that has already failed.";
			break;
		case "10053" :
			return "Software caused connection abort. An established connection was aborted by the software in your host machine, possibly due to a data transmission timeout or protocol error.";
			break;
		case "10054" :
			return 'Connection reset by peer. An existing connection was forcibly closed by the remote host. This normally results if the peer program on the remote host is suddenly stopped, the host is rebooted, or the remote host used a "hard close" (see setsockopt for more information on the SO_LINGER option on the remote socket.)';
			break;
		case "10057" :
			return "Socket is not connected. A request to send or receive data was disallowed because the socket is not connected and (when sending on a datagram socket using sendto) no address was supplied. Any other type of operation might also return this error - for example, setsockopt setting SO_KEEPALIVE if the connection has been reset.";
			break;
		case "10058" :
			return "Cannot send after socket shutdown. A request to send or receive data was disallowed because the socket had already been shut down in that direction with a previous shutdown call. By calling shutdown a partial close of a socket is requested, which is a signal that sending or receiving or both has been discontinued.";
			break;
		case "10060" :
			return "Connection timed out. A connection attempt failed because the connected party did not properly respond after a period of time, or established connection failed because connected host has failed to respond.";
			break;
		case "10061" :
			return "Connection refused. No connection could be made because the target machine actively refused it. This usually results from trying to connect to a service that is inactive on the foreign host - i.e. one with no server program running.";
			break;
		case "10063" :
			return "Specified host name is too long.";
			break;
		case "10064" :
			return "Host is down. A socket operation failed because the destination host was down. A socket operation encountered a dead host. Networking activity on the local host has not been initiated. These conditions are more likely to be indicated by the error WSAETIMEDOUT.";
			break;
		case "10065" :
			return "No route to host. A socket operation was attempted to an unreachable host. See WSAENETUNREACH";
			break;
		case "10091" :
			return "Network subsystem is unavailable. This error is returned by WSAStartup if the Windows Sockets implementation cannot function at this time because the underlying system it uses to provide network services is currently unavailable.";
			break;
		case "10093" :
			return "Successful WSAStartup not yet performed. Either the program has not called WSAStartup or WSAStartup failed. The program may be accessing a socket which the current active task does not own (i.e. trying to share a socket between tasks), or WSACleanup has been called too many times.";
			break;
		case "10094" :
			return "Graceful shutdown in progress. Returned by recv, WSARecv to indicate the remote party has initiated a graceful shutdown sequence.";
			break;
		case "11001" :
			return "Host not found. No such host is known. The name is not an official hostname or alias, or it cannot be found in the database(s) being queried. This error may also be returned for protocol and service queries, and means the specified name could not be found in the relevant database.";
			break;
		case "11002" :
			return "Authoritative host not found. This is usually a temporary error during hostname resolution and means that the local server did not receive a response from an authoritative server. A retry at some time later may be successful.";
			break;
		case "30001" :
			return "Cannot connect at this time. Use Disconnect first.";
			break;
		case "30002" :
			return "Please set login/password combination.";
			break;
		case "30003" :
			return "Invalid Hostname property value.";
			break;
		case "30004" :
			return "Cannot change Hostname at this time. Use Disconnect first.";
			break;
		case "30005" :
			return "Cannot change Port at this time. Use Disconnect first.";
			break;
		case "30006" :
			return "Cannot [send/receive/make dir/remove dir/rename/get real path/delete file/list dir] at this time, not connected.";
			break;
		case "30007" :
			return "Cannot [send/receive/make dir/remove dir/rename/get real path/delete file/list dir] at this time, component busy.";
			break;
		case "30008" :
			return "Cannot use single DES with SSH2 protocol.";
			break;
		case "30009" :
			return "Invalid local file name or path.";
			break;
		case "30010" :
			return "Could not resolve given Hostname.";
			break;
		case "30011" :
			return "Invalid data received from remote server. Protocol error.";
			break;
		case "30012" :
			return "Protocol version mismatch error.";
			break;
		case "30013" :
			return "Bad server public Diffie Hellman key value.";
			break;
		case "30014" :
			return "Server signature does not match.";
			break;
		case "30015" :
			return "Invalid username or password reported by server.";
			break;
		case "30016" :
			return "SFTP subsystem on server unavailable.";
			break;
		case "30017" :
			return "Server returned invalid response to [FXP_ATTRS/FXP_OPEN/FXP_READ/FXP_REALPATH/FXP_READDIR/FXP_LSTAT].";
			break;
		case "30018" :
			return myActiveX.getProperty("ServerErrorText");
			break;
		case "30019" :
			return "Given path on the server is a directory.";
			break;
		case "30020" :
			return "Server cannot write to a given path. ";
			break;
		case "30021" :
			return "LocalPath should specify a file, and such file does not exist.";
			break;
		case "30022" :
			return "Error occurred trying to open local file.";
			break;
		case "30023" :
			return "Error occurred trying to read local file.";
			break;
		case "30024" :
			return "Error occurred trying to write to local file.";
			break;
		case "30025" :
			return "Server replied with invalid response ID.";
			break;
		case "30026" :
			return "Please set Hostname property.";
			break;
		case "30027" :
			return "Component was busy and got disconnected.";
			break;
		case "30028" :
			return "Invalid identification received from server. This is most probably not SSH server.";
			break;
		case "30029" :
			return "Protocol error. Could not open channel on the server.";
			break;
		case "30030" :
			return "No more authentication methods available. Giving up...";
			break;
		case "30031" :
			return "Failed to set attributes. Invalid response from the server.";
			break;
		case "30032" :
			return "Failed to create temporary file.";
			break;
		case "30033" :
			return "Aborted by user.";
			break;
		case "30034" :
			return "Private key type could not be determined.";
			break;
		case "30035" :
			return "Cannot change buffer size at this time. Use Disconnect first.";
			break;
		case "30036" :
			return "Invalid buffer size. Use at least 8kb buffers.";
			break;
		case "30037" :
			return "Current method was aborted.";
			break;
		case "30038" :
			return "Cannot set compression at this time. Use Disconnect first.";
			break;
		case "30039" :
			return "Compression level should be between 0 and 9.";
			break;
		case "30040" :
			return "Proxy server has closed the connection.";
			break;
		case "30041" :
			return "Proxy server rejected supplied login credentials.";
			break;
		case "30043" :
			return "Cannot use Append method when Resume property is set to True.";
			break;
		case "30044" :
			return "Size cannot be 0.";
			break;
		case "39999" :
			return "License key missing. You can not use this component in design environment.";
			break;
		}
	}
}
