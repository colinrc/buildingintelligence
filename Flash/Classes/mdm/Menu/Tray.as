 /**
* @author 	MDM
* @version 	1.0.0
*/
intrinsic class mdm.Menu.Tray
{
	/* events */
	/* constructor */
	/* methods */
	static function hideIcon () : Void
	static function insertDivider () : Void
	static function insertItem (itemLabel : String) : Void
	static function itemChecked (itemLabel : String, checked : Boolean) : Void
	static function itemEnabled (itemLabel : String, enabled : Boolean) : Void
	static function itemVisible (itemLabel : String, visible : Boolean) : Void
	static function removeItem (itemLabel : String) : Void
	static function setMenuType (menuType : String) : Void
	static function setIcon (filePath : String) : Void
	static function showBalloon (balloonTitle : String, balloonText : String, balloonIconType : String, BalloonTimeout : Number, balloonFrameLabel : String) : Void
	static function showIcon () : Void
	/* properties */
	static var menuType : String
	static var iconHint : String
}
