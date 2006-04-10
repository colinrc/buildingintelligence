/*
 * AcceptConfig.java
 *
 * Created on April 9, 2006, 10:42 PM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */
package au.com.BI.Config;

import java.io.*;
/**
 *
 * @author colin
 */
public class AcceptConfig implements FilenameFilter{
    String pattern;
    
    /** Creates a new instance of AcceptConfig */
    public AcceptConfig() {
    }

    public void setPattern(String pattern) {
	this.pattern = pattern;
    }


    public boolean accept (File dir,String name) {
	if (name.matches(pattern)) {
	    return true;
	} else {
	    return false;
	}
    }
}
