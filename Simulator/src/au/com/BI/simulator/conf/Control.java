package au.com.BI.simulator.conf;

import au.com.BI.simulator.util.Utility;
import java.util.logging.*;
import java.util.*;

public class Control {
	   public static enum DisplayTypes {UNKNOWN,BUTTONS,SLIDER,CONTROLS,SLIDER_RAW,BUTTONS_RAW,NONE}

	   public static enum SimTypes {ALL,UNKNOWN,CBUS,RAW,COMFORT,GC100,M1}
	   public static enum SimSubTypes {UNKNOWN, INPUT,OUTPUT,COUNTER,CONTROLS,TEMP}
	   
	   
	   private SimTypes simType = SimTypes.UNKNOWN;
	   private SimSubTypes simSubType = SimSubTypes.UNKNOWN;
	   
	   public static enum ControlStates { OFF,ON,CUSTOM}
  
	   private String key;
	   private String keyOn;
	   private String keyOff;
	   private String selectList = "";
	   private String title;
	   private boolean updatingSlider = false;
	   private DisplayTypes displayType = DisplayTypes.BUTTONS;

	   protected Vector controlTitles = null;
	   protected Vector controlCommands = null;
	   protected Vector controlObjects = null;
		public Logger logger;
		protected LinkedHashMap <String,String>controlKeyPairs;
		
	   public Control () {
			logger = Logger.getLogger(this.getClass().getPackage().getName());
		   
		   controlCommands = new Vector (10);
		   controlTitles = new Vector (10);
		   controlObjects = new Vector(10);
		   controlKeyPairs = new LinkedHashMap <String,String>();

	   }

	   public Control(String groupType,String subGroupType) {
		  this.setGroupType (groupType,subGroupType);  
	   }
	   

	   public void  addControlKeyPair (String value, String label){
		   controlKeyPairs.put(value, label);
	   }
	   
	   public Map<String,String> getControlKeyPairs (){
		   return controlKeyPairs;
	   }
	   
	   public void setGroupType(String typeStr,String subTypeStr) {
		   this.setSimType(typeStr);
		   if (subTypeStr != null) this.setSimSubType(subTypeStr);
	   }
	   	   
	   public SimTypes getSimType () {
		   return simType;
	   }
	   
	   public void  setSimType (SimTypes simType) {
		   this.simType = simType;
	   }
	   

		public void setSimType(String simTypeStr) {
			try {
				this.simType = SimTypes.valueOf(simTypeStr);
			} catch (IllegalArgumentException ex) {
				logger.log (Level.WARNING,"An illegal simulator type was specified for the control " + title + " : " + simTypeStr);
				setSimType(SimTypes.UNKNOWN);
			} catch (NullPointerException ex){
				logger.log (Level.WARNING,"A simulator type was not specified for the control " + title);
				setSimType(SimTypes.UNKNOWN);
			}
		}
		
	   public SimSubTypes getSimSubType () {
		   return simSubType;
	   }
	   
	   public void  setSimSubType (SimSubTypes simSubType) {
		   this.simSubType = simSubType;
	   }
	   

		public void setSimSubType(String simSubType) {
			try {
				this.simSubType = SimSubTypes.valueOf(simSubType);
			} catch (IllegalArgumentException ex) {
				logger.log (Level.WARNING,"An illegal simulator sub-type was specified " + title +" : " + simSubType);
				setSimSubType(SimSubTypes.UNKNOWN);
			} 
		}


	public boolean isHasSlider() {
		if (getDisplayType() == DisplayTypes.SLIDER || getDisplayType() == DisplayTypes.SLIDER_RAW)
			return true;
		else 
			return false;
	}

	public String getKey() {
		return key;
	}

	public void setKey(String key) {
		this.key = key;
	}

	public String getKeyOff() {
		return keyOff;
	}

	public void setKeyOff(String offString) {
		this.keyOff = Utility.parseString(offString);
	}

	public String getKeyOn() {
		return keyOn;
	}

	public void setKeyOn(String onString) {
		this.keyOn = Utility.parseString(onString);
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}


	public boolean isUpdatingSlider() {
		return updatingSlider;
	}

	public void setUpdatingSlider(boolean updatingSlider) {
		this.updatingSlider = updatingSlider;
	}

	public String getSelectList() {
		return selectList;
	}

	public void setSelectList(String selectList) {
		this.selectList = selectList;
	}

	public DisplayTypes getDisplayType() {
		return displayType;
	}

	public void setDisplayType(DisplayTypes displayType) {
		this.displayType = displayType;
	}
	
	public void setDisplayType(String displayType) {
		try {
			this.displayType = DisplayTypes.valueOf(displayType);
		} catch (IllegalArgumentException ex) {
			logger.log (Level.WARNING,"An illegal display type was specified " + displayType);
			setDisplayType(DisplayTypes.UNKNOWN);
		} catch (NullPointerException ex){
			logger.log (Level.WARNING,"A display type was not specified for the control");
			setDisplayType(DisplayTypes.UNKNOWN);
		}
	}
	
	public boolean isControls() {
		if (getDisplayType() == DisplayTypes.CONTROLS)
			return true;
		else 
			return false;	
	}
	
   }