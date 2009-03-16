package au.com.BI.GroovyModels;
import java.util.*;

public class GroovyRunBlock {
	protected boolean enabled = true;
	protected Date lastUpdated = null;
	protected String fileName = null;
	protected Class theClass = null;
	
	public GroovyRunBlock () {
		lastUpdated = new Date();
	}
	

	public boolean isEnabled() {
		return enabled;
	}

	public void setEnabled(boolean enabled) {
		this.enabled = enabled;
	}


	public Date getLastUpdated() {
		return lastUpdated;
	}

	public void setLastUpdated(Date lastUpdated) {
		this.lastUpdated = lastUpdated;
	}

	public String getFileName() {
		return fileName;
	}


	public void setFileName(String fileName) {
		this.fileName = fileName;
	}


	public Class getTheClass() {
		return theClass;
	}


	public void setTheClass(Class theClass) {
		this.theClass = theClass;
	}
	
}
