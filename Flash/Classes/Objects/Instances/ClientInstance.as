class Objects.Instances.ClientInstance {
	private var ipAddress:String;
	private var userName:String;
	private var password:String;
	private var clients:Array;
	private var clientConnection:Object;
	private var monitorConnection:Object;
	private var treeNode:XMLNode;
	private var sftpConnection:Object;
	private var name:String;
	public function deleteSelf() {
		monitorConnection.disconnectMonitor();
		sftpConnection.disconnect();
		treeNode.removeNode();
	}
	public function ClientInstance() {
		ipAddress = "127.0.0.1";
		userName = "";
		password = "";
		clients = new Array();
		monitorConnection = new Objects.MonitorConnection();
		sftpConnection = new Objects.SFTPConnection(true);
	}
	public function toXML():XMLNode {
		var clientNode = new XMLNode(1, "clientInstance");
		clientNode.attributes.ipAddress = ipAddress;
		clientNode.attributes.userName = userName;
		clientNode.attributes.password = password;
		for (var client in clients) {
			clientNode.appendChild(clients[client].toXML());
		}
		return clientNode;
	}
	public function setXML(newData:XMLNode):Void {
		clients = new Array();
		if (newData.nodeName == "clientInstance") {
			if (newData.attributes.ipAddress != undefined) {
				ipAddress = newData.attributes.ipAddress;
			}
			if (newData.attributes.userName != undefined) {
				userName = newData.attributes.userName;
			}
			if (newData.attributes.password != undefined) {
				password = newData.attributes.password;
			}
			for (var child in newData.childNodes) {
				var newClient = new Objects.Instances.ClientInstance();
				newClient.setXML(newData.childNodes[child]);
				newClient.id = _global.formDepth++;
				clients.push(newClient);
			}
		} else {
			trace("ERROR, found node " + newData.nodeName + ", expecting clientInstance");
		}
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Client");
		newNode.object = this;
		for (var client in clients) {
			newNode.appendChild(clients[client].toTree());
		}
		treeNode = newNode;
		return newNode;
	}
	public function getName():String {
		return name;
	}
	public function getConnections():Object {
		return {monitorConnection:monitorConnection, sftpConnection:sftpConnection, dataObject:this, ipAddress:ipAddress, userName:userName, password:password};
	}
	public function setDetails(newData:Object):Void{
		ipAddress = newData.ipAddress;
		userName = newData.userName;
		password = newData.password;
	}
}
