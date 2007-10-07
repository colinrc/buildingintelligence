package Objects {
	/**
    Name: Steps
	Description: This class is used to old the workflow steps. Use an array of this class
    author: Jeff 
    version: 0.1
    modified: 20060207
    copyright: Building Intelligence
	*/
	import flash.utils.IExternalizable;
	import flash.utils.IDataOutput;
	import flash.utils.IDataInput;
	
	[Bindable("Steps")]
	[RemoteClass(alias="elifeAdmin.objects.steps")]
	public class Steps extends Array {
		private var label:String;
		private var key:String;
		private var description:String;
		private var order:Number;
	
		public override function writeExternal(output:IDataOutput):void {
			super.writeExternal(output);
			output.writeUTF(label);
			output.writeUTF(key);
			output.writeUTF(description);
			output.writeDouble(order);
		}
		
		public override function readExternal(input:IDataInput):void {
			super.readExternal(input);
			label = input.readUTF()as String;
			key = input.readUTF()as String;
			description = input.readUTF()as String;
			order = input.readDouble() as Number;
		}
		
	
		public function Steps() {
			
		}
			
		/*
		setters/getters
		*/
		public function setLabel(myLabel:String) {
			label = myLabel;
		}
		public function getLabel(item:Number) {
			return 
	}
}