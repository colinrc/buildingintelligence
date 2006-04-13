class Objects.Instances.ClientInstance{
	private var __ipAddress:String;
	private var __monitorPort:Number;
	private var clientType:String;
	private var monitorConnection:Object;
	private var clientName:String;
	private var treeNode:XMLNode;
	public function deleteSelf(){
		monitorConnection.disconnect();
		treeNode.removeNode();
	}				
	public function get ipAddress():String{
		return __ipAddress;
	}
	public function set ipAddress(inIpAddress:String){
		__ipAddress = inIpAddress;
		monitorConnection.ipAddress = __ipAddress;
	}
	public function get monitorPort():Number{
		return __monitorPort;
	}
	public function set monitorPort(inMonitorPort:Number){
		__monitorPort = inMonitorPort;
		monitorConnection.monitorPort = __monitorPort;
	}	
	public function ClientInstance(){
		__ipAddress = "172.16.3.101";
		__monitorPort = 10002;
		clientName = "";
		monitorConnection = new Objects.MonitorConnection();
	}
	public function toXML():XMLNode {
		var clientNode = new XMLNode(1, "client");
		clientNode.attributes.clientName = clientName;
		clientNode.attributes.ipAddress = __ipAddress;
		clientNode.attributes.monitorPort = __monitorPort;
		return clientNode;
	}
	public function setXML(newData:XMLNode):Void {
		if (newData.nodeName == "client") {
			if(newData.attributes.clientName != undefined){
				clientName = newData.attributes.clientName;
			}
			if(newData.attributes.ipAddress != undefined){
				__ipAddress = newData.attributes.ipAddress;
			}
			if(newData.attributes.monitorPort != undefined){
				__monitorPort = newData.attributes.monitorPort;
			}			
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting client");
		}
	}	
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Client");
		newNode.object = this;
		treeNode = newNode;
		return newNode;
	}
	public function getName():String {
		return clientName;
	}
	public function getConnection():Object {
		return {monitorConnection:monitorConnection,dataObject:this};
	}
	public function setData(newData:Object) {
		/*process client changes*/
	}
}
