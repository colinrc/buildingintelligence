// Initialize 
		public function systemSettings():void {
				
			loader.setURLandLoad	
		    loader.addEventListener("onInit", loadComplete);
		 
		}
		public function loadComplete(event:Event):void {
			eLifeAdmin_xml = ("data/elifeAdmin.xml");
			vDivBoxWidth = eLifeAdmin_xml.settings.@vDivBoxWidth;
			
		    
		}