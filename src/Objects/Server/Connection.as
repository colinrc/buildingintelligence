package Objects.Server {
	import Objects.*;
	import flash.xml.XMLNode;
	import mx.utils.ObjectProxy;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import flash.events.EventDispatcher;
	[Bindable("connection")]
	[RemoteClass(alias="elifeAdmin.objects.server.connection")]
	public class Connection extends EventDispatcher implements IExternalizable {
		[Bindable]
		public var type:String;
		[Bindable]
		public var port:String;
		[Bindable]
		public var baud:String;
		[Bindable]
		public var parity:String;
		[Bindable]
		public var flow:String;
		[Bindable]
		public var dataBits:String;
		[Bindable]
		public var stopBits:String;
		[Bindable]
		public var supportsCD:String;
		[Bindable]
		public var address:String;
		[Bindable]
		public var active:String;
	
		/*[Bindable]
		public function set address(value:String) :void {
			s_address = value;
		}
		
		public function get address() :String {
			return s_address;
		}*/
		
		public function writeExternal(output:IDataOutput):void {
			output.writeUTF(type);
			output.writeUTF(port);
			output.writeUTF(baud);
			output.writeUTF(parity);
			output.writeUTF(flow);
			output.writeUTF(dataBits);
			output.writeUTF(stopBits);
			output.writeUTF(supportsCD);
			output.writeUTF(address);
			output.writeUTF(active);
		}
		
		public function readExternal(input:IDataInput):void {
			type = input.readUTF() as String;
			port = input.readUTF() as String;
			baud = input.readUTF() as String;
			parity = input.readUTF() as String;
			flow = input.readUTF() as String;
			dataBits = input.readUTF() as String;
			stopBits = input.readUTF() as String;
			supportsCD = input.readUTF() as String;
			address = input.readUTF() as String;
			active = input.readUTF() as String;
		}
		
		
		public function isValid():String {
			var flag:String = "ok";
			clearValidationMsg();
		
			if ((type == null) || (type == "")) {
				flag = "error";
				appendValidationMsg("Connection type is empty");
			}
			if (active == "Y") {
				if (type == "IP") {
					if ((address == null) || (address == "")) {
						flag = "error";
						appendValidationMsg("Connection address is empty");
					}
					if ((port == null) || (port == "")) {
						flag = "error";
						appendValidationMsg("Connection port is empty");
					}
				} else if (type == "SERIAL") {
					if ((flow == null) || (flow == "")) {
						flag = "error";
						appendValidationMsg("Connection flow is empty");
					}
					if ((dataBits == null) || (dataBits == "")) {
						flag = "error";
						appendValidationMsg("Connection Data Bits is empty");
					}
					if ((stopBits == null) || (stopBits == "")) {
						flag = "error";
						appendValidationMsg("Connection Stop Bits is empty");
					}
					if ((supportsCD == null) || (supportsCD == "")) {
						flag = "error";
						appendValidationMsg("Connection Supports CD is empty");
					}
					if ((parity == null) || (parity == "")) {
						flag = "error";
						appendValidationMsg("Connection Parity is empty");
					}
					if ((baud == null) || (baud == "")) {
						flag = "error";
						appendValidationMsg("Connection Baud is empty");
					}
					if ((port == null) || (port == "")) {
						flag = "error";
						appendValidationMsg("Connection port is empty");
					}
				}
			}
			
		
			return flag;
		}
		
		public function toXML():XML {
			var newCatalogue:XML = new XML("<CONNECTION />");
			var child:XML;
			if (type == "IP") {
				child = new XML("<IP ADDRESS=\""+address+"\" PORT=\""+port+ "\" />");
			} else if (type == "SERIAL") {
				child = new XML("<SERIAL FLOW=\""+flow+"\" DATA_BITS=\""+dataBits+"\" STOP_BITS=\""+stopBits+"\" SUPPORTS_CD=\""+supportsCD+"\" PARITY=\""+parity+"\" BAUD=\""+baud+"\" PORT=\""+port+"\" ACTIVE=\""+active+ "\" />");
			}
			newCatalogue.appendChild(child);
			
			return newCatalogue;
		}
		public function getName():String {
			return type;
		}
		public  function toTree():MyTreeNode {
			var newNode:MyTreeNode = new MyTreeNode();
			newNode.make(1,getName(),this);
			treeNode =newNode;
			return newNode;
		}
		public function getKey():String {
			return "Connection";
		}
		
		public function setXML(newData:XML):void {
			type = newData.children()[0].name();
			port = newData.children()[0].@PORT;
			baud = newData.children()[0].@BAUD;
			parity = newData.children()[0].@PARITY;
			flow = newData.children()[0].@FLOW;
			dataBits = newData.children()[0].@DATA_BITS;
			stopBits = newData.children()[0].@STOP_BITS;
			supportsCD = newData.children()[0].@SUPPORTS_CD;
			address = newData.children()[0].@IP_ADDRESS;
			active = newData.children()[0].@ACTIVE;
		}
	}
}