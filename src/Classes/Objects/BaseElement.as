class Objects.BaseElement {
	private var validationMsg="";
	public var usedIcons:Array = new Array();
	var usedKeys:Array;
	private var errorText:String ="";
	
	//public function getIcons():Array{
	//	return usedIcons;
	//}
	private function addIcon(icon:String){
		usedIcons.push(icon);
	}
	public function getUsedKeys():Array{
		return usedKeys;
	}
	private function addUsedKey(key:String){
		usedKeys.push(key);
	}
	public function isValid():String {
		return "ok";
	}
	public function getHighestFlagValue(oldFlag:String, isValidFlag:String):String{
		if (oldFlag == "ok"){
			return isValidFlag;
		}
		if (oldFlag == "empty") {
			if (isValidFlag == "warning" || isValidFlag == "error") {
				return isValidFlag;
			}
			else {
				return "empty";
			}
		}
		if (oldFlag == "warning") {
			if (isValidFlag == "warning" || isValidFlag == "error") {
				return isValidFlag;
			}
			else {
				return "warning";
			}
		}
		return "error";
	}
			
	public function getValidationMsg():String{
		return validationMsg;
	}
	public function setValidationMsg(msg:String):Void{
		validationMsg = msg+"\n";
	}
	public function clearValidationMsg():Void{
		validationMsg = "";
	}
	public function appendValidationMsg(msg:String):Void{
		validationMsg += msg+"\n";
	}
	public function getForm():String {
		return "base.form";
	}
	public function toXML():XMLNode {
		return new XMLNode(1,"XML_UNAVAILABLE");
	}
	public function toTree():XMLNode{
		return new XMLNode(1,"XML_UNAVAILABLE");
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
