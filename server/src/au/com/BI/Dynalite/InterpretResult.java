package au.com.BI.Dynalite;
import java.util.LinkedList;
import java.util.List;

import au.com.BI.Command.CommandInterface;

public class InterpretResult extends GeneralDynaliteResult {
	List <CommandInterface> decoded;
	String fullKey;
	
	public InterpretResult () {
		 decoded = new LinkedList<CommandInterface> ();
	}

	public String getFullKey() {
		return fullKey;
	}

	public void setFullKey(String fullKey) {
		this.fullKey = fullKey;
	}
}
