class Objects.Connections.ServerInstance{
	private var __ipAddress:String;
	private var __serverPort:Number;
	private var __monitorPort:Number;
	private var clients:Array;
	private var serverConnection:Object;
	private var serverName:String;
	private var treeNode:XMLNode;
	public function deleteSelf(){
		serverConnection.disconnectServer();
		serverConnection.disconnectMonitor();		
		treeNode.removeNode();
	}				
	public function get ipAddress():String{
		return __ipAddress;
	}
	public function set ipAddress(inIpAddress:String){
		__ipAddress = inIpAddress;
		serverConnection.ipAddress = __ipAddress;
	}
	public function get serverPort():Number{
		return __serverPort;
	}
	public function set serverPort(inServerPort:Number){
		__serverPort = inServerPort;
		serverConnection.serverPort = __serverPort;
	}
	public function get monitorPort():Number{
		return __monitorPort;
	}
	public function set monitorPort(inMonitorPort:Number){
		__monitorPort = inMonitorPort;
		serverConnection.monitorPort = __monitorPort;
	}	
	public function ServerInstance(){
		__ipAddress = "172.16.3.101";
		__serverPort = 10001;
		__monitorPort = 10002;
		clients = new Array();
		serverName = "";
		serverConnection = new Objects.ServerConnection();
	}
	public function toXML():XMLNode {
		var serverNode = new XMLNode(1, "server");
		serverNode.attributes.serverName = serverName;
		serverNode.attributes.ipAddress = __ipAddress;
		serverNode.attributes.serverPort = __serverPort;
		serverNode.attributes.monitorPort = __monitorPort;
		for (var client in clients) {
			serverNode.appendChild(clients[client].toXML());
		}
		return serverNode;
	}
	public function setXML(newData:XMLNode):Void {
		clients = new Array();
		if (newData.nodeName == "server") {
			if(newData.attributes.serverName != undefined){
				serverName = newData.attributes.serverName;
			}
			if(newData.attributes.ipAddress != undefined){
				__ipAddress = newData.attributes.ipAddress;
			}
			if(newData.attributes.serverPort != undefined){
				__serverPort = newData.attributes.serverPort;
			}
			if(newData.attributes.monitorPort != undefined){
				__monitorPort = newData.attributes.monitorPort;
			}			
			for (var child in newData.childNodes) {
				var newClient = new Objects.Connections.Client();
				newClient.setXML(newData.childNodes[child]);
				newClient.id = _global.formDepth++;
				clients.push(newClient);
			}
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting CONFIG");
		}
	}	
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Server");
		newNode.object = this;
		for (var client in clients) {
			newNode.appendChild(clients[client].toTree());
		}
		treeNode = newNode;
		return newNode;
	}
	public function getName():String {
		return serverName;
	}
	public function getClients():Object {
		return {clients:clients,dataObject:this};
	}
	public function getConnection():Object {
		return {serverConnection:serverConnection,dataObject:this};
	}
	public function setData(newData:Object) {
		_global.left_tree.setIsOpen(treeNode, false);		
		//Process client changes....
		var newClients = new Array();
		for (var index in newData.clients) {
			if (newData.clients[index].id == undefined) {
				newClients.push({description:newData.clients[index].description, client_type:newData.clients[index].client_type, ipAddress:newData.clients[index].ipAddress});
			}
		}
		for (var client in clients) {
			var found = false;
			for (var index in newData.clients) {
				if (clients[client].id == newData.clients[index].id) {
					clients[client].client_type = newData.clients[index].client_type;
					clients[client].description = newData.clients[index].description;
					clients[client].ipAddress = newData.clients[index].ipAddress;						
					found = true;
				} else{
					newClients.push({description:newData.clients[index].description, client_type:newData.clients[index].client_type});
				}
			}
			if (found == false) {
				clients[client].deleteSelf();
				clients.splice(parseInt(client), 1);
			}
		}
		for (var newClient in newClients) {
			
		}
		_global.left_tree.setIsOpen(treeNode, true);
	}
}
