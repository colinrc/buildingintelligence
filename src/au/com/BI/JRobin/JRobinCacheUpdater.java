package au.com.BI.JRobin;

import au.com.BI.Command.CommandInterface;
import java.util.Iterator;
import java.util.ArrayList;
import java.util.logging.*;

/**
 * <p>Title: </p>
 *
 * <p>Description: </p>
 *
 * <p>Copyright: Copyright (c) 2005</p>
 *
 * All logic for processing and buffering of RRD data is done here in doCommandForJRobin.
 *
 * @author  By = JeffK
 *
 * @version 1.0
 */

public class JRobinCacheUpdater {


        final int DATATYPE = 1;
        final int DATAALLTYPE = 2;
        final int DATAPOWERCONSUMPTIONTYPE = 3;
        protected Logger logger;
        protected JRobinSupport jRobinSupport;

        public JRobinCacheUpdater(JRobinSupport jRobinSupport) {
                logger = Logger.getLogger(this.getClass().getPackage().getName());
                setJRobinSupport(jRobinSupport);
        }

        public void doCommandForJRobin(CommandInterface command) {
                JRobinData jRobinData;
                String sValue;
                sValue = new String();
                String search;
                double value;
                value = 0;

                JRobinDataItem jRobinDataItem;

                jRobinData = command.getJRobinData();
                if (jRobinData == null) {
                        logger.log(Level.FINE, "RRD jRobinData is null from: " + command.toString());
                        return;
                }
                ArrayList dataItems;

                String displayName;
                if (command.isClient()) {
                        displayName = command.getKey();
                }
                else {
                        displayName = command.getDisplayName();
                }
                dataItems = jRobinData.getJRobinDataItems(displayName);

                if (dataItems == null) {
                       logger.log(Level.FINE, "RRD jRobinDataItems is null from: " + command.toString());
                       return;
               }


                Iterator theDataItem = dataItems.iterator();
                while (theDataItem.hasNext()) {
                        jRobinDataItem = (JRobinDataItem) theDataItem.next();

                        logger.log(Level.FINE, jRobinDataItem.toString());

                        if (jRobinDataItem.getItemType() == DATATYPE || jRobinDataItem.getItemType() == DATAALLTYPE) {
                                search = jRobinDataItem.getSearchValue();

                                if (jRobinDataItem.getSource().equals("USAGE")) {
                                        if (search.length() > 0) {
                                                if (search.equals(command.getCommandCode())) {
                                                        jRobinSupport.incrementVariable(jRobinDataItem.getVariable());
                                                        continue;
                                                }
                                        }
                                        else {
                                                jRobinSupport.incrementVariable(jRobinDataItem.getVariable());
                                                continue;
                                        }
                                }

                                if (jRobinDataItem.getSource().equals("EXTRA_VALUE1")) {
                                        sValue = command.getExtraInfo();
                                       if (sValue == "" && command.getCommandCode().equals("on")) {
                                               sValue = "100"; //extrainfo does not contain values for off/on switch
                                       }
                                }
                                else if (jRobinDataItem.getSource().equals(
                                  "EXTRA_VALUE2")) {
                                        sValue = command.getExtra2Info();
                                }
                                else if (jRobinDataItem.getSource().equals(
                                  "EXTRA_VALUE3")) {
                                        sValue = command.getExtra3Info();
                                }
                                else if (jRobinDataItem.getSource().equals(
                                  "EXTRA_VALUE4")) {
                                        sValue = command.getExtra4Info();
                                }
                                else if (jRobinDataItem.getSource().equals(
                                  "EXTRA_VALUE5")) {
                                        sValue = command.getExtra5Info();
                                }

                                if (search.length() > 0) {
                                        if (!search.equals(command.getCommandCode()))
                                                continue;
                                }

                                try {
                                        value = Double.parseDouble(sValue);
                                }

                                catch (NumberFormatException ex) {
                                        value = 0;
                                }

                                //get old value
                                double oldVal;
                                String sOldValue;
                                sOldValue = new String();
                                try {
                                        oldVal = jRobinSupport.getDoubleVariable(jRobinDataItem.getVariable()).doubleValue();
                                }
                                catch (NullPointerException ex) {
                                        oldVal = 0;
                                }

                                if (jRobinDataItem.getFunction().equals("TOTAL")) {
                                        oldVal = oldVal + value;
                                        jRobinSupport.setVariable(jRobinDataItem.getVariable(), oldVal);
                                }
                                else if (jRobinDataItem.getFunction().equals("MIN")) {
                                        if (sOldValue.equals("None")) {
                                                //First time
                                                jRobinSupport.setVariable(jRobinDataItem.getVariable(), value);
                                        }
                                        else if (value < oldVal) {
                                                jRobinSupport.setVariable(jRobinDataItem.getVariable(), value);
                                        }
                                }
                                else if (jRobinDataItem.getFunction().equals("MAX")) {
                                        if (sOldValue.equals("None")) {
                                                //First time
                                                jRobinSupport.setVariable(jRobinDataItem.getVariable(), value);
                                        }
                                        else if (value > oldVal) {
                                                jRobinSupport.setVariable(jRobinDataItem.getVariable(), value);
                                        }

                                }
                                else if (jRobinDataItem.getFunction().equals("AVG")) {
                                        oldVal = oldVal + value;
                                        jRobinSupport.setVariable(jRobinDataItem.getVariable(), oldVal);
                                        jRobinSupport.incrementVariable(jRobinDataItem.getVariable() + "_~COUNT");
                                }
                        } // end of DATATYPE
                        //Power time
                        else if (jRobinDataItem.getItemType() == DATAPOWERCONSUMPTIONTYPE) {
                                //implement dataSource, displayName, variable, source, ratio

                                if (jRobinDataItem.getSource().equals("EXTRA_VALUE1")) {
                                        sValue = command.getExtraInfo();
                                        if (sValue == "" && command.getCommandCode().equals("on")) {
                                                sValue = "100"; //extrainfo does not contain values for off/on switch
                                        }
                                }
                                else if (jRobinDataItem.getSource().equals(
                                  "EXTRA_VALUE2")) {
                                        sValue = command.getExtra2Info();
                                }
                                else if (jRobinDataItem.getSource().equals(
                                  "EXTRA_VALUE3")) {
                                        sValue = command.getExtra3Info();
                                }
                                else if (jRobinDataItem.getSource().equals(
                                  "EXTRA_VALUE4")) {
                                        sValue = command.getExtra4Info();
                                }
                                else if (jRobinDataItem.getSource().equals(
                                  "EXTRA_VALUE5")) {
                                        sValue = command.getExtra5Info();
                                }

                                try {
                                        value = Double.parseDouble(sValue);
                                }

                                catch (NumberFormatException ex) {
                                        value = 0;
                                }

                                //get old value
                                double oldVal, consume, oldConsume;

                                try {
                                        oldVal = jRobinSupport.getDoubleVariable(jRobinDataItem.getVariable()).doubleValue();
                                }
                                catch (NullPointerException ex) {
                                        oldVal = value; //use current
                                }


                                //get old time
                                long oldtime, lastQueryTime, lastAccessTime, startTime, endTime;
                                double powerRating, ratio, elapsedTime;
                                String sOldTime, sLastQueryTime;
                                sOldTime = new String();
                                sLastQueryTime = new String();

                                try {
                                        oldtime = jRobinSupport.getLongVariable(jRobinDataItem.getVariable() + "_~TIME").longValue();
                                }
                                catch (NullPointerException ex) {
                                        oldtime = 0;
                                }

                                try {
                                        lastQueryTime = jRobinSupport.getLongVariable(jRobinData.getRRDName() + "_~LASTQTIME").longValue();
                                }
                                catch (NullPointerException ex) {
                                        lastQueryTime = 0;
                                }
                                ratio = jRobinDataItem.getRatio();
                                lastAccessTime = command.getCreationDate();
                                powerRating = jRobinDataItem.getPowerRating();

                                //Now start logic

                                endTime = System.currentTimeMillis();

                                if (lastAccessTime <= lastQueryTime) {
                                        startTime = lastQueryTime;
                                }
                                else {
                                        startTime = lastAccessTime;
                                }
                                elapsedTime = (endTime - startTime);
                                elapsedTime = elapsedTime / 1000d;  //seconds

                                consume = (oldVal / 100d * powerRating) / elapsedTime * ratio; //wattt's per second

                                try {
                                        oldConsume = jRobinSupport.getDoubleVariable(jRobinDataItem.getVariable() + "_~CONSUME").doubleValue();
                                }
                                catch (NullPointerException ex) {
                                        oldConsume = 0;
                                }
                                oldConsume = oldConsume + consume;

                                jRobinSupport.setVariable(jRobinDataItem.getVariable() + "_~POWERRATING", powerRating);

                                jRobinSupport.setVariable(jRobinDataItem.getVariable() + "_~CONSUME", oldConsume);

                                jRobinSupport.setLongVariable(jRobinDataItem.getVariable() + "_~TIME", endTime);

                                jRobinSupport.setVariable(jRobinDataItem.getVariable(), value);

                        }
                }
        }

        public void setJRobinSupport(JRobinSupport jRobinSupport) {
                this.jRobinSupport = jRobinSupport;
        }

        public JRobinSupport getJRobinSupport() {
                return this.jRobinSupport;
        }

}
