package Objects.Instances {
	import flash.xml.XMLNode;
	import Objects.*;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("ClientInstance")]
	[RemoteClass(alias="elifeAdmin.objects.instances.clientInstance")]
	public class ClientInstance {
		private var ipAddress:String="";
		private var userName:String="";
		private var password:String="";
		private var description:String="";
		private var clientConnection:Object;
		private var monitorConnection:Object;
		private var treeNode:MyTreeNode;
		private var sftpConnection:Object;
		public var serverParent:Object;
		public var clientDesign:Object;
		public var name:String="";
		public var id:int;
		
		public function writeExternal(output:IDataOutput):void {
			output.writeUTF(ipAddress);
			output.writeUTF(userName);
			output.writeUTF(password);
			output.writeUTF(description);
			output.writeObject(clientConnection);
			output.writeObject(monitorConnection);
			output.writeObject(treeNode);
			output.writeObject(sftpConnection);
			output.writeObject(serverParent);
			output.writeObject(clientDesign);
			output.writeUTF(name);
			output.writeInt(id);
		}
		
		public function readExternal(input:IDataInput):void {
			ipAddress = input.readUTF() as String;
			userName = input.readUTF() as String;
			password = input.readUTF() as String;
			description = input.readUTF() as String;
			clientConnection = input.readObject() as Object;
			monitorConnection = input.readObject() as Object;
			treeNode = input.readObject() as MyTreeNode;
			sftpConnection = input.readObject() as Object;
			serverParent = input.readObject() as Object;
			clientDesign = input.readObject() as Object;
			name = input.readUTF() as String;
			id = input.readInt() as Int;
		}
		
		
		public function deleteSelf():void {
			//monitorConnection.disconnectMonitor();
			//sftpConnection.disconnect();
			treeNode.removeNode();
		}
		public function ClientInstance() {
			ipAddress = "127.0.0.1";
			userName = "";
			password = "";
			monitorConnection = new MonitorConnection();
			sftpConnection = new SFTPConnection(false);
		}
		public function toXML():XML {
			var clientNode:XML = new XML("<clientInstance />");
			clientNode.@ipAddress = ipAddress;
			clientNode.@userName = userName;
			clientNode.@password = password;
			clientNode.@description = description;
			//clientNode.@designName = clientDesign.description;
			return clientNode;
		}
		public function setXML(newData:XML):void {
			if (newData.name() == "clientInstance") {
					ipAddress = newData..@ipAddress;
					userName = newData..@userName;
					password = newData..@password;
					description = newData..@description;
					changeDesign(newData..@designName);			
			} else {
				trace("ERROR, found node " + newData.name() + ", expecting clientInstance");
			}
		}
		public function isValid():String {
			return "ok";
		}
		public function getKey():String {
			return "";
		}
		public function getUniqueID():String {
			return "-2";
		}
		public function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			
			treeNode = newNode;
			return newNode;
		}
		public function getName():String {
			return description;
		}
		public function getConnections():Object {
			return {clientDesign:clientDesign.description, monitorConnection:monitorConnection, sftpConnection:sftpConnection, dataObject:this, ipAddress:ipAddress, userName:userName, password:password};
		}
		public function setDetails(newData:Object):void{
			ipAddress = newData.ipAddress;
			userName = newData.userName;
			password = newData.password;
			changeDesign(newData.clientDesign);
		}
		
		//TODO: problem with last method here.
		private function changeDesign(designName:String):void{
/*			serverParent.
			for(var client:Object in serverParent.serverDesign.clients){
				if(designName == serverParent.serverDesign.clients[client].description){
					clientDesign = serverParent.serverDesign.clients[client];
					return;
				}
			} */
			clientDesign = undefined;
			return;
		}
	}
}