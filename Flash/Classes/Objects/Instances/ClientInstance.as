class Objects.Instances.ClientInstance {
	private var ipAddress:String;
	private var userName:String;
	private var password:String;
	private var description:String;
	private var clientConnection:Object;
	private var monitorConnection:Object;
	private var treeNode:XMLNode;
	private var sftpConnection:Object;
	private var serverParent:Object;
	private var clientDesign:Object;
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
		monitorConnection = new Objects.MonitorConnection();
		sftpConnection = new Objects.SFTPConnection(false);
	}
	public function toXML():XMLNode {
		var clientNode = new XMLNode(1, "clientInstance");
		clientNode.attributes.ipAddress = ipAddress;
		clientNode.attributes.userName = userName;
		clientNode.attributes.password = password;
		clientNode.attributes.description = description;
		clientNode.attributes.designName = clientDesign.description;
		return clientNode;
	}
	public function setXML(newData:XMLNode):Void {
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
			if (newData.attributes.description != undefined) {
				description = newData.attributes.description;
			}
			if (newData.attributes.designName != undefined) {
				changeDesign(newData.attributes.designName);
			}			
		} else {
			trace("ERROR, found node " + newData.nodeName + ", expecting clientInstance");
		}
	}
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "clientInstance");
		newNode.object = this;
		treeNode = newNode;
		return newNode;
	}
	public function getName():String {
		return description;
	}
	public function getConnections():Object {
		return {clientDesign:clientDesign.description, monitorConnection:monitorConnection, sftpConnection:sftpConnection, dataObject:this, ipAddress:ipAddress, userName:userName, password:password};
	}
	public function setDetails(newData:Object):Void{
		ipAddress = newData.ipAddress;
		userName = newData.userName;
		password = newData.password;
		changeDesign(newData.clientDesign);
	}
	private function changeDesign(designName:String):Void{
		for(var client in serverParent.serverDesign.clients){
			if(designName == serverParent.serverDesign.clients[client].description){
				clientDesign = serverParent.serverDesign.clients[client];
				return;
			}
		}
		clientDesign = undefined;
		return;
	}
}
