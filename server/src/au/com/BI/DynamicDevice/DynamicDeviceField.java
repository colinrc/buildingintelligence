/**
 * 
 */
package au.com.BI.DynamicDevice;

/**
 * @author colin
 *
 */
public class DynamicDeviceField {
	enum FieldType {STRING,INT};
	
	String key = "";
	boolean mandatory = false;
	FieldType fieldType = FieldType.STRING;
	int min = Integer.MIN_VALUE;
	int max =Integer.MAX_VALUE;
	String strVal = "";
	int intVal = 0;
	String defaultVal = "";
	int defaultIntVersion = 0;
	
	public DynamicDeviceField () {
		
	}
	
	public DynamicDeviceField (String key, String defaultVal, boolean mandatory) {
		this.fieldType = FieldType.STRING;
		this.defaultVal = defaultVal;
		this.mandatory = mandatory;
	}
	
	public DynamicDeviceField (String key, int defaultVal, boolean mandatory) {
		this.fieldType = FieldType.INT;
		this.defaultIntVersion = defaultVal;
		this.mandatory = mandatory;
	}
	
	public DynamicDeviceField (String key, int defaultVal, int minVal, int maxVal, boolean mandatory) {
		this.fieldType = FieldType.INT;
		this.defaultIntVersion = defaultVal;
		this.min = minVal;
		this.max = maxVal;
		this.mandatory = mandatory;
	}
	
	public String getKey() {
		return key;
	}
	public void setKey(String key) {
		this.key = key;
	}
	public boolean isMandatory() {
		return mandatory;
	}
	public void setMandatory(boolean mandatory) {
		this.mandatory = mandatory;
	}
	public int getMax() {
		return max;
	}
	public void setMax(int max) {
		this.max = max;
	}
	public int getMin() {
		return min;
	}
	public void setMin(int min) {
		this.min = min;
	}

	public FieldType getFieldType() {
		return fieldType;
	}

	public void setFieldType(FieldType fieldType) {
		this.fieldType = fieldType;
	}
}
