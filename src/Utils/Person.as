package Utils
{
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	[Bindable("person")]
	[RemoteClass(alias="elifeAdmin.Utils.Person")]
	public class Person implements IExternalizable
	{
		private var myName:String ="fred";
		private var myAge:int =20;
		public var myThing:Thing;
		public function Person():void {
			myThing = new Thing();
		}
		
		public function get Name():String {
			return myName;
		}
		public function set Name(me:String):void {
			myName = me;
		}
		public function get Age():int {
			return myAge;
		}
		public function set Age(me:int):void {
			myAge = me;
		}
		public function writeExternal(output:IDataOutput):void {
			output.writeUTF(myName);
			output.writeInt(myAge);	
			output.writeObject(myThing);
		}
		
		public function readExternal(input:IDataInput):void {
			myName = input.readUTF()as String;
			myAge = input.readInt()as int;
			myThing = input.readObject() as Thing;
			
		}
	}
}