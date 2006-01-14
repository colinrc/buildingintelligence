/*
 * Created on Jan 16, 2005
 * @Author Colin Canfield
 */
package au.com.BI.Admin;

import java.util.logging.*;

public class BIFormatter extends Formatter {

	public String format (LogRecord record) {
		//return "<?xml version=\"1.0\"?/>\r\n<LOG LEVEL=\"" + record.getLevel().getName() + "\" TIME=\"" +  record.getMillis() + " \" SRC=\"" + record.getSourceClassName() + "." + record.getSourceMethodName() + "\" MSG=\"" + record.getMessage() + "\" />\r\n";
		String cleanMessage = record.getMessage().replaceAll("[^\\p{Print}]",".");
		cleanMessage = cleanMessage.replaceAll("<","&lt;");		
		cleanMessage = cleanMessage.replaceAll(">","&gt;");		
		cleanMessage = cleanMessage.replaceAll("'","&apos;");
		String srcName = record.getSourceClassName();
		if (srcName == null) srcName = "";
		String methodName = record.getSourceMethodName();
		if (methodName == null) methodName = "";
		if (methodName.equals ("<init>")) methodName = "init";
		String retString = "<LOG LEVEL=\"" + record.getLevel().getName() + "\" TIME=\"" +  record.getMillis() + "\" SRC=\"" + srcName + "." + methodName + "\" MSG='" + cleanMessage+ "' />";
		return retString + "\r\n";
	}
	
	public String getHead (Handler h) {
		return "";
	}

	public String getTail (Handler h) {
		return "";
	}

}
