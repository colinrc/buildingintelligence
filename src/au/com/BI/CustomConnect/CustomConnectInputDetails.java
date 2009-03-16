/**
 * 
 */
package au.com.BI.CustomConnect;

import java.util.regex.Pattern;
import java.util.regex.Matcher;
/**
 * @author colin
 *
 */
public class CustomConnectInputDetails {
	public String command  ="";
	public String extra = "";
	public String extra2 = "";
	public String extra3 = "";
	public String extra4 = "";
	public String extra5 = "";
	public String toMatch = "";
	public String key = "";
	protected Pattern p;
	public String name = "";
	
	public CustomConnectInputDetails (String toMatch, String key, String name, String command, String extra, String extra2, String extra3, String extra4, String extra5){
		this.setKey(key);
		this.setToMatch(toMatch);
		this.setCommand(command);
		this.setExtra(extra);
		this.setExtra2(extra2);
		this.setExtra3(extra3);
		this.setExtra4(extra4);
		this.setExtra5(extra5);
	}
	
	public CustomConnectInputDetails () {
		p = Pattern.compile ("");
	}
	
	public String getCommand() {
		return command;
	}
	
	public void setCommand(String command) {
		this.command = command;
	}
	
	public String getExtra() {
		return extra;
	}
	
	public void setExtra(String extra) {
		this.extra = extra;
	}
	
	public String getExtra2() {
		return extra2;
	}
	
	public void setExtra2(String extra2) {
		this.extra2 = extra2;
	}
	
	public String getExtra3() {
		return extra3;
	}
	
	public void setExtra3(String extra3) {
		this.extra3 = extra3;
	}
	
	public String getExtra4() {
		return extra4;
	}
	
	public void setExtra4(String extra4) {
		this.extra4 = extra4;
	}
	
	public String getExtra5() {
		return extra5;
	}
	
	public void setExtra5(String extra5) {
		this.extra5 = extra5;
	}
	
	public String getKey() {
		return key;
	}
	
	public void setKey(String key) {
		this.key = key;
	}
	
	public String getToMatch() {
		return toMatch;
	}
	
	public void setToMatch(String toMatch) {
		this.toMatch = toMatch;
		p = Pattern.compile(toMatch);
	}
	

	public Matcher getMatcher (String stringToCompare) {
	        return p.matcher (stringToCompare);
		}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}


}
