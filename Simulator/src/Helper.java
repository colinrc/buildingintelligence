import java.util.*;
import java.io.*;

public class Helper {
	Properties properties;
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

	   public String getPropValue(String name) {
		    String result = properties.getProperty(name);
			if (result == null) result = "";
			return result;
	   }

	public Properties getProperties() {
		return properties;
	}

	public void setProperties(Properties properties) {
		this.properties = properties;
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
