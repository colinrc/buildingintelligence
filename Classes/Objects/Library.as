/*  DISCLAIMER
 This is pretty rough, and there arent any dependancies for this
 class yet, so feel free to change, improvise, develop, criticize
 any ideas here*/
class Objects.Library {
	//the library stored as xml
	private var library:XML;
	/*routines for loading/importing an existing library
	 or creating a new one need to be established.*/
	/*if all the components are stored within an xml file, loading
	 and storing operations should be very straight forward.*/
	public function Library(){
	}
	/*return a template from the library, this needs to have a URL
	 that specifies where the object is in the library and another
	 URL that specifices where the object is to go in the project?*/
	public function getObject(objectURL:String):Object{
		return new Object();
	}
	/*Store an object in the library as a template, it needs to have
	 a URL that specifies what peice of the project it is*/
	public function addObject(inObject:Object){
	}
	/*Replace an object template at objectURL*/
	public function changeObject(objectURL:String,inObject:Object){
	}
	/*The library will be displayed on the UI (most likely in
	 a tree component), changes to the library will only be made
	 through this class however*/
	public function viewLibrary():XML{
		return library;
	}
}