package Objects.Instances {
	import Objects.*;
	import Objects.Server.Server;
	
	import flash.utils.IDataInput;
	import flash.utils.IDataOutput;
	import flash.utils.IExternalizable;
	import flash.xml.XMLNode;
	
	import mx.collections.ArrayCollection;
	import mx.core.Application;
	
	[Bindable("ServerInstance")]
	[RemoteClass(alias="elifeAdmin.objects.instances.serverInstance")]
	public class ServerInstance implements IExternalizable {
		[Bindable]
		public var ipAddress:String="";
		[Bindable]
		public var userName:String="";
		[Bindable]
		public var password:String="";
		[Bindable]
		public var clients:ArrayCollection;
		public var serverConnection:ServerConnection;
		public var wsConnection:WsConnection
		public var monitorConnection:MonitorConnection;
		public var treeNode:MyTreeNode;
		public var serverDesign:Server;
		public var id:int = 0;
		
		
		public function writeExternal(output:IDataOutput):void {
			output.writeUTF(ipAddress);
			output.writeUTF(userName);
			output.writeUTF(password);
			output.writeObject(clients);
			output.writeObject(serverConnection);
			output.writeObject(monitorConnection);
			output.writeObject(treeNode);
			output.writeObject(wsConnection);
			output.writeObject(serverDesign);
			output.writeObject(id);
		}
		
		public function readExternal(input:IDataInput):void {
			ipAddress = input.readUTF() as String;
			userName = input.readUTF() as String;
			password = input.readUTF() as String;
			clients = input.readObject() as ArrayCollection;
			serverConnection = input.readObject() as ServerConnection;
			monitorConnection = input.readObject() as MonitorConnection;
			treeNode = input.readObject() as MyTreeNode;
			wsConnection = input.readObject() as WsConnection;
			serverDesign = input.readObject() as ServerDesign;
			id = input.readInt() as int;
		}
		
		public function deleteSelf():void {
			serverConnection.disconnectServer();
			monitorConnection.disconnectMonitor();
			wsConnection.disconnect();
			treeNode.removeNode();
		} 
		public function isValid():String {
			return "server";
		}
		public function getKey():String {
			return "server";
		}
		public function getUniqueID():String {
			return this.id;
		}
		
		public function ServerInstance() {
			ipAddress = "127.0.0.1";
			userName = "";
			password = "";
			clients = new ArrayCollection();
			serverConnection = new ServerConnection();
			monitorConnection = new MonitorConnection();
			id = Application.application.formDepth++;
			wsConnection = new WsConnection(true);
		}
		public function toXML():XML {
			var serverNode:XML = new XML("<serverInstance />");
			serverNode.@ipAddress = ipAddress;
			serverNode.@userName = userName;
			serverNode.@password = password;
			
			for (var child:int = 0; child < clients.length; child++) {
				serverNode.appendChild(clients[child].toXML());
			}
			return serverNode;
		}
		public function setXML(newData:XML):void {
			clients = new ArrayCollection();
			var nodeName:String = newData.name();
			if (nodeName == "serverInstance") {
				if (newData.@ipAddress != undefined) {
					ipAddress = newData.@ipAddress;
				}
				if (newData.@userName != undefined) {
					userName = newData.@userName;
				}
				if (newData.@password != undefined) {
					password = newData.@password;
				}
				for (var child:int = 0; child < newData.children().length(); child++) {
				
					var newClient:ClientInstance = new ClientInstance();
					newClient.id = Application.application.formDepth++;
					newClient.serverParent = this;
					newClient.setXML(newData.children()[child]);
					
					clients.addItem(newClient);
				}
			} else {
				trace("ERROR, found node " + newData.name().toString() + ", expecting serverInstance");
			}
		}
		public function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			newNode.object = this;
			
			for (var client:int = 0; client < clients.length; client++) {
				newNode.appendChild(clients[client].toTree());
			}
			treeNode = newNode;
			return newNode;
		}
		public function getName():String {
			return "Server";
		}
		public function getClients():Object {
			return {clients:clients, dataObject:this};
		}
		public function getClientDesigns():ArrayCollection {
			var clientDesigns:ArrayCollection = new ArrayCollection();
			for (var client:int = 0; client < serverDesign.clients.length; client++) {
				clientDesigns.addItem({label:serverDesign.clients[client].description, data:serverDesign.clients[client].description});
			}
			return clientDesigns;
		}
		public function getClientDescriptions():ArrayCollection {
			var clientDesc:ArrayCollection = new ArrayCollection();
			for (var client:int = 0; client < clients.length; client++) {
				clientDesc.addItem({label:clients[client].description, data:clients[client].description});
			}
			return clientDesc;
		}
		
		public function getConnections():Object {
			return {serverConnection:serverConnection, monitorConnection:monitorConnection, wsConnection:wsConnection, dataObject:this, ipAddress:ipAddress, userName:userName, password:password};
		}
		public function setDetails(newData:Object):void{
			ipAddress = newData.ipAddress;
			userName = newData.userName;
			password = newData.password;
		}
		public function setData(newData:Object):void {
			//Process client changes....
			var newClients = new Array();
			for (var index in newData.clients) {
				if (newData.clients[index].id == undefined) {
					newClients.push({description:newData.clients[index].description, ipAddress:newData.clients[index].ipAddress});
				}
			}
			for (var client in clients) {
				var found = false;
				for (var index in newData.clients) {
					if (clients[client].id == newData.clients[index].id) {
						clients[client].description = newData.clients[index].description;
						clients[client].ipAddress = newData.clients[index].ipAddress;
						found = true;
					}
				}
				if (found == false) {
					clients.removeItemAt(client);
					
				}
			}
			for (var newClient in newClients) {
					var newClientObject = new Objects.Instances.ClientInstance();
					var newClientXML = new XMLNode(1,"clientInstance");
					newClientXML.attributes.description = newClients[newClient].description;
					newClientXML.attributes.ipAddress = newClients[newClient].ipAddress;
					newClientObject.setXML(newClientXML);
					newClientObject.id = Application.application.formDepth++;
					newClientObject.serverParent = this;				
					clients.addItem(newClientObject);
					treeNode.appendChild(newClientObject.toTree());
			}
			
		}
	}
}