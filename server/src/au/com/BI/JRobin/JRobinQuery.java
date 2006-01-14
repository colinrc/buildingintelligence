/*
 * Created on Jan 26, 2005
 * @Author Colin Canfield
 */
package au.com.BI.JRobin;


import au.com.BI.Home.Controller;
import java.util.logging.*;
import java.util.*;
import au.com.BI.JRobin.JRobinData;
import au.com.BI.JRobin.JRobinDataItem;

public class JRobinQuery extends Thread {
        protected Controller controller;
        protected long testInterval;
        private boolean isRunning = false;
        protected Logger logger;
        protected JRobinData jRobinData;
        protected String RRDName;

        final int DATATYPE = 1;
        final int DATAALLTYPE = 2;
        final int DATAPOWERCONSUMPTIONTYPE = 3;

        public JRobinQuery (JRobinData jRobinData , Controller controller) {
                this.controller = controller;
                testInterval = jRobinData.getUpdateInterval();
                this.jRobinData = jRobinData;
                RRDName = jRobinData.getRRDName();
        }

        public void run() {
                logger = Logger.getLogger(this.getClass().getPackage().getName());
                isRunning = true;

                JRobinDataItem jRobinDataItem;
                ArrayList dataSources;

                while (isRunning) {
                        logger.log(Level.FINE,
                          "JRobinQuery is Running " + RRDName +
                          " RRD every " + Long.toString(testInterval) +
                          " seconds.");
                        // potenial performance problem CHECK THIS
                        dataSources = controller.getRRDDataSources(RRDName);

                        if (dataSources == null ) {
                        	   isRunning = false;
                        	   continue;
                        }
                        double values[] = new double[dataSources.size()];

                        int i = 0, idx = 0;
                        int numOfDataItems = jRobinData.getNumberOfDataItems() - 1;
                        long endTime;
                        endTime = System.currentTimeMillis();
                        String variable, key;

                        while (i <= numOfDataItems) {
                                jRobinDataItem = jRobinData.getDataItem(i);
                                key = jRobinDataItem.getDataSource();
                                idx = dataSources.indexOf(key);
                                if (idx == -1) {
                                        logger.log(Level.WARNING, "JRobinQuery: Can't find " + key + " in " + RRDName);
                                        i++;
                                        continue;
                                }
                                if (jRobinDataItem.getItemType() == DATAPOWERCONSUMPTIONTYPE) {
                                        //Process DATA_POWER_CONUMPTION items
                                        double powerRating, ratio;
                                        long startTime, lastQuerytTime;
                                        double value, oldConsume, consume,elapsedTime;
                                        double valuesPower[] = new double[numOfDataItems];

                                        try {
                                                oldConsume = controller.getDoubleVariable(jRobinDataItem.getVariable() + "_~CONSUME").doubleValue();
                                        }
                                        catch (NullPointerException ex) {
                                                oldConsume = 0;
                                        }
                                        try {
                                                startTime = controller.getLongVariable(jRobinDataItem.getVariable() + "_~TIME").longValue();
                                        }
                                        catch (NullPointerException ex) {
                                                startTime = 0;
                                        }
                                        try {
                                                lastQuerytTime = controller.getLongVariable(jRobinData.getRRDName() + "_~LASTQTIME").longValue();
                                        }
                                        catch (NullPointerException ex) {
                                                lastQuerytTime = 0;
                                        }
                                        if (startTime <= lastQuerytTime) {
                                                startTime = lastQuerytTime;
                                        }


                                        try {
                                                value = controller.getDoubleVariable(jRobinDataItem.getVariable()).doubleValue();
                                        }
                                        catch (NullPointerException ex) {
                                                value = 0;
                                        }

                                        ratio = jRobinDataItem.getRatio();

                                        powerRating = jRobinDataItem.getPowerRating();

                                        elapsedTime = endTime - startTime;
                                        elapsedTime = elapsedTime /1000d;  //seconds

                                        consume = (value / 100d * powerRating) / elapsedTime * ratio; //wattt's per second
                                        consume = consume + oldConsume;

                                        values[idx] = consume;
                                }
                                else {
                                        //process DATA and DATA_ALL

                                        String count;
                                        double value;
                                        double countValue;


                                        try {
                                                value = controller.getDoubleVariable(jRobinDataItem.getVariable()).doubleValue();
                                        }
                                        catch (NullPointerException ex) {
                                                value = 0;
                                        }

                                        if (jRobinDataItem.getFunction().equals("AVG")) {
                                                try {
                                                        countValue = controller.getDoubleVariable(jRobinDataItem.getVariable() + "_~COUNT").doubleValue();
                                                }
                                                catch (NullPointerException ex) {
                                                        countValue = 0;
                                                }

                                                if (countValue > 0) {
                                                        value = value / countValue;
                                                }
                                        }
                                        try {
                                                values[idx] = value;
                                        }
                                        catch (ArrayIndexOutOfBoundsException e)
                                        {
                                                logger.log(Level.SEVERE,"Your RRD Definition and config file may be out of sink " + e.getMessage() );
                                        }

                                }

                                i++;
                        }
                        logger.log(Level.FINE, "update rrd with " + values.toString());
                        controller.rrdUpdate(RRDName, values);

                        ArrayList variables;
                        variables = jRobinData.getJRobinDataItemVariables();
                        controller.clearVariables(variables);
                        controller.setLongVariable(jRobinData.getRRDName() + "_~LASTQTIME", endTime);

                        try {
                                Thread.sleep(testInterval * 1000);
                        }
                        catch (InterruptedException e) {
                        }
                }
        }
        /**
         * @return Returns the isRunning.
         */
        public boolean isRunning() {
                return isRunning;
        }
        /**
         * @param isRunning The isRunning to set.
         */
        public void setRunning(boolean isRunning) {
                this.isRunning = isRunning;
        }
}
