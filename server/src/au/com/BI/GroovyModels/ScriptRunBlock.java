package au.com.BI.GroovyModels;
import java.util.*;
import au.com.BI.Util.DeviceModel.ModelTypes;

public class ScriptRunBlock {
	boolean enabled = true;
	public String statusString = "";
	public boolean stoppable = false;
	public Date lastUpdated = null;
	public String name = "";
	public ModelTypes modelType = ModelTypes.GroovySource; 
	
	public ScriptRunBlock () {
		lastUpdated = new Date();
	}
	
	
	public boolean isEnabled() {
		return enabled;
	}

	public void setEnabled(boolean enabled) {
		this.enabled = enabled;
	}

	public String getStatusString() {
		return statusString;
	}

	public void setStatusString(String statusString) {
		this.statusString = statusString;
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
	

	public ModelTypes getModelType() {
		return modelType;
	}

	public void setModelType(ModelTypes modelType) {
		this.modelType = modelType;
	}

}
