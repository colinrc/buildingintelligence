/* DISCLAIMER
 This is pretty rough, and there arent any dependancies for this
 class yet, so feel free to change, improvise, develop, criticize
 any ideas here*/
class Objects.History {
	//The history stored as xml
	private var history:XML;
	/* an evtObj could be an object containing XML and a reference
	to where in the project it came from (some kind of URL standard
	needs to be decided) these evtObj's could be stored as CCDATA 
	within an XML document, along with time and details of change.
	Weather or not we are simply tracking changes or allowing a
	change control system is open to debate. Although a simple
	tracking mechanism is all we need at this stage*/
	public function History() {
	}
	//evtObj is the object being changed, oldValues is an object containing
	//the previous values and newValues is an object containing the new values
	public function objectChanged(evtObj:Object, oldValues:Object, newValues:Object):Void{
	}
	public function objectCreated(evtObj:Object, newValues:Object){
	}
	public function objectDeleted(evtObj:Object, oldValues:Object){
	}
	/*The history will be displayed on the UI (most likely in
	 a tree component), changes to the history will only be made
	 through this class however*/
	public function viewHistory():XML{
		//This just needs to return the encapsulated XML
		return history;
	}
	/*Roll back a particular change, dependencies will need to be checked... 
	 maybe this is a little hardcore?*/
	public function rollBack():evtObj{
		//this could potentially return a list of changes
		return new Object();
	}
	//simple undo
	public function rollBackLastChange():evtObj{
		return new Object();
	}
}