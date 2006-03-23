class Objects.ServerDesigns{
	/*Array containing project server designs*/
	private var servers:Array;
	private var treeNode:XMLNode;
	/*Constructor*/
	public function ServerDesigns(){
		servers = new Array();
		/**Append default server device here*/		
		var new_server = new Objects.Server.Server();
		new_server.setXML(_global.default_server_xml.firstChild);
		new_server.description = "Default Server";
		new_server.id = _global.formDepth++;
		servers.push(new_server);		
	}
	/*Returns the object in XML form*/
	public function toXML():XMLNode {
		var serversNode = new XMLNode(1, "serverDesigns");
		/*Append all server objects as children*/
		for (var server in servers) {
			serversNode.appendChild(servers[server].toXML());
		}
		return serversNode;
	}
	/*Returns the object in project form*/
	public function toProject():XMLNode{
		var serversNode = new XMLNode(1, "serverDesigns");
		/*Append all server objects as children*/
		for (var server in servers) {
			serversNode.appendChild(servers[server].toProject());
		}
		return serversNode;
	}
	/*Returns the linkage of the form associate with this object*/
	public function getForm():String {
		return "forms.project.serverDesigns";
	}
	/*Set Object attributes from XML*/
	public function setXML(newData:XMLNode):Void {
		servers = new Array();
		if (newData.nodeName == "serverDesigns") {
			for (var child in newData.childNodes) {
				var newServer = new Objects.Server.Server();
				newServer.setXML(newData.childNodes[child]);
				newServer.id = _global.formDepth++;
				servers.push(newServer);
			}
		} else {
			trace("ERROR, found node "+newData.nodeName+", expecting serverDesigns");
		}
	}
	/* Return Project Tree Structure*/
	public function toTree():XMLNode {
		var newNode = new XMLNode(1, "Servers");
		newNode.object = this;
		for (var server in servers) {
			newNode.appendChild(servers[server].toTree());
		}
		/*Retain a reference of its tree node*/
		treeNode = newNode;
		return newNode;
	}
	/* Return Name of Object*/
	public function getName():String {
		return "Project Designs";
	}
	/*Return attributes of object*/
	public function getData():Object {
		return {servers:servers,dataObject:this};
	}
	/*Set object attributes from object*/
	public function setData(newData:Object) {
		/*Close the left node, if nodes are added while node is open graphical glitches occur*/
		_global.left_tree.setIsOpen(treeNode, false);		
		//Process server list changes....
		/*Create an array to store new servers*/
		var newServers = new Array();
		/*For each server in incoming object*/
		for (var index in newData.servers) {
			/*If a server object in incoming object does not have unique id*/
			if (newData.servers[index].id == undefined) {
				/*Assign object new unique id*/
				newData.servers[index].id = _global.formDepth++;
				/*Append new server to new server list*/
				newServers.push({description:newData.servers[index].description,id:newData.servers[index].id});
			}
		}
		/* Find all servers that have been removed */
		for (var server in servers) {
			/*Prime flag to false*/
			var found = false;
			/*For each server in incoming object*/
			for (var index in newData.servers) {
				/*If server id exists*/
				if (servers[server].id == newData.servers[index].id) {
					/*Update description*/
					servers[server].description = newData.servers[index].description;
					found = true;
				}
			}
			/*If existing server is not a member of incoming object*/
			if (found == false) {
				/*Delete server*/
				servers[server].deleteSelf();
				/*Remove reference*/
				servers.splice(parseInt(server), 1);
			}
		}
		for (var newServer in newServers) {
			/*Add new Servers*/
			/*Reference Vanilla Object*/
			var new_server = new Objects.Server.Server();
			new_server.setXML(_global.default_server_xml);
			new_server.description = newServers[newServer].description;
			new_server.id = newServers[newServer].id;
			treeNode.appendChild(new_server.toTree());
			servers.push(new_server);
		}
		_global.left_tree.setIsOpen(treeNode, true);
	}
}
