package Controls
{
 import flash.events.Event;
 import mx.controls.dataGridClasses.DataGridListData;
 import mx.core.mx_internal;
 import mx.controls.Button;
 use namespace mx_internal;
 
 public class ButtonPlus extends mx.controls.Button
 {
	public var onValue:Object=true;
	public var offValue:Object=false;
	private var _value:*;

	public function ButtonPlus() {
		super();
		/*addEventListener(Event.CHANGE,
			function(event:Event):void{
	 			if (listData) {
	  				data[DataGridListData(listData).dataField] = value;
	 			}
			}*/
		//);
	}
/*
  	public function set value(val:*) :void {
		_value = val;
		invalidateProperties();
  	}
	public function get value():Object  {
		if (_value==undefined)
		  return _value;
		else
		  return selected?onValue:offValue;
	}
	override protected function commitProperties():void {
		if (_value!=undefined)
			selected = (_value == onValue);
		super.commitProperties();
	}

	override public function set data(item:Object):void	{
		super.data = item;
		if( item!=null ) {
			value = item[DataGridListData(listData).dataField];
		}
	}

	 override protected function updateDisplayList(unscaledWidth:Number,unscaledHeight:Number):void
	{

		super.updateDisplayList(unscaledWidth, unscaledHeight);
		if (currentIcon) {
			var style:String = getStyle("textAlign");
			if ((!label) && (style=="center") ) {
				currentIcon.x = (unscaledWidth - currentIcon.measuredWidth)/2;
			}
			currentIcon.visible = (_value!=undefined);
		}
	}*/
 }
}