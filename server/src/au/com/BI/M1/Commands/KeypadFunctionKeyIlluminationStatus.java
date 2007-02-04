package au.com.BI.M1.Commands;

import au.com.BI.Util.Type;

public class KeypadFunctionKeyIlluminationStatus extends Type {

	public static final KeypadFunctionKeyIlluminationStatus OFF = new KeypadFunctionKeyIlluminationStatus("0","Off");
	public static final KeypadFunctionKeyIlluminationStatus ON_CONSTANT = new KeypadFunctionKeyIlluminationStatus("1","On Constant");
	public static final KeypadFunctionKeyIlluminationStatus ON_BLINKING = new KeypadFunctionKeyIlluminationStatus("2","On Blinking");
	
	private KeypadFunctionKeyIlluminationStatus(String value, String desc) {
		super(value, desc);
	}
	
	public static KeypadFunctionKeyIlluminationStatus getByValue(String value) {
		return((KeypadFunctionKeyIlluminationStatus)KeypadFunctionKeyIlluminationStatus.getByValue(KeypadFunctionKeyIlluminationStatus.class,value));
	}
}
