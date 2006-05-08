package au.com.BI.Nuvo;

import java.util.Vector;

import au.com.BI.Command.CommandInterface;

public class NuvoCommands {
		Vector <String>avOutputStrings;
		Vector <CommandInterface>avOutputFlash;
		
		boolean error = false;
		String errorDescription = "";
		
		int outputCommandType;
		int paramCommandType;
		
		public NuvoCommands() {
			avOutputStrings = new Vector<String>();
			avOutputFlash = new Vector<CommandInterface>();
		}
		
		public void addAvOutputString (String newItem){
			avOutputStrings.add(newItem);
		}
		
		public void addAvOutputString (CommandInterface newItem){
			avOutputFlash.add(newItem);
		}
}
