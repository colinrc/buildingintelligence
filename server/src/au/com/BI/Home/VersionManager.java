/**
 * 
 */
package au.com.BI.Home;

import java.util.HashMap;

/**
 * @author colin
 *
 */
public class VersionManager {
	String masterVersion = "";
	HashMap <String,String>modelVersions;
	
	public VersionManager() {
		modelVersions = new HashMap <String,String>();
	}

	public String getMasterVersion() {
		return masterVersion;
	}

	public void setMasterVersion(String masterVersion) {
		this.masterVersion = masterVersion;
	}
	
	public void setVersion (String modelName, String version) {
		modelVersions.put(modelName, version);
	}
	
	public String getVersion (String modelName) {
		if (modelVersions.containsKey(modelName)){
			return modelVersions.get(modelName);
		} else {
			return "";
		}
	}
	
	
}
