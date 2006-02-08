/**
    Name: Steps
	Description: This class is used to old the workflow steps. Use an array of this class
    author: Jeff 
    version: 0.1
    modified: 20060207
    copyright: Building Intelligence
*/
import mdm.FileSystem.*;
class Objects.Steps extends Array {
	private var label:String;
	private var key:String;
	private var description:String;
	private var order:Number;


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