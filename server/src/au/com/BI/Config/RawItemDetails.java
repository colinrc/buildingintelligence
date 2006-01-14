/*
 * Created on Apr 3, 2004
 *
 * To change the template for this generated file go to
 * Window - Preferences - Java - Code Generation - Code and Comments
 */
package au.com.BI.Config;
import java.util.*;
import au.com.BI.Command.*;

/**
 * @author colinc
 *
 * To change the template for this generated type comment go to
 * Window - Preferences - Java - Code Generation - Code and Comments
 */
public class RawItemDetails {
	protected String catalogue;
	protected String code;
	protected HashMap variableMap;
	
	/**
	 * Used to encapsulate raw details specified against a device.
	 */
	public RawItemDetails(String catalogue, String code, HashMap variableMap) {
		this.catalogue = catalogue;
		this.code = code;
		if (variableMap == null)
			this.variableMap = new HashMap(5);
		else
			this.variableMap = variableMap;
	}
	/**
	 * @return Returns the catalogue.
	 */
	public String getCatalogue() {
		return catalogue;
	}
	/**
	 * @param catalogue The catalogue to set.
	 */
	public void setCatalogue(String catalogue) {
		this.catalogue = catalogue;
	}
	/**
	 * @return Returns the code.
	 */
	public String getCode() {
		return code;
	}
	/**
	 * @param code The code to set.
	 */
	public void setCode(String code) {
		this.code = code;
	}
	/**
	 * @return Returns the variableMap.
	 */
	public HashMap getVariableMap() {
		return variableMap;
	}
	/**
	 * @param variableMap The variableMap to set.
	 */
	public void setVariableMap(HashMap variableMap) {
		this.variableMap = variableMap;
	}
	
	/**
	 * Fills in any variables specified in the config file into the catalogue value.
	 * @param catalogueValue The source to fill in.
	 * @return
	 */
	public String populateVariables (String catalogueValue, CommandInterface command) {
		if (catalogueValue == null) return null;
		if (catalogueValue.equals ("")) return "";
		Iterator vars = variableMap.keySet().iterator();
		catalogueValue = catalogueValue.replaceAll("%EXTRA%", command.getExtraInfo());
		while (vars.hasNext()) {
			String varName = (String)vars.next();
			String varValue = (String)variableMap.get(varName);
			catalogueValue = catalogueValue.replaceAll("%" + varName + "%", varValue);
		}
		return catalogueValue;
	}

}
