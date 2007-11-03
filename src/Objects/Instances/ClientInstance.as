package Objects.Instances {
	import Forms.Control.Clients_frm;
	
	import Objects.*;
	
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	
	import mx.core.Application;
	
	[Bindable("ClientInstance")]
	[RemoteClass(alias="elifeAdmin.objects.instances.clientInstance")]
	public class ClientInstance {
		[Bindable]
		public var ipAddress:String="";
		public var userName:String="";
		public var password:String="";
		[Bindable]
		public var description:String="";
		[Bindable]
		public var designName:String="";
				
		[Bindable]
		public var monitorConnection:MonitorConnection;
		public var treeNode:MyTreeNode;
		public var serverParent:ServerInstance;
		public var clientDesign:Object;
		
		public var id:int = 0;
		
		public function writeExternal(output:IDataOutput):void {
			output.writeUTF(ipAddress);
			output.writeUTF(userName);
			output.writeUTF(password);
			output.writeUTF(description);
			output.writeUTF(designName);
			output.writeObject(monitorConnection);
			output.writeObject(treeNode);
			output.writeObject(sftpConnection);
			output.writeObject(serverParent);
			output.writeObject(clientDesign);
			output.writeInt(id);
		}
		
		public function readExternal(input:IDataInput):void {
			ipAddress = input.readUTF() as String;
			userName = input.readUTF() as String;
			password = input.readUTF() as String;
			description = input.readUTF() as String;
			designName = input.readUTF() as String;
			monitorConnection = input.readObject() as MonitorConnection;
			treeNode = input.readObject() as MyTreeNode;
			wsConnection = input.readObject() as WsConnection;
			serverParent = input.readObject() as ServerInstance;
			clientDesign = input.readObject() as Object;
			id = input.readInt() as Int;
		}
		
		
		public function deleteSelf():void {
			//monitorConnection.disconnectMonitor();
			//wsConnection.disconnect();
			treeNode.removeNode();
		}
		public function ClientInstance() {
			ipAddress = "127.0.0.1";
			userName = "";
			password = "";
			designName = "";
			monitorConnection = new MonitorConnection();
			id = Application.application.formDepth++;
		}
		public function toXML():XML {
			var clientNode:XML = new XML("<clientInstance />");
			clientNode.@ipAddress = ipAddress;
			clientNode.@userName = userName;
			clientNode.@password = password;
			clientNode.@description = description;
			clientNode.@designName = designName;
			return clientNode;
		}
		public function setXML(newData:XML):void {
			if (newData.name() == "clientInstance") {
					ipAddress = newData..@ipAddress;
					userName = newData..@userName;
					password = newData..@password;
					description = newData..@description;
					designName = newData..@designName
					changeDesign(designName);			
			} else {
				trace("ERROR, found node " + newData.name() + ", expecting clientInstance");
			}
		}
		public function isValid():String {
			return "client";
		}
		public function getKey():String {
			return "client";
		}
		public function getUniqueID():String {
			return this.id;
		}
		
		public function getClassForm():Class {
			var className:Class = Forms.Control.Clients_frm;
			return className;		
		}
		public function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			newNode.object = this;
			
			treeNode = newNode;
			return newNode;
		}
		public function getName():String {
			return description;
		}
		public function getConnections():Object {
			return {clientDesign:clientDesign.description, monitorConnection:monitorConnection, wsConnection:wsConnection, dataObject:this, ipAddress:ipAddress, userName:userName, password:password};
		}
		public function setDetails(newData:Object):void{
			ipAddress = newData.ipAddress;
			userName = newData.userName;
			password = newData.password;
			changeDesign(newData.clientDesign);
		}
		
		private function changeDesign(desName:String):void{
			for(var client in serverParent.serverDesign.clients){
				if(desName == serverParent.serverDesign.clients[client].description){
					clientDesign = serverParent.serverDesign.clients[client];
					return;
				}
			}
			clientDesign = undefined;
			return;
		}
	}
}