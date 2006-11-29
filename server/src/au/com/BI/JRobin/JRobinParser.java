package au.com.BI.JRobin;

import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jdom.Element;

import au.com.BI.Config.Config;
import au.com.BI.Config.ConfigError;

public class JRobinParser {
	Logger logger;
    protected HashMap <String, JRobinData>jRobinRRDS;
	protected boolean JRobinActive = false;
    protected HashMap <String, Object>powerRating;
	
	public JRobinParser () {
		jRobinRRDS = new HashMap <String, JRobinData>(40);
        powerRating = new HashMap <String,Object>(20);
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}
	
	public void clearRRDS() {
		synchronized (jRobinRRDS) {
			jRobinRRDS.clear();
		}
	}
	

    public void addPowerRating(String displayName, double rating) {
            if (powerRating.containsKey(displayName)) {
                   powerRating.remove(displayName);
                   powerRating.put(displayName, Double.toString(rating));
                   return;
            }
            powerRating.put(displayName, new Double(rating));
    }

	
	public void parseJRobinConfig(Config config, Element jRobinConfig) throws ConfigError {
	        String active = jRobinConfig.getAttributeValue("ACTIVE");
	        if (active == null || !active.equals("N")) {
				setJRobinActive(true);
	                String interval = jRobinConfig.getAttributeValue(
	                    "INTERVAL");
	                long intervalLong;
	                String rrd = jRobinConfig.getAttributeValue("RRD");
	
	                try {
	                        intervalLong = Long.parseLong(interval);
	                }
	                catch (NumberFormatException ex) {
	                        intervalLong = 60;
	                }
	
	                if (rrd == null || rrd.equals("")) {
	                        throw new ConfigError(
	                            "Illegal empty JROBIN RRD name definition");
	                }
	
	                JRobinData jRobinData = new JRobinData(intervalLong,
	                    rrd);
	
	                synchronized (jRobinRRDS) {
	                        //process only the data_all items
	                        List dataAllItemList = jRobinConfig.getChildren("DATA_ALL");
	                        Iterator dataItems = dataAllItemList.iterator();
	
	                        while (dataItems.hasNext()) {
	                                Element dataItem = (Element) dataItems.next();
	
	                                String displayName = dataItem.getAttributeValue("DISPLAY_NAME");
	                                if (displayName == null ||
	                                    displayName.equals("")) {
	                                        displayName = "";
	                                }
	
	                                String variableName = dataItem.
	                                    getAttributeValue("VARIABLE");
	                                if (variableName == null ||
	                                    variableName.equals("")) {
	                                        throw new ConfigError(
	                                            "Illegal empty VARIABLE for JROBIN DATA definition");
	                                }
	
	                                String function = dataItem.getAttributeValue("FUNCTION");
	                                if (function == null || function.equals("")) {
	                                        throw new ConfigError(
	                                            "Illegal empty FUNCTION for JROBIN DATA definition");
	                                }
	
	                                String searchValue = dataItem.getAttributeValue("SEARCH_VALUE");
	                                if (searchValue == null ||
	                                    searchValue.equals("")) {
	                                        searchValue = "";
	                                }
	
	                                String source = dataItem.getAttributeValue("SOURCE");
	                                if (source == null || source.equals("")) {
	                                        source = "";
	                                }
	
	                                jRobinData.addDataItem(displayName,
	                                                       variableName, source, searchValue,
	                                                       function, getPowerRating(displayName));
	                        }
	
	                        //now process only the data items
	                        List dataItemList = jRobinConfig.getChildren("DATA");
	
	                        if (dataItemList.size() > 0) {
	                                if (dataAllItemList.size() > 0) {
	                                        throw new ConfigError(
	                                            "Illegal use of JROBIN DATA definition when using DATA_ALL");
	                                }
	                        }
	
	                        dataItems = dataItemList.iterator();
	                        while (dataItems.hasNext()) {
	                                Element dataItem = (Element) dataItems.next();
	                                String dataSource = dataItem.getAttributeValue("DATASOURCE");
	
	                                if (dataSource == null || dataSource.equals("")) {
	                                        throw new ConfigError(
	                                            "Illegal empty DATASOURCE for JROBIN DATA definition");
	                                }
	
	                                String displayName = dataItem.getAttributeValue("DISPLAY_NAME");
	                                if (displayName == null || displayName.equals("")) {
	                                        displayName = "";
	                                }
	
	                                String variableName = dataItem.getAttributeValue("VARIABLE");
	                                if (variableName == null || variableName.equals("")) {
	                                        throw new ConfigError(
	                                            "Illegal empty VARIABLE for JROBIN DATA definition");
	                                }
	
	                                String function = dataItem.getAttributeValue("FUNCTION");
	                                if (function == null || function.equals("")) {
	                                        throw new ConfigError(
	                                            "Illegal empty FUNCTION for JROBIN DATA definition");
	                                }
	
	                                String searchValue = dataItem.getAttributeValue("SEARCH_VALUE");
	                                if (searchValue == null || searchValue.equals("")) {
	                                        searchValue = "";
	                                }
	
	                                String source = dataItem.getAttributeValue("SOURCE");
	                                if (source == null || source.equals("")) {
	                                        source = "";
	                                }
	
	                                jRobinData.addDataItem(dataSource, displayName, variableName,
	                                                       source, searchValue, function, getPowerRating(displayName));
	                        }
	
	                        //now process only the dataPowerConsumption items
	                        List dataItemPowerList = jRobinConfig.getChildren(
	                            "DATA_POWER_CONSUMPTION");
	                        if (dataItemPowerList.size() > 0) {
	                                if (dataAllItemList.size() > 0) {
	                                        throw new ConfigError(
	                                            "Illegal use of JROBIN DATA_POWER_CONSUMPTION definition when using DATA_ALL");
	                                }
	                        }
	
	                        dataItems = dataItemPowerList.iterator();
	                        int intRatio;
	                        while (dataItems.hasNext()) {
	                                Element dataItem = (Element) dataItems.
	                                    next();
	                                String dataSource = dataItem.getAttributeValue("DATASOURCE");
	
	                                if (dataSource == null || dataSource.equals("")) {
	                                        throw new ConfigError(
	                                            "Illegal empty DATASOURCE for JROBIN DATA_POWER_CONSUMPTION definition");
	                                }
	
	                                String displayName = dataItem.getAttributeValue("DISPLAY_NAME");
	                                if (displayName == null || displayName.equals("")) {
	                                        throw new ConfigError(
	                                            "Illegal empty DISPLAY_NAME for JROBIN DATA_POWER_CONSUMPTION definition");
	                                }
	
	                                String variableName = dataItem.
	                                    getAttributeValue("VARIABLE");
	                                if (variableName == null || variableName.equals("")) {
	                                        throw new ConfigError(
	                                            "Illegal empty VARIABLE for JROBIN DATA_POWER_CONSUMPTION definition");
	                                }
	
	                                String source = dataItem.getAttributeValue("SOURCE");
	                                if (source == null || source.equals("")) {
	                                        throw new ConfigError(
	                                            "Illegal empty SOURCE for JROBIN DATA_POWER_CONSUMPTION definition");
	                                }
	
	                                String ratio = dataItem.getAttributeValue("RATIO");
	                                if (ratio == null || ratio.equals("")) {
	                                        throw new ConfigError(
	                                            "Illegal empty RATIO for JROBIN DATA_POWER_CONSUMPTION definition");
	                                }
	
	                                try {
	                                        intRatio = Integer.parseInt(ratio);
	                                }
	                                catch (NumberFormatException ex) {
	                                        intRatio = 1; //default ratio so numbers wont change.
	                                }
	
	                                jRobinData.addDataItem(dataSource, displayName, variableName,
	                                                       source, intRatio, getPowerRating(displayName));
	                        }
	
	
	                        jRobinRRDS.put(rrd, jRobinData);
	                        logger.log(Level.FINE,
	                                   "Config RRD " + rrd + " added to data object");
	                }
	       }
	}

	public void setJRobinActive(boolean robinActive) {
		this.JRobinActive = robinActive;
	}

	/**
	 * @param config TODO
	 * @param robinDataSources The jRobinDataSources to set.
	 */
	public void setJRobinDataSources( HashMap robinDataSources) {
		this.jRobinRRDS = robinDataSources;
	}

	/**
	 * @param config TODO
	 * @return Returns the jRobinRRDs.
	 */
	public HashMap getJRobinRRDs() {
		return jRobinRRDS;
	}

	public boolean isJRobinActive() {
		return JRobinActive;
	}

	double getPowerRating( String key) {
	        Double rating;
	        String sRating;
	
	        synchronized (powerRating) {
	                if (powerRating.containsKey(key) == true) {
	                         rating =  (Double)powerRating.get(key);
	                         sRating = rating.toString();
	                         return Double.parseDouble(sRating);
	                }
	        }
	        return 0;
	}

}
