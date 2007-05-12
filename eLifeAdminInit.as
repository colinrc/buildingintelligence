// Initialize 
		public function systemSettings():void {
				
			loader.setURLandLoad("data/elifeAdmin.xml");	
		    loader.addEventListener("onInit", loadComplete);
		 
		}
		public function loadComplete(event:Event):void {
			eLifeAdmin_xml = loader.data;
			loader.removeEventListener("onInit", loadComplete);
			vDivBoxWidth = eLifeAdmin_xml.settings.@vDivBoxWidth;
			
		    
		}