package au.com.BI.simulator.sims;
import java.util.*;
import au.com.BI.simulator.conf.*;

public class Helper {
	Config config;
	   // Connect status constants
	   public final static int NULL = 0;
	   public final static int DISCONNECTED = 1;
	   public final static int DISCONNECTING = 2;
	   public final static int BEGIN_CONNECT = 3;
	   public final static int CONNECTED = 4;
	   
	   // Other constants
	   public final static String statusMessages[] = {
	      " Error! Could not connect!", " Disconnected",
	      " Disconnecting...", " Waiting for connection...", " Connected"
	   };
	
	public Helper () {}
	
	   /////////////////////////////////////////////////////////////////

	public Config getConfig() {
		return config;
	}

	public void setConfig(Config config) {
		this.config = config;
	}
	
	  public String addCBUSChecksum(String sourceString) {
		  return sourceString + calcChecksum (sourceString);
	  }
	  
	protected String calcChecksum (String toCalc) {
		int total = 0;
		for (int i = 0; i < toCalc.length(); i+=2) {
			String nextPart = toCalc.substring(i,i+2);
			int val = Integer.parseInt(nextPart,16);
			total += val;
		}
		byte remainder = (byte)(total % 256);
		byte twosComp = (byte)-remainder;
		//byte twosComp = (byte)remainder;
		
		String hexCheck = Integer.toHexString(twosComp); 
		if (hexCheck.length() == 1) hexCheck = "0" + hexCheck;
		if (hexCheck.length() > 2) hexCheck = hexCheck.substring(hexCheck.length() - 2);
		return hexCheck;
	}

	

}
