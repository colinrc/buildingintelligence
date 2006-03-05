package au.com.BI.Dynalite;
import java.util.LinkedList;
import java.util.List;

public class InterpretResult extends GeneralDynaliteResult {
	List decoded;
	String fullKey;
	
	public InterpretResult () {
		 decoded = new LinkedList ();
	}

	public String getFullKey() {
		return fullKey;
	}

	public void setFullKey(String fullKey) {
		this.fullKey = fullKey;
	}
}
