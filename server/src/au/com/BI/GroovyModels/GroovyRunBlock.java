package au.com.BI.GroovyModels;
import java.util.*;

public class GroovyRunBlock {
	boolean enabled = true;
	public Date lastUpdated = null;
	public String name = "";
	
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

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
	



}
