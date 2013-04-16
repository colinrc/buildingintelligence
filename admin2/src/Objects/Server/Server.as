package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import Objects.Server.*;
	import Objects.Client.*;
	import mx.core.Application;
	import Objects.MyTreeNode;
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	import mx.core.UIComponent;
	import Forms.Server.Server_test;
	import Forms.Server.ClientDesign;
	import Forms.Server.ClientDesign_frm;
	import mx.collections.ArrayCollection;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	[Bindable("Server")]
	[RemoteClass(alias="elifeAdmin.server.server")] 
	public class Server extends BaseElement {
		[Bindable]
		public var description:String="";
		//private var id:int;
		private var controls:Controls;
		private var settings:Settings;
		private var macros:Macros;  
		private var scripts:Scripts;
		[Bindable]
		public var devices:ArrayCollection;
		private var JROBIN:XML;
		[Bindable]
		public var clients:Array;
		private var parentObject:Object;
		
		public function Server(){
			
			description = "";
			devices = new ArrayCollection();
			controls = new Controls();
			settings = new Settings();
			macros = new Macros();
			scripts = new Scripts();
			clients = new Array();
			
			JROBIN = new XML("<JROBIN />");
			//*Append default client device here**/	
			var new_client:Client;	
	 		new_client = new Client();
	 		//Application.application.formDepth++;
			new_client.setXML(Application.application.default_client_xml);
			
			new_client.description = "Client-1";
			new_client.id = Application.application.incFormDepth();
			clients.push(new_client);		
		}
		
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(description);
			output.writeObject(controls);
			output.writeObject(settings);
			output.writeObject(macros);
			output.writeObject(scripts);
			output.writeObject(devices);
			output.writeObject(JROBIN);
			output.writeObject(clients);
			output.writeObject(parentObject);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			description = input.readUTF()as String;
			controls = input.readObject() as Controls;
			settings = input.readObject() as Settings;
			macros = input.readObject() as Macros;  
			scripts = input.readObject() as Scripts;
			devices = input.readObject() as ArrayCollection;
			JROBIN = input.readObject() as XML;
			clients = input.readObject() as Array;
			parentObject = input.readObject() as Object;
		}
		
		public function deleteSelf():void {
			treeNode.removeNode();
		}			
		public function getKeys():Array{
			var tempKeys:Array = new Array();
			for(var device in devices){
				tempKeys = tempKeys.concat(devices[device].getKeys());
			}
			tempKeys = tempKeys.concat(controls.getKeys());
			//mdm.Dialogs.prompt(controls.getKeys());
			tempKeys = tempKeys.sort();
			var keys:Array = new Array();
			var lastKey:String;
			for(var tempKey in tempKeys){
				if(tempKeys[tempKey] != lastKey){
					keys.push(tempKeys[tempKey]);
					lastKey = tempKeys[tempKey];
					//What if not in order
				}
			}
			return keys;
		}
		public function vaildateKeys():Array{
			var keys:Array = new Array();
			return keys;
		}
		
		public override function  isValid():String {
			var flag:String = "ok";
			flag = getHighestFlagValue(flag, controls.isValid());
			for (var device in devices) {
				flag = getHighestFlagValue(flag, devices[device].isValid());
			}
			return flag;
		}
		public override function getForm():String {
			var className:String = getQualifiedClassName( this ).replace( "::", "." );	
			return className;			
		}
		public function getClassForm():Array {
			var className:Class = Forms.Server.Server_frm;
			var class2Name:Class = Forms.Server.ClientDesign_frm;
			
			return [className,class2Name];			
			//return "Forms.Server.Server_frm";
		}
		public override function toXML():XML {
			var serverNode:XML = new XML("<CONFIG />");
			var descriptionNode:XML = new XML("<DESC>"+description+"</DESC>");
			serverNode.appendChild(descriptionNode);
			var controlNode:XML = new XML("<CONTROLS />");
			controlNode.appendChild(controls.toXML());
			controlNode.appendChild(settings.toXML());
			serverNode.appendChild(controlNode);
			serverNode.appendChild(macros.toXML());
			serverNode.appendChild(scripts.toXML());
			serverNode.appendChild(JROBIN);
			for (var device:int in devices) {
				serverNode.appendChild(devices[device].toXML());
			}
			return serverNode
		}
		public function getMacros():Array{
			return macros.getMacros();
		}
		public function getScripts():XML{
			return scripts.toXML();
		}
		public function toProject():XML {
			var serverNode:XML = new XML("<CONFIG />");
			var descriptionNode:XML = new XML("<DESC>"+description+"</DESC>");
			serverNode.appendChild(descriptionNode);
			var controlNode:XML = new XML("<CONTROLS />");
			controlNode.appendChild(controls.toXML());
			controlNode.appendChild(settings.toXML());
			serverNode.appendChild(controlNode);
			serverNode.appendChild(macros.toXML());
			serverNode.appendChild(scripts.toXML());
			serverNode.appendChild(JROBIN);
			for (var device:int in devices) {
				serverNode.appendChild(devices[device].toXML());
			}
			
			for (var client in clients) {
				serverNode.appendChild(clients[client].toXML());
			}
			return serverNode;
		}
		public override function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
						
			//test for advanced set
			if(mx.core.Application.application.advancedOn == true){
				newNode.appendChild(controls.toTree());
				newNode.appendChild(settings.toTree());			
			}
			newNode.appendChild(macros.toTree());
			newNode.appendChild(scripts.toTree());
			for (var device in devices) {
				newNode.appendChild(devices[device].toTree());
			}
			treeNode = newNode;
			return newNode;
		}
		public function getKey():String {
			return "Server";
		}	
		 public override function getName():String {
			return "Server Design";
		}
		 public function get2Name():String {
			return "Client Designs";
		}
		public function getOtherNames():ArrayCollection {
			var tabNames:ArrayCollection = new ArrayCollection();
			tabNames.addItem(getName());
			tabNames.addItem("Client Designs");
			return tabNames;
		}
		public  function get Data():ObjectProxy {
			var ob:ObjectProxy = new ObjectProxy({description:description, devices:devices, dataObject:this, clients:clients});
			return ob;
		}
		public  function getClients():Array{
			return clients;
		}
		
		public  function setClients(newData:Object){
			/*Close the left node, if nodes are added while node is open graphical glitches occur*/
			//_global.left_tree.setIsOpen(treeNode, false);		
			//Process client list changes....
			/*Create an array to store new clients*/
			var newClients = new Array();
			/*For each client in incoming object*/
			for (var index in newData.clients) {
				/*If a client object in incoming object does not have unique id*/
				if (newData.clients[index].id == undefined) {
					/*Assign object new unique id*/
					newData.clients[index].id = Application.application.formDepth++;
					/*Append new client to new client list*/
					newClients.push({description:newData.clients[index].description,id:newData.clients[index].id});
				}
			}
			/* Find all clients that have been removed */
			for (var client in clients) {
				/*Prime flag to false*/
				var found:Boolean = false;
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
				new_client.setXML(Application.application.default_client_xml.children()[0]);
				new_client.description = newClients[newClient].description;
				new_client.id = newClients[newClient].id;
				//Append global tree
				Application.application.designTree_xml.appendChild(new_client.toTree());
				clients.push(new_client);
			}
			//_global.left_tree.setIsOpen(treeNode, true);		
		}
		[Bindable]
		public  function set Data(newData:ObjectProxy):void {
			//_global.left_tree.setIsOpen(treeNode, false);		
			description = newData.description;
			//Process device changes....
			var newDevices = new Array();
			for (var index in newData.devices) {
				if (newData.devices[index].id == undefined) {
					newDevices.push({description:newData.devices[index].description, device_type:newData.devices[index].device_type});
				}
			}
			for (var device in devices) {
				var found = false;
				for (var index in newData.devices) {
					if (devices[device].id == newData.devices[index].id) {
						if(devices[device].device_type == newData.devices[index].device_type){
							devices[device].description = newData.devices[index].description;
							found = true;
						} else{
							newDevices.push({description:newData.devices[index].description, device_type:newData.devices[index].device_type});
						}
					}
				}
				if (found == false) {
					devices[device].deleteSelf();
					devices.removeItemAt(device);
				}
			}
			for (var newDevice in newDevices) {
				var newNode:XML = new XML("<DEVICE />");
				newNode.@DESCRIPTION = newDevices[newDevice].description;
				newNode.@DEVICE_TYPE = newDevices[newDevice].device_type;
				newNode.@ACTIVE = "N";
				var newDevice:XML = new XML("<"+newDevices[newDevice].device_type+" />");
				newNode.appendChild(newDevice);
				switch (newNode.@DEVICE_TYPE) {
				case "PELCO" :
					var newPelco = new Pelco();
					newPelco.setXML(newNode);
					newPelco.id = Application.application.formDepth++;
					newPelco.active = "Y";
					treeNode.appendChild(newPelco.toTree());				
					devices.addItem(newPelco);
					break;
				case "OREGON" :
					var newOregon = new Oregon();
					newOregon.setXML(newNode);
					newOregon.id = Application.application.formDepth++;
					newOregon.active = "Y";				
					treeNode.appendChild(newOregon.toTree());
					devices.addItem(newOregon);
					break;
				case "IR_LEARNER" :
					var newIR = new IR_Learner();
					newIR.setXML(newNode);
					newIR.id = Application.application.formDepth++;
					newIR.active = "Y";				
					treeNode.appendChild(newIR.toTree());
					devices.addItem(newIR);
					break;
				case "TUTONDO" :
					var newTutondo = new Tutondo();
					newTutondo.setXML(newNode);
					newTutondo.id = Application.application.formDepth++;
					newTutondo.active = "Y";				
					treeNode.appendChild(newTutondo.toTree());				
					devices.addItem(newTutondo);
					break;
				case "KRAMER" :
					var newKramer = new Kramer();
					newKramer.setXML(newNode);
					newKramer.id = Application.application.formDepth++;
					newKramer.active = "Y";				
					treeNode.appendChild(newKramer.toTree());				
					devices.addItem(newKramer);
					break;
				case "HAL" :
					var newHal = new Hal();
					newHal.setXML(newNode);
					newHal.id = Application.application.formDepth++;
					newHal.active = "Y";				
					treeNode.appendChild(newHal.toTree());				
					devices.addItem(newHal);
					break;
				case "CBUS" :
					var newCBus = new CBus();
					newCBus.setXML(newNode);
					newCBus.id = Application.application.formDepth++;
					newCBus.active = "Y";				
					treeNode.appendChild(newCBus.toTree());				
					devices.addItem(newCBus);
					break;
				case "NUVO" :
					var newNuvo = new Nuvo();
					newNuvo.setXML(newNode);
					newNuvo.id = Application.application.formDepth++;				
					newNuvo.active = "Y";				
					treeNode.appendChild(newNuvo.toTree());
					devices.addItem(newNuvo);
					break;
				case "SIGN_VIDEO" :
					var newSignVideo = new SignVideo();
					newSignVideo.setXML(newNode);
					newSignVideo.id = Application.application.formDepth++;				
					newSignVideo.active = "Y";				
					treeNode.appendChild(newSignVideo.toTree());
					devices.addItem(newSignVideo);
					break;
				case "DYNALITE" :
					var newDynalite = new Dynalite();
					newDynalite.setXML(newNode);
					newDynalite.id = Application.application.formDepth++;				
					newDynalite.active = "Y";				
					treeNode.appendChild(newDynalite.toTree());
					devices.addItem(newDynalite);
					break;
				case "DMX" :
					var newDMX = new DMX();
					newDMX.setXML(newNode);
					newDMX.id = Application.application.formDepth++;				
					newDMX.active = "Y";				
					treeNode.appendChild(newDMX.toTree());
					devices.addItem(newDMX);
					break;
				case "GC100" :
					var newGC100 = new GC100();
					newGC100.setXML(newNode);
					newGC100.id = Application.application.formDepth++;
					newGC100.active = "Y";				
					treeNode.appendChild(newGC100.toTree());
					devices.addItem(newGC100);
					break;
				case "RAW_CONNECTION" :
					var newRaw = new Raw_Connection();
					newRaw.setXML(newNode);
					newRaw.id = Application.application.formDepth++;				
					newRaw.active = "Y";				
					treeNode.appendChild(newRaw.toTree());		
					devices.addItem(newRaw);
					break;
				case "M1" :
					var newM1 = new M1();
					newM1.setXML(newNode);
					newM1.id = Application.application.formDepth++;								
					newM1.active = "Y";				
					treeNode.appendChild(newM1.toTree());
					devices.addItem(newM1);
					break;
				case "COMFORT" :
					var newComfort = new Comfort();
					newComfort.setXML(Application.application.comfort_XML.firstChild);
					//newComfort.setXML(newNode);
					newComfort.id = Application.application.formDepth++;								
					newComfort.active = "Y";				
					treeNode.appendChild(newComfort.toTree());
					devices.addItem(newComfort);
					break;
				case "CUSTOM_CONNECT":
					var newCustomConnect = new CustomConnect();
					newCustomConnect.setXML(newNode);
					newCustomConnect.id = Application.application.formDepth++;								
					newCustomConnect.active = "Y";				
					treeNode.appendChild(newCustomConnect.toTree());
					devices.addItem(newCustomConnect);
					break;
				case "JANDI":
					var newJandy = new Jandy();
					newJandy.setXML(newNode);
					newJandy.id = Application.application.formDepth++;								
					newJandy.active = "Y";				
					treeNode.appendChild(newJandy.toTree());
					devices.addItem(newJandy);
					
					break;
					}
				}
			//Application.application.left_tree.setIsOpen(treeNode, true);		
		}
		public  override function setXML(newData:XML):void {
			controls = new Controls();
			settings = new Settings();
			macros = new Macros();
			scripts = new Scripts();
			devices = new ArrayCollection();
			clients = new Array();
			description = "";
			if (newData.name().toString() == "CONFIG") {
				description = newData.CONFIG.DESC;
				var sizeOfDevices:int = newData.elements("DEVICE").length()
				
				var i:int;
				for (i = 0; i < sizeOfDevices; i++) {
	
					var dev:XML = newData.elements("DEVICE")[i];
					//if (dev.attribute("NAME").toString() != undefined) {
					var	device_type:String = dev.attribute("NAME").toString() ;
					if (device_type == undefined || device_type =="") {
						device_type = dev.@DEVICE_TYPE;
					}
					//connection
					//parameters			
					
					switch (device_type) {
						case "PELCO" :
							var newPelco = new Pelco();
							newPelco.setXML(dev);
							newPelco.id = Application.application.formDepth++;
												
							devices.addItem(newPelco);
							break;
						case "OREGON_SCIENTIFIC":
							dev.@DEVICE_TYPE = "OREGON";
						case "OREGON" :
							var newOregon = new Oregon();
							newOregon.setXML(dev);
							newOregon.id = Application.application.formDepth++;
												
							devices.addItem(newOregon);
							break;
						case "IR_LEARNER" :
							var newIR = new IR_Learner();
							newIR.setXML(dev);
							newIR.id = Application.application.formDepth++;
													
							devices.addItem(newIR);
							break;
						case "TUTONDO" :
							var newTutondo = new Tutondo();
							newTutondo.setXML(dev);
							newTutondo.id = Application.application.formDepth++;
													
							devices.addItem(newTutondo);
							break;
						case "KRAMER" :
							var newKramer = new Kramer();
							newKramer.setXML(dev);
							newKramer.id = Application.application.formDepth++;
												
							devices.addItem(newKramer);
							break;
						case "HAL" :
							var newHal = new Hal();
							newHal.setXML(dev);
							newHal.id = Application.application.formDepth++;
													
							devices.addItem(newHal);
							break;
						case "CBUS" :
							var newCBus:CBus = new CBus();
							newCBus.setXML(dev);
							newCBus.id = Application.application.incFormDepth();
													
							devices.addItem(newCBus);
							break;
						case "DYNALITE" :
							var newDynalite = new Dynalite();
							newDynalite.setXML(dev);
							newDynalite.id = Application.application.formDepth++;
												
							devices.addItem(newDynalite);
							break;
						case "DMX" :
							var newDMX = new DMX();
							newDMX.setXML(dev);
							newDMX.id = Application.application.formDepth++;
													
							devices.addItem(newDMX);
							break;
						case "GC100" :
							var newGC100 = new GC100();
							newGC100.setXML(dev);
							newGC100.id = Application.application.formDepth++;
													
							devices.addItem(newGC100);
							break;
						case "NUVO" :
							var newNuvo = new Nuvo();
							newNuvo.setXML(dev);
							newNuvo.id = Application.application.formDepth++;
													
							devices.addItem(newNuvo);
							break;
						case "SIGN_VIDEO" :
							var newSignVideo = new SignVideo();
							newSignVideo.setXML(dev);
							newSignVideo.id = Application.application.formDepth++;
												
							devices.addItem(newSignVideo);
							break;
						case "M1":
							var newM1 = new M1();
							newM1.setXML(dev);
							newM1.id = Application.application.formDepth++;						
												
							devices.addItem(newM1);
							break;					
						case "RAW_CONNECTION" :
							var newRaw = new Raw_Connection();
							newRaw.setXML(dev);
							newRaw.id = Application.application.formDepth++;						
													
							devices.addItem(newRaw);
							break;
						case "COMFORT" :
							var newComfort = new Comfort();
							newComfort.setXML(dev);
							newComfort.id = Application.application.formDepth++;
												
							devices.addItem(newComfort);
							break;
						case "CUSTOM_CONNECT":
							var newCustomConnect = new CustomConnect();
							newCustomConnect.setXML(dev);
							newCustomConnect.id = Application.application.formDepth++;
								
							devices.addItem(newCustomConnect);
							break;
						case "JANDI":
							var newJandy = new Jandy();
							newJandy.setXML(dev);
							newJandy.id = Application.application.formDepth++;
								
							devices.addItem(newJandy);
							break;
					}
				}
	/***************************************************************************************/

				var variables:XML = newData.CONTROLS[0].VARIABLES[0];
				if (variables != undefined) {
					controls.setXML(variables);
				}
				
				var cal:XML = newData.CONTROLS[0].CALENDAR_MESSAGES[0];
				if (cal != undefined) {
					settings.setXML(cal);
				}
				
				var desc:XML = newData.DESC[0];
				if (desc != undefined) {
					description = desc.toString();
				}
				
				JROBIN = newData.JROBIN[0];
				
				for (var theClients:int=0 ; theClients < newData.application.length() ; theClients++) {
					var app:XML = newData.application[theClients];
					if (app != undefined) {
						var newClient:Client = new Client();
						newClient.setXML(app);
						newClient.id = Application.application.incFormDepth();
						clients.push(newClient);
					}
				}
				
				macros.setXML(newData.MACROS[0]);
				scripts.setXML(newData.SCRIPT_STATUS[0]);
				
			}
		}
			
	}
}