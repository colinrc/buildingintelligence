package au.com.BI.Nuvo;

import java.util.Vector;

public class NuvoCommands {
		Vector <String>avOutputStrings;
		
		boolean error = false;
		String errorDescription = "";
		
		int outputCommandType;
		int paramCommandType;
		
		public NuvoCommands() {
			avOutputStrings = new Vector<String>();
		}
		
		public void addAvOutputString (String newItem){
			avOutputStrings.add(newItem);
		}
		
}
