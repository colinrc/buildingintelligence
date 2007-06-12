package Objects.Server {
	import Objects.*;
	import mx.utils.ObjectProxy;
	import flash.utils.*;
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	import flash.events.IEventDispatcher;
	[Bindable("device")]
	[RemoteClass(alias="elifeAdmin.server.device")]
	public class Device extends BaseElement {
		[Bindable]
		public var device_type:String;
		[Bindable]
		public var description:String;
	//	public var id:int;
		[Bindable]
		public var active:String;
		[Bindable]
		public var catalogues:Catalogues;
		[Bindable]
		public var connection:Connection = new Connection();
		[Bindable]
		public var parameters:Array;
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
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			device_type = input.readUTF() as String;
			description = input.readUTF() as String;
			active = input.readUTF() as String;		
			catalogues = input.readObject() as Catalogues;
			connection = input.readObject() as Connection;
			parameters= input.readObject() as Array;
		}
		public override function isValid():String {
			return connection.isValid();
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
		public override function set Data(newData:ObjectProxy):void {
			device_type = newData.device_type;
			description = newData.description;
			active = newData.active;
			connection = newData.connection;
			parameters = newData.parameters;
		}		
	}
}