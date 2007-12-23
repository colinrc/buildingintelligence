package Utils
{
	import flash.events.MouseEvent;
	
	import mx.controls.CheckBox;

  

	[Bindable("YNCheckBox")]
	public class YNCheckBox extends CheckBox
	{
		[Bindable]
		public var result:String;
		private var dataObj:Object;
		public function YNCheckBox()
		{
			super();
			callLater(fixResult);
			
		}
		private function fixResult():void {
			
				if (result=="Y") {
					this.selected = true;
				} else {
					this.selected = false;
				}
			
		}
		override protected function clickHandler(event:MouseEvent):void
        {
          	
            //data[DataGridListData(listData).dataField] = selected;
            if (this.selected == true) {
				result ="N";
			} else {
				result ="Y";
			}
			super.clickHandler(event);
        }
	}
}