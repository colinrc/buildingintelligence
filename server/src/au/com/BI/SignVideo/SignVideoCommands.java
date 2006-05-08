package au.com.BI.SignVideo;

import java.util.Vector;

import au.com.BI.Command.CommandInterface;

public class SignVideoCommands {
		Vector <String>avOutputStrings;
		Vector <CommandInterface>avOutputFlash;
		
		boolean error = false;
		String errorDescription = "";
		
		int outputCommandType;
		int paramCommandType;
		
		public SignVideoCommands() {
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
