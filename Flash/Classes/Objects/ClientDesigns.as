class Objects.ClientDesigns{
	/*Array containing project client designs*/
	private var clients:Array;
	private var treeNode:XMLNode;
	/*Constructor*/
	public function ClientDesigns(){
		clients = new Array();
		/**Append default client device here*/		
		var new_client = new Objects.Client.Client();
		new_client.setXML(_global.default_client_xml.firstChild);
		//mdm.Dialogs.prompt(_global.default_client_xml);
		new_client.description = "Default Client";
		new_client.id = _global.formDepth++;
		clients.push(new_client);		
	}
	/*Returns the object in XML form*/
	public function toXML():XMLNode {
		var clientsNode = new XMLNode(1, "clientDesigns");
		/*Append all client objects as children*/
		for (var client in clients) {
			clientsNode.appendChild(clients[client].toXML());
		}
		return clientsNode;
	}
	/*Returns the linkage of the form associate with this object*/
	public function getForm():String {
		return "forms.project.clientDesigns";
	}
	/*Set Object attributes from XML*/
	public function setXML(newData:XMLNode):Void {
		clients = new Array();
		if (newData.nodeName == "clientDesigns") {
			for (var child in newData.childNodes) {
				var newClient = new Objects.Client.Client();
				newClient.setXML(newData.childNodes[child]);
				newClient.id = _global.formDepth++;
				clients.push(newClient);
			}
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting clientDesigns");
		}
	}
	/* Return Project Tree Structure*/
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Clients");
		newNode.object = this;
		for (var client in clients) {
			newNode.appendChild(clients[client].toTree());
		}
		/*Retain a reference of its tree node*/
		treeNode = newNode;
		return newNode;
	}
	/* Return Name of Object*/
	public function getName():String {
		return "Client Designs";
	}
	/*Return attributes of object*/
	public function getData():Object {
		return {clients:clients,dataObject:this};
	}
	/*Set object attributes from object*/
	public function setData(newData:Object) {
		/*Close the left node, if nodes are added while node is open graphical glitches occur*/
		_global.left_tree.setIsOpen(treeNode, false);		
		//Process client list changes....
		/*Create an array to store new clients*/
		var newClients = new Array();
		/*For each client in incoming object*/
		for (var index in newData.clients) {
			/*If a client object in incoming object does not have unique id*/
			if (newData.clients[index].id == undefined) {
				/*Assign object new unique id*/
				newData.clients[index].id = _global.formDepth++;
				/*Append new client to new client list*/
				newClients.push({description:newData.clients[index].description,id:newData.clients[index].id});
			}
		}
		/* Find all clients that have been removed */
		for (var client in clients) {
			/*Prime flag to false*/
			var found = false;
			/*For each client in incoming object*/
			for (var index in newData.clients) {
				/*If client id exists*/
				if (clients[client].id == newData.clients[index].id) {
					/*Update description*/
					clients[client].description = newData.clients[index].description;
					found = true;
				}
			}
			/*If existing client is not a member of incoming object*/
			if (found == false) {
				/*Delete client*/
				clients[client].deleteSelf();
				/*Remove reference*/
				clients.splice(parseInt(client), 1);
			}
		}
		for (var newClient in newClients) {
			/*Add new Clients*/
			/*Reference Vanilla Object*/
			var new_client = new Objects.Client.Client();
			new_client.setXML(_global.default_client_xml);
			new_client.description = newClients[newClient].description;
			new_client.id = newClients[newClient].id;
			treeNode.appendChild(new_client.toTree());
			clients.push(new_client);
		}
		_global.left_tree.setIsOpen(treeNode, true);
	}
}
