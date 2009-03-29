/**
* @author 	MDM
* @version 	1.0.0
*/
intrinsic class mdm.AppleScript {
	/* events */
	/* constructor */
	/* methods */
	/**
	*	<p>Compiles a previously defined AppleScript and returns true
	* 	if the Script Compiled without Errors or false is the Script Compiled with Errors.</p>
	*	@use <pre>var compiled = mdm.AppleScript.compileScript();</pre>
	*	@return Boolean
	*/
	static function compileScript():Boolean;
	/**
	*	<p>If a runtime error is found, you can use this command to return
	* 	the exact details of the error.</p>
	*	@use	<pre>var lastError = mdm.AppleScript.getLastError();</pre>
	*	@return	String
	*/
	static function getLastError():String;
	/**
	*	<p>If a compilation error is found, you can use this command to return the exact details of the error</p>
	*	@use	<pre>var errorDetails = mdm.AppleScript.getCompilationError();</pre>
	*	@return	String
	*/
	static function getCompilationError():String;
	/**
	*	<p>Used to retrieve the value of the specified Property (if applicable).</p>
	*	@use	<pre>var errorDetails = mdm.AppleScript.getCompilationError();</pre>
	*	@param	propertyName	Reference to the Property Name
	*	@return String
	*/
	static function getProperty(propertyName:String):String;
	/**
	*	<p>Used to retrieve the AppleScript result value (if applicable).</p>
	*	@use	<pre>var myResults = mdm.AppleScript.getResult();</pre>
	*	@return	String
	*/
	static function getResult():String;
	/**
	*	<p>Will run the previously set and compiled AppleScript.
	* 	Returns true if the Script Executed without Errors, or false is the Script Executed with Errors.</p>
	*	@use	<pre>var success = mdm.AppleScript.run();</pre>
	*	@return	Boolean
	*/
	static function run():Boolean;
	/**
	*	<p>This command will execute an Event (a Function that resides inside a AppleScript).</p>
	*	@use	<pre>mdm.AppleScript.runEvent("showDialog", "Hello World");</pre>
	*	@param	eventName	Reference to the Event Name
	*	@param	params	Reference to an optional Event Parameter. Upto 8 Parameters can be passed (Param1, Param2 etc).
	*	@return	String
	*/
	static function runEvent(eventName:String, params:String):String;
	/**
	*	<p>Used to set the value of the specified Property (if applicable).</p>
	*	@use	<pre>mdm.AppleScript.setProperty("myProperty", "This is my Value");</pre>
	*	@param	propertyName	Reference to the Property Name
	*	@param	propertyValue	Reference to the Property Value
	*	@return	String
	*/
	static function setProperty(propertyName:String, propertyValue:String):String;
	/**
	*	<p>Used to set the value of the specified Property (if applicable).</p>
	*	@use	<pre>mdm.AppleScript.setScript("tell application \"Finder\" empty trash end tell");</pre>
	*	@param	script	Contains the AppleScript to be set
	*	@return nothing
	*/
	static function setScript(script:String):Void;
	/* properties */
}
