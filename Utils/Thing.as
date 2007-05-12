package Utils
{
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	[Bindable("jkjk")]
	[RemoteClass(alias="elifeAdmin.Utils.mn")]
	public class Thing implements IExternalizable
	{
		private var myThing:String ="apple";
		private var myThingsize:int =100;
		
		public function get meThing():String {
			return myThing;
		}
		public function set meThing(me:String):void {
			myThing = me;
		}
		public function get Size():int {
			return myThingsize;
		}
		public function set Size(me:int):void {
			myThingsize = me;
		}
		public function writeExternal(output:IDataOutput):void {
			output.writeUTF(myThing);
			output.writeInt(myThingsize);	
		}
		
		public function readExternal(input:IDataInput):void {
			
			myThing = input.readUTF()as String;
			myThingsize = input.readInt()as int;
		
		}
	}
}