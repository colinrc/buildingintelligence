/*
 * Created on Apr 11, 2004
 *
 * To change the template for this generated file go to
 * Window - Preferences - Java - Code Generation - Code and Comments
 */
package au.com.BI.Comfort;
import java.util.*;
import java.util.logging.*;

/**
 * @author colinc
 *
 * To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Generation - Code and Comments
 */
public class ComfortString {
	protected String lastSplit = "";
	protected Logger logger;
		String comfortKey;
		String theParameter;
		String theParameter2;
		
		
		protected HashMap fourDigitKeys= null;
		protected HashMap fiveDigitKeys= null;
		protected HashMap lastHouseCode = null;
		
		public ComfortString (){
			logger = Logger.getLogger(this.getClass().getPackage().getName());
			
			fourDigitKeys = new HashMap (10);
			fiveDigitKeys = new HashMap (10);
			lastHouseCode = new HashMap (26);
			
			fourDigitKeys.put ("DB","");
			fourDigitKeys.put ("LU","");
			fourDigitKeys.put ("MD","");
			fourDigitKeys.put ("KD","");	
			fourDigitKeys.put ("IX","");	
			fourDigitKeys.put ("RA","");	
			fourDigitKeys.put ("NA","");	
			fourDigitKeys.put ("OK","");	
			fourDigitKeys.put ("a?","");	

			fiveDigitKeys.put ("XF","");	
			fiveDigitKeys.put ("XU","");	
		}
		/**
		 * @return Returns the comfortKey.
		 */
		public String getComfortKey() {
			return comfortKey;
		}
		/**
		 * @param comfortKey The comfortKey to set.
		 */
		public void setComfortKey(String comfortKey) {
			this.comfortKey = comfortKey;
		}
		/**
		 * @return Returns the theParameter.
		 */
		public String getTheParameter() {
			return theParameter;
		}
		/**
		 * @param theParameter The theParameter to set.
		 */
		public void setTheParameter(String theParameter) {
			this.theParameter = theParameter;
		}
		/**
		 * @return Returns the theParameter2.
		 */
		public String getTheParameter2() {
			return theParameter2;
		}
		/**
		 * @param theParameter2 The theParameter2 to set.
		 */
		public void setTheParameter2(String theParameter2) {
			this.theParameter2 = theParameter2;
		}
		
		public void setOutputKey (String outputKey){
			this.clear();
			this.comfortKey = outputKey;
		}
		
		public boolean splitString (String fullKey) {
			boolean commandParsed = false;


			if (fullKey.length() < 3) {
				lastSplit = "";
				return false;
			}
			if (fullKey.equals (lastSplit)) {
				return true;
			} else {
				lastSplit = fullKey;		
				try {
					String UCMCommand = fullKey.substring (1,3);
					if (fourDigitKeys.containsKey(UCMCommand)) {
						this.comfortKey = UCMCommand;
						if (fullKey.length() > 3)
							this.theParameter = fullKey.substring (3,5);
						if (fullKey.length() > 5)
							this.theParameter2 = fullKey.substring (5,7);
						commandParsed = true;
					}
					if (!commandParsed && fiveDigitKeys.containsKey(UCMCommand)) {
						if (UCMCommand.equals ("XU")){
							// X10 unit code strings keys are the entire string.
							// The key to be search will them be XUA02  H=house AB=unit
							this.comfortKey = fullKey.substring(1);  
							this.theParameter = fullKey.substring(3,6);  
						}
						if (UCMCommand.equals("XF")){
							// X10 controller codes come accross as two strings. The first carries the Unit code that must
							// be appended to the key.
							// The key to be search will them be XFHAB  H=house AB=parameter
							String houseCode = fullKey.substring (3,4);
							if (lastHouseCode.get(houseCode) != null) { 
								this.comfortKey = "XF" + houseCode + (String)lastHouseCode.get(houseCode) ;
								this.theParameter = fullKey.substring (4,6);
							}
							else
								this.comfortKey = "";
						}
						commandParsed = true;
					}
					if (!commandParsed) {
						this.comfortKey = fullKey.substring (1,5);
						if (fullKey.length() > 5) 
							this.theParameter = fullKey.substring(5,7);
						else
							this.theParameter = "";
					}
					return true;
				} catch (java.lang.IndexOutOfBoundsException ex){
					lastSplit = "";
					return false;
				}
			}
			
		}
		
		public void clear () {
			lastHouseCode.clear ();
			this.comfortKey = "";
			this.theParameter = "";
			this.theParameter2 = "";
			
			lastSplit = "";
		}
		
		public void setLastHouseCode () {
			lastHouseCode.put (theParameter.substring(0,1),theParameter.substring(1,3));

		}

}
