/**
 * 
 */
package au.com.BI.Device;

/**
 * @author colin
 *
 */
public class ExtraAttribute {
	String name;
	boolean mandatory;
	
	public ExtraAttribute (String name, boolean mandatory ){
		this.setName (name);
		this.setMandatory(mandatory);
	}
	
	public String getName() {
		return name;
	}
	public void setName(String name) {
		this.name = name;
	}
	public boolean isMandatory() {
		return mandatory;
	}
	public void setMandatory(boolean mandatory) {
		this.mandatory = mandatory;
	}
}
