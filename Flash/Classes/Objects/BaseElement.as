class Objects.BaseElement {
	var validation:Array;
	private var errorText:String;
	public function getValidation():Array{
		return validation;
	}
	public function getHighestFlagValue(inString1:String,inString2:String):String{
		return "ok";
	}
	public function appendValidationMsg(inString:String){
		errorText+=inString+"\n";
	}
	public function clearValidationMsg(){
		errorText = null;
	}
	public function isValid():Boolean {
		return true;
	}
	public function getForm():String {
		return "base.form";
	}
	public function toXML():XMLNode {
		return new XMLNode(1,"BLAH");
	}
	public function toTree():XMLNode{
		return new XMLNode(1,"BLAH");
	}
	public function getName():String{
		return "BASE FORM";
	}
	public function getData():Object{
		return new Object({object:""});
	}
	public function setXML(newData:XMLNode):Void{
	}
	public function setData(newData:Object):Void{
	}
}
