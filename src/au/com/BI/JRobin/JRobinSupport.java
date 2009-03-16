/*
 * JRobinSupport.java
 *
 * Created on November 30, 2006, 9:44 AM
 *
 * To change this template, choose Tools | Template Manager
 * and open the template in the editor.
 */

package au.com.BI.JRobin;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collection;
import java.util.HashMap;
import java.util.Iterator;
import java.util.logging.Level;
import java.util.logging.Logger;

import org.jrobin.core.RrdDb;
import org.jrobin.core.RrdDbPool;
import org.jrobin.core.RrdException;
import org.jrobin.core.Sample;

import au.com.BI.Command.Cache;
import au.com.BI.Config.Bootstrap;
import au.com.BI.Home.Controller;

/**
 *
 * @author colin
 */
public class JRobinSupport {
	public HashMap<String, Object> variableCache;
	protected Logger logger;
	protected HashMap jRobinRRDS;

	protected static String RRDBDIRECTORY = ".\\JRobin\\";

	protected static String RRDXMLDIRECTORY = ".\\JRobin\\RRDDefinition\\";

	protected String RRDGRAPH = ".\\JRobin\\Graph\\"; // Default value for testing

	protected static org.jrobin.core.RrdDbPool rrdbPool;

	public  au.com.BI.JRobin.RRDGraph rrdGraph;
	
	/** Creates a new instance of JRobinSupport */
	public JRobinSupport() {
		variableCache = new HashMap<String, Object>(20);
		jRobinRRDS = new HashMap();
		logger = Logger.getLogger(this.getClass().getPackage().getName());
	}

	public void clearVariables(ArrayList variables) {
		Iterator eachVariable = variables.iterator();
		synchronized (variableCache) {
			while (eachVariable.hasNext()) {
				String variable = (String) eachVariable.next();
				variableCache.remove(variable);
			}
		}

	}

	/**
	 * @return Returns the value stored in variable.
	 * @param key The key to get the value for.
	 */
	public String getVariable(String key) {
		if (variableCache.containsKey(key) == true) {
			return (String) variableCache.get(key);
		}
		return "None";
	}

	/**
	 * @return Returns the value stored in variable.
	 * @param key The key to get the value for.
	 */
	public Long getLongVariable(String key) {
		if (variableCache.containsKey(key) == true) {
			return (Long) variableCache.get(key);
		}
		return null;
	}

	/**
	 * @return Returns the value stored in variable.
	 * @param key The key to get the value for.
	 */
	public Double getDoubleVariable(String key) {
		if (variableCache.containsKey(key) == true) {
			return (Double) variableCache.get(key);
		}
		return null;
	}

	/**
	 * Set the varaible Key,Value
	 * @param key The key to store the value for.
	 * @param @value The value to store.
	 */
	public void setVariable(String key, String value) {
		synchronized (variableCache) {
			if (variableCache.containsKey(key) == true) {
				variableCache.remove(key);
				variableCache.put(key, value);
				return;
			}
			variableCache.put(key, value);
		}
		return;
	}

	/**
	 * Set the varaible Key,Value where value is a long, but stored as a string.
	 * @param key The key to store the value for.
	 * @param @value The value to store as a long.
	 */
	public void setLongVariable(String key, long value) {
		synchronized (variableCache) {
			if (variableCache.containsKey(key) == true) {
				variableCache.remove(key);
				variableCache.put(key, new Long(value));
				return;
			}
			variableCache.put(key, new Long(value));
		}
		return;
	}

	/**
	 * Set the varaible Key,Value where value is a double, but stored as a string.
	 * @param key The key to store the value for.
	 * @param @value The value to store as a double.
	 */
	public void setVariable(String key, double value) {
		synchronized (variableCache) {
			if (variableCache.containsKey(key) == true) {
				variableCache.remove(key);
				variableCache.put(key, new Double(value));
				return;
			}
			variableCache.put(key, new Double(value));
		}
		return;
	}

	/**
	 * Increment the variable Value
	 * @param key The key to store the value for.
	 */
	public void incrementVariable(String key) {
		Double value;
		double numValue;
		Double num;
		synchronized (variableCache) {
			if (variableCache.containsKey(key) == true) {
				value = (Double) variableCache.get(key);
				numValue = value.doubleValue();
				numValue = numValue + 1d;
				value = new Double(numValue);
				variableCache.remove(key);
				variableCache.put(key, value);
				return;
			}

			variableCache.put(key, new Double(1d));
			return;
		}
	}

	/**
	 * Decrement the variable Value
	 * @param key The key to store the value for.
	 */
	public void decrementVariable(String key) {
		Double value;
		double numValue;
		Double num;
		synchronized (variableCache) {
			if (variableCache.containsKey(key) == true) {
				value = (Double) variableCache.get(key);
				numValue = value.doubleValue();
				numValue = numValue - 1d;
				value = new Double(numValue);
				variableCache.remove(key);
				variableCache.put(key, value);
				return;
			}

			variableCache.put(key, new Double(-1d));
			return;
		}
	}

	public ArrayList getRRDDataSources(String rrdKey) {
		RrdDb myRrd = null;
		String[] dataSources;
		ArrayList list;

		try {
			myRrd = useRrd(RRDBDIRECTORY + rrdKey + ".rrd");
			dataSources = myRrd.getDsNames();
			releaseRrd(myRrd);
			list = new ArrayList(Arrays.asList(dataSources));
			return list;
		}

		catch (IOException e) {
			logger.log(Level.SEVERE, "IO Exception error " + e.getMessage()
					+ e.toString());
		} catch (RrdException e) {
			logger.log(Level.SEVERE, "RRD Exception error " + e.getMessage()
					+ e.toString());
		} finally {
			try {
				releaseRrd(myRrd);
			} catch (IOException e) {
				logger.log(Level.SEVERE, "IO Exception error " + e.getMessage()
						+ e.toString());
			} catch (RrdException e) {
				logger.log(Level.SEVERE, "RRD Exception error "
						+ e.getMessage() + e.toString());
			}
		}
		return null;
	}

	/**
	 * @param rrdKey The rrd key name. Just the name with no dir or extensions.
	 * @param rrdTime The timestamp of this sample. Time ia a (long) in secs since 1/1/1970 UTC
	 * @param rrdDSName The DataSource name to update.
	 * @param rrdValue The value you want to store.
	 * This method is overloaded to provide flexability in use. It will call the appropriate sample methods and update the rrd.
	 */
	public void rrdUpdate(String rrdKey, long rrdTime, String rrdDSName,
			double rrdValue) {
		RrdDb myRrd = null;
		try {
			myRrd = useRrd(RRDBDIRECTORY + rrdKey + ".rrd");
			Sample sample = myRrd.createSample();
			sample.setTime(rrdTime);
			sample.setValue(rrdDSName, rrdValue);
			sample.update();
		} catch (IOException e) {
			logger.log(Level.SEVERE, "IO Exception error " + e.getMessage()
					+ e.toString());
		} catch (RrdException e) {
			logger.log(Level.SEVERE, "RRD Exception error " + e.getMessage()
					+ e.toString());
		} finally {
			try {
				releaseRrd(myRrd);
			} catch (IOException e) {
				logger.log(Level.SEVERE, "IO Exception error " + e.getMessage()
						+ e.toString());
			} catch (RrdException e) {
				logger.log(Level.SEVERE, "RRD Exception error "
						+ e.getMessage() + e.toString());
			}
		}
	}

	public static RrdDb useRrd(String rrdbPath) throws IOException,
			RrdException {

		RrdDb rrd = rrdbPool.requestRrdDb(rrdbPath);
		return rrd;
	}

	public static void releaseRrd(RrdDb myRrdb) throws IOException,
			RrdException {

		rrdbPool.release(myRrdb);
	}

	/**
	 * @param rrdKey The rrd key name. Just the name with no dir or extensions.
	 * @param rrdDSName The DataSource name to update.
	 * @param rrdValue The value you want to store.
	 * This method is overloaded to provide flexability in use. It will call the appropriate sample methods and update the rrd. Current time would be used.
	 */
	public void rrdUpdate(String rrdKey, String rrdDSName, double rrdValue) {
		RrdDb myRrd = null;
		try {
			myRrd = useRrd(RRDBDIRECTORY + rrdKey + ".rrd");
			Sample sample = myRrd.createSample();
			sample.setValue(rrdDSName, rrdValue);
			sample.update();
		} catch (IOException e) {
			logger.log(Level.SEVERE, "IO Exception error " + e.getMessage()
					+ e.toString());
		} catch (RrdException e) {
			logger.log(Level.SEVERE, "RRD Exception error " + e.getMessage()
					+ e.toString());
		} finally {
			try {
				releaseRrd(myRrd);
			} catch (IOException e) {
				logger.log(Level.SEVERE, "IO Exception error " + e.getMessage()
						+ e.toString());
			} catch (RrdException e) {
				logger.log(Level.SEVERE, "RRD Exception error "
						+ e.getMessage() + e.toString());
			}
		}
	}

	/**
	 * @param rrdKey The rrd key name. Just the name with no dir or extensions.
	 * @param rrdTime The timestamp of this sample. Time ia a (long) in secs since 1/1/1970 UTC
	 * @param rrdDSint The DataSource index number to update.
	 * @param rrdValue The value you want to store.
	 * This method is overloaded to provide flexability in use. It will call the appropriate sample methods and update the rrd.
	 * eg.  rrdUpdate("test",1105537200L,"input", 12345d);
	 */
	public void rrdUpdate(String rrdKey, long rrdTime, int rrdDSint,
			double rrdValue) {
		RrdDb myRrd = null;
		try {
			myRrd = useRrd(RRDBDIRECTORY + rrdKey + ".rrd");
			Sample sample = myRrd.createSample();
			sample.setTime(rrdTime);
			sample.setValue(rrdDSint, rrdValue);
			sample.update();
			releaseRrd(myRrd);
		} catch (IOException e) {
			logger.log(Level.SEVERE, "IO Exception error " + e.getMessage()
					+ e.toString());
		} catch (RrdException e) {
			logger.log(Level.SEVERE, "RRD Exception error " + e.getMessage()
					+ e.toString());
		} finally {
			try {
				releaseRrd(myRrd);
			} catch (IOException e) {
				logger.log(Level.SEVERE, "IO Exception error " + e.getMessage()
						+ e.toString());
			} catch (RrdException e) {
				logger.log(Level.SEVERE, "RRD Exception error "
						+ e.getMessage() + e.toString());
			}
		}
	}

	/**
	 * @param rrdKey The rrd key name. Just the name with no dir or extensions.
	 * @param rrdDSint The DataSource index number to update.
	 * @param rrdValue The value you want to store.
	 * This method is overloaded to provide flexability in use. It will call the appropriate sample methods and update the rrd.
	 */
	public void rrdUpdate(String rrdKey, int rrdDSint, double rrdValue) {
		RrdDb myRrd = null;
		try {
			myRrd = useRrd(RRDBDIRECTORY + rrdKey + ".rrd");
			Sample sample = myRrd.createSample();
			sample.setValue(rrdDSint, rrdValue);
			sample.update();
		} catch (IOException e) {
			logger.log(Level.SEVERE, "IO Exception error " + e.getMessage()
					+ e.toString());
		} catch (RrdException e) {
			logger.log(Level.SEVERE, "RRD Exception error " + e.getMessage()
					+ e.toString());
		} finally {
			try {
				releaseRrd(myRrd);
			} catch (IOException e) {
				logger.log(Level.SEVERE, "IO Exception error " + e.getMessage()
						+ e.toString());
			} catch (RrdException e) {
				logger.log(Level.SEVERE, "RRD Exception error "
						+ e.getMessage() + e.toString());
			}
		}
	}

	//    -----------------------------------------------------------------------------------------
	// These are all with double[] array passed in

	/**
	 * @param rrdKey The rrd key name. Just the name with no dir or extensions.
	 * @param rrdTime The timestamp of this sample. Time ia a (long) in secs since 1/1/1970 UTC
	 * @param rrdValues The values you want to store in the order of dsn. leave 1 blank and nan will be stored.
	 * This method is overloaded to provide flexability in use. It will call the appropriate sample methods and update the rrd.
	 */
	public void rrdUpdate(String rrdKey, long rrdTime, double[] rrdValues) {
		RrdDb myRrd = null;
		try {
			myRrd = useRrd(RRDBDIRECTORY + rrdKey + ".rrd");
			Sample sample = myRrd.createSample();
			sample.setTime(rrdTime);
			sample.setValues(rrdValues);
			sample.update();
		} catch (IOException e) {
			logger.log(Level.SEVERE, "IO Exception error " + e.getMessage()
					+ e.toString());
		} catch (RrdException e) {
			logger.log(Level.SEVERE, "RRD Exception error " + e.getMessage()
					+ e.toString());
		} finally {
			try {
				releaseRrd(myRrd);
			} catch (IOException e) {
				logger.log(Level.SEVERE, "IO Exception error " + e.getMessage()
						+ e.toString());
			} catch (RrdException e) {
				logger.log(Level.SEVERE, "RRD Exception error "
						+ e.getMessage() + e.toString());
			}
		}
	}

	/**
	 * @param rrdKey The rrd key name. Just the name with no dir or extensions.
	 * @param rrdValues The values you want to store in the order of dsn. leave 1 blank and nan will be stored.
	 * This method is overloaded to provide flexability in use. It will call the appropriate sample methods and update the rrd. Current time would be used.
	 */
	public void rrdUpdate(String rrdKey, double[] rrdValues) {
		RrdDb myRrd = null;
		try {
			myRrd = useRrd(RRDBDIRECTORY + rrdKey + ".rrd");
			Sample sample = myRrd.createSample();
			sample.setValues(rrdValues);
			sample.update();
		} catch (IOException e) {
			logger.log(Level.SEVERE, "IO Exception error " + e.getMessage()
					+ e.toString());
		} catch (RrdException e) {
			logger.log(Level.SEVERE, "RRD Exception error " + e.getMessage()
					+ e.toString());
		} finally {
			try {
				releaseRrd(myRrd);
			} catch (IOException e) {
				logger.log(Level.SEVERE, "IO Exception error " + e.getMessage()
						+ e.toString());
			} catch (RrdException e) {
				logger.log(Level.SEVERE, "RRD Exception error "
						+ e.getMessage() + e.toString());
			}
		}
	}
	

	public au.com.BI.JRobin.JRobinData getJrobinDataObject(String key) {
		synchronized (jRobinRRDS) {
			Collection jRobinRRDsCollection = jRobinRRDS.values();

			Iterator eachJRobin = jRobinRRDsCollection.iterator();
			while (eachJRobin.hasNext()) {
				JRobinData jRobinData = (JRobinData) eachJRobin.next();
				if (jRobinData.findDisplayName(key) == true) {
					return jRobinData;
				}
			}
		}
		return null;
	}
	
	public void  doJRobinStartup(Bootstrap bootstrap, Controller controller, Cache cache, JRobinParser jRobinParser) {
		RRDGRAPH = bootstrap.getRrdGraphDir(); // assign the directory from the
												// xml file
		RRDDefinition jRobinDef = null;
		boolean isActive=  jRobinParser.isJRobinActive();

		if (isActive ) {
			RrdDbPool myrrdbPool = RrdDbPool.getInstance();
			rrdbPool = myrrdbPool;

			rrdGraph = new au.com.BI.JRobin.RRDGraph(RRDGRAPH);
			rrdGraph.setController(controller);
			jRobinDef = new au.com.BI.JRobin.RRDDefinition();

			// ensure rrds exist
			try {
				RRDBDIRECTORY = bootstrap.getRRDBDIRECTORY();
				RRDXMLDIRECTORY = bootstrap.getRRDXMLDIRECTORY();

					jRobinDef.startUp(RRDBDIRECTORY, RRDXMLDIRECTORY);
					cache.setJRobinActive(true);

			} catch (NoClassDefFoundError ex) {
				String errorMsg = ex.getMessage();
			}
			jRobinRRDS = jRobinParser.getJRobinRRDs();
			Collection jRobinRRDsCollection = jRobinRRDS.values();
			Iterator eachJRobin = jRobinRRDsCollection.iterator();
			while (eachJRobin.hasNext()) {
				JRobinData jRobinData = (JRobinData) eachJRobin.next();
				JRobinQuery jrobin = new JRobinQuery(jRobinData, this);
				jrobin.start();
			}
		}
	}
	

	/**
	 * @return Returns the RRDBDIRECTORY.
	 */
	public String getRRDBDIRECTORY() {
		return RRDBDIRECTORY;
	}

}
