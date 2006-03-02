/*
 * Created on Jan 16, 2005
 * @Author Colin Canfield
 */
package au.com.BI.Flash;

import java.util.logging.*;
import java.util.regex.*;

public class BroadcastFormatter extends Formatter {

	public String format (LogRecord record) {
		//return "<?xml version=\"1.0\"?/>\r\n<LOG LEVEL=\"" + record.getLevel().getName() + "\" TIME=\"" +  record.getMillis() + " \" SRC=\"" + record.getSourceClassName() + "." + record.getSourceMethodName() + "\" MSG=\"" + record.getMessage() + "\" />\r\n";
		 try {
			String cleanMessage = record.getMessage().replaceAll("[^\\p{Print}]",".");
			cleanMessage = cleanMessage.replaceAll("<","&lt;");		
			cleanMessage = cleanMessage.replaceAll(">","&gt;");		
			cleanMessage = cleanMessage.replaceAll("'","&apos;");	
			String srcName = record.getSourceClassName();
			if (srcName == null) srcName = "";
			String methodName = record.getSourceMethodName();
			if (methodName == null) methodName = "";
			if (methodName.equals ("<init>")) methodName = "init";
			if (!cleanMessage.trim().equals("")) {
				String retString = "<MESSAGE ICON=\"warning\" TITLE=\"SEVERE ERROR\" CONTENT=\"" + cleanMessage+ "\" />";
				return retString + "\r\n";
			}
			else {
				return "";
			}
		} catch ( PatternSyntaxException ex) {
			return "";
		}
	}
	
	public String getHead (Handler h) {
		return "";
	}

	public String getTail (Handler h) {
		return "";
	}

}
