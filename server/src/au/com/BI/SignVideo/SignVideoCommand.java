package au.com.BI.SignVideo;

import java.util.Vector;

import au.com.BI.Command.CommandInterface;

public class SignVideoCommand {
		Vector <byte[]>avOutputBytes;
		Vector <String>avOutputStrings;
		Vector <CommandInterface>avOutputFlash;
		
		boolean error = false;
		String errorDescription = "";
		
		int outputCommandType;
		int paramCommandType;
		
		public SignVideoCommand() {
			avOutputBytes = new Vector<byte[]>();
			avOutputStrings = new Vector<String>();
			avOutputFlash = new Vector<CommandInterface>();
		}
		
		public void addAvOutputBytes (byte[] newItem){
			avOutputBytes.add(newItem);
		}
		
		public void addAvOutputString (String newItem){
			avOutputStrings.add(newItem);
		}
		
		public void addAvOutputString (CommandInterface newItem){
			avOutputFlash.add(newItem);
		}
}
