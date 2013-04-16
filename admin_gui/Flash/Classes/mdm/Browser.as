 /**
* @author 	MDM
* @version 	1.0.0
*/
intrinsic class mdm.Browser
{
	/* events */
	var onDocumentComplete : Function
	/* constructor */
	function Browser ();
	/* methods */
	function addFavorite (url : String, description : String) : Void
	function back () : Void
	function close () : Void
	function forward () : Void
	function goto (url : String) : Void
	function gotoTarget (url : String, target : String) : Void
	function hide () : Void
	function print (showPrompt : Boolean) : Void
	function printCopies (copies : Number) : Void
	function printFooter (footerText : String) : Void
	function printHeader (headerText : String) : Void
	function printHtmlHeader (htmlText : String) : Void
	function printMargins (left : Number, right : Number, top : Number, bottom : Number) : Void
	function printOrientation (orientation : String) : Void
	function printPreview () : Void
	function refresh () : Void
	function setSourceInTarget (content : String, target : String) : Void
	function show () : Void
	function stop () : Void
	/* properties */
	var favourites : String
	var height : Number
	var isBusy : Boolean
	var source : String
	var title : String
	var url : String
	var userAgent : String
	var visible : Boolean
	var width : Number
	var x : Number
	var y : Number
}
