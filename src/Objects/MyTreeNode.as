package Objects
{
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("myTreeNode")]
	[RemoteClass(alias="elifeAdmin.objects.server.myTreeNode")]
	dynamic public class MyTreeNode implements IExternalizable {
		public var childObject:Array;
		public var object:Object;
		public var myXML:XML;
		
		public function writeExternal(output:IDataOutput):void {
			output.writeObject(childObject);
			output.writeObject(object);	
			output.writeObject(myXML);
		}
		
		public function readExternal(input:IDataInput):void {
			childObject = input.readObject() as Array;
			object = input.readObject()as Object;
			myXML = input.readObject()as XML;		
		}
		
		public function MyTreeNode():void{
			
		}
		public function make(type:uint, value:String, ob:Object):void
		{
			var icon:String = "def";
			var key:String = "";
			object = ob;
			childObject = new Array();
			if (type == 0) { //top level
				myXML = new XML("<"+value+ " />");
				//trace(myXML.toXMLString());
			}
			else {
				if (object == null) {
					icon = "def";
					key = "";
					
				} else
				{
					key = object.getKey()+"_*_"+object.getUniqueID();
					icon = object.isValid();
					if (icon=="error") {icon = "err";}
				}
				myXML = new XML("<node name=\""+value+ "\" icon = \""+icon+"\" key=\""+key+"\" />");
				//trace(myXML.toXMLString());
			}
		}
		public function getObject():Object {
			return object;
		}
		public function setObject(obj:Object):void {
			object= obj;
		}	
		public function appendChildObject(obj:Object):void {
			childObject.push(obj);
		}
		public function getChildObject():Array {
			return childObject;
		}
		public function setChildObject(obj:Array):void {
			childObject = obj;
		}	
		public function getXML():XML {
			return myXML;
		}	
		public function setXML(obj:XML):void {
			myXML = obj;
		}
		public function appendChild(obj:MyTreeNode):MyTreeNode {
			childObject.push(obj);
			var objXML:XML = obj.getXML();
			myXML.appendChild(objXML);
			
			//trace ("myXML:"+myXML.toXMLString());
			return this;
			
		}
	}
}