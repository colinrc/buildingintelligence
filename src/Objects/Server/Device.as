package Objects.Server {
	import Objects.*;
	import mx.utils.ObjectProxy;
	import flash.utils.*;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import flash.events.IEventDispatcher;
	import mx.core.Application;
	[Bindable("device")]
	[RemoteClass(alias="elifeAdmin.server.device")]
	public class Device extends BaseElement {
		[Bindable]
		public var device_type:String="";
		[Bindable]
		public var description:String="";
	//	public var id:int;
		[Bindable]
		public var active:String="";
		[Bindable]
		public var catalogues:Catalogues = new Catalogues();
		[Bindable]
		public var connection:Connection = new Connection();
		[Bindable]
		public var parameters:HashMap = new HashMap();
		
		public function deleteSelf():void{
			if (treeNode != null) {
				treeNode.removeNode();
			}
		}			
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(device_type);
			output.writeUTF(description);
			output.writeUTF(active);	
			output.writeObject(catalogues);
			output.writeObject(connection);
			output.writeObject(parameters);
		}
		
		public function newObject():void {
			parameters = new HashMap();	
			connection = new Connection();
			catalogues = new Catalogues();	
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			device_type = input.readUTF() as String;
			description = input.readUTF() as String;
			active = input.readUTF() as String;		
			catalogues = input.readObject() as Catalogues;
			connection = input.readObject() as Connection;
			parameters= input.readObject() as HashMap;
		}
		public override function isValid():String {
			var flag:String = "ok";
			clearValidationMsg();
					
			if ((active != "Y") && (active != "N")) {
				flag = "error";
				appendValidationMsg("Active is invalid");
			}
			else {
				if (active =="Y"){
					if ((description == undefined) || (description == "")) {
						flag = "empty";
						appendValidationMsg("Description is empty");
					}
					if ((device_type == undefined) || (device_type == "")) {
						flag = "error";
						appendValidationMsg("Device Type is invalid");
					}
					
					if (connection == null || connection.type == "") {
					flag = "error";
					appendValidationMsg("Connection is missing");
					}
					else {
						//trace("cbus node:"+connection.ip.name());
						if (connection.type == "IP") {
							if ((connection.address == "") || (connection.address ==null)) {
								flag = "error";
								appendValidationMsg("Connection Address is empty");
							}
							else if (Application.application.isValidIP(connection.address)==false) {
								flag = "error";
								appendValidationMsg("Connection IP Address is invalid");
							}
							if ((connection.port == "") || (connection.port ==null)) {
								flag = "error";
								appendValidationMsg("Connection Port is empty");
							}
						}
						else{
							//FLOW="NONE" DATA_BITS="8" STOP_BITS="1" SUPPORTS_CD="N" PARITY="NONE" BAUD="9600" ACTIVE
							if ((connection.port == "") || (connection.port ==null)) {
								flag = "error";
								appendValidationMsg("Connection Port is empty");
							}
							if ((connection.flow == "") || (connection.flow ==null)) {
								flag = "error";
								appendValidationMsg("Connection Flow is invalid");
							}
							if ((connection.dataBits == "") || (connection.dataBits ==null)) {
								flag = "error";
								appendValidationMsg("Connection Data Bits is invalid");
							}
							if ((connection.stopBits == "") || (connection.stopBits ==null)) {
								flag = "error";
								appendValidationMsg("Connection Stop Bits is invalid");
							}
							if ((connection.supportsCD == "") || (connection.supportsCD ==null)) {
								flag = "error";
								appendValidationMsg("Connection Supports CD is invalid");
							}
							if ((connection.parity == "") || (connection.parity ==null)) {
								flag = "error";
								appendValidationMsg("Connection Parity is invalid");
							}
							if ((connection.baud == "") || (connection.baud ==null)) {
								flag = "error";
								appendValidationMsg("Connection Baud is invalid");
							}
						} 
					} 
				}
				else {
					if (active =="N"){
						flag = "empty";
						appendValidationMsg(device_type + " is not active");
					}
				}
				
			}
			return flag;
		}
		
		public override function getForm():String {
			return "forms.project.device.head";
		}
		public override function getName():String {
			return device_type+" : "+description;
		}
		
		public function get Data():ObjectProxy {
			var ob:ObjectProxy = new ObjectProxy( {device_type:device_type, description:description, active:active, connection:connection, parameters:parameters, dataObject:this})
			return ob;
		}
		[Bindable] 
		public function set Data(newData:ObjectProxy):void {
			device_type = newData.device_type;
			description = newData.description;
			active = newData.active;
			connection = newData.connection;
			parameters = newData.parameters;
		}		
	}
}