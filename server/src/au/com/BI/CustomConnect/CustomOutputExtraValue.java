/**
 * 
 */
package au.com.BI.CustomConnect;

/**
 * @author colin
 *
 */
public class CustomOutputExtraValue {
	String configValue = "";
	String name = "";
	
	public CustomOutputExtraValue (String configValue, String name){
		this.configValue = configValue;
		this.name = name;
	}
	
	public String getConfigValue() {
		return configValue;
	}
	public void setConfigValue(String configValue) {
		this.configValue = configValue;
	}
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
}