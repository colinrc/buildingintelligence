﻿class Objects.Instances.ServerInstance {
	private var ipAddress:String;
	private var userName:String;
	private var password:String;
	private var clients:Array;
	private var serverConnection:Object;
	private var monitorConnection:Object;
	private var treeNode:XMLNode;
	private var sftpConnection:Object;
	public function deleteSelf() {
		serverConnection.disconnectServer();
		serverConnection.disconnectMonitor();
		sftpConnection.disconnect();
		treeNode.removeNode();
	}
	public function ServerInstance() {
		ipAddress = "127.0.0.1";
		userName = "";
		password = "";
		clients = new Array();
		serverConnection = new Objects.ServerConnection();
		monitorConnection = new Objects.MonitorConnection();
		sftpConnection = new Objects.SFTPConnection(true);
	}
	public function toXML():XMLNode {
		var serverNode = new XMLNode(1, "serverInstance");
		serverNode.attributes.ipAddress = ipAddress;
		serverNode.attributes.userName = userName;
		serverNode.attributes.password = password;
		for (var client in clients) {
			serverNode.appendChild(clients[client].toXML());
		}
		return serverNode;
	}
	public function setXML(newData:XMLNode):Void {
		clients = new Array();
		if (newData.nodeName == "serverInstance") {
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
			trace("ERROR, found node " + newData.nodeName + ", expecting serverInstance");
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
		return "Server";
	}
	public function getClients():Object {
		return {clients:clients, dataObject:this};
	}
	public function getConnections():Object {
		return {serverConnection:serverConnection, monitorConnection:monitorConnection, sftpConnection:sftpConnection, dataObject:this, ipAddress:ipAddress, userName:userName, password:password};
	}
	public function setDetails(newData:Object):Void{
		ipAddress = newData.ipAddress;
		userName = newData.userName;
		password = newData.password;
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
				} else {
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
