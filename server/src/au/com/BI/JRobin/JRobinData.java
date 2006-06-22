/*
 * Created on Jan 28, 2005
 *
 */
package au.com.BI.JRobin;

import java.util.*;
import au.com.BI.JRobin.JRobinDataItem;

public class JRobinData {
        private long updateInterval;
        private String RRDName;

        private ArrayList <JRobinDataItem>data;
        private int numberOfData;
        private int numberOfDataAll;
        private int numberOfDataPowerConumption;

        /**
         *
         */
        public JRobinData() {
        }

        public JRobinData(long updateInterval, String RRDName) {
                this.updateInterval = updateInterval;
                this.RRDName = RRDName;

                data = new ArrayList <JRobinDataItem>(20);
                numberOfData = 0;
                numberOfDataAll = 0;
                numberOfDataPowerConumption = 0;
        }

         public String toString() {
                 String showValues;
                 showValues = "RRDName:" + this.RRDName + "\n" +
                   "RRDInterval:" + new Long(updateInterval).toString() + "\n";
                 return showValues;
         }

        /**
         * returns the number of JRobinData Items that were defined.
         *
         * @return Integer
         */
        public int getNumberOfDataItems() {
                 return numberOfData + numberOfDataAll + numberOfDataPowerConumption;

         }

        /**
         * Returns true if JROBIN config has DATA_ALL elements.
         *
         * @return boolean
         */
        public boolean isDataAll() {
                 if (numberOfDataAll > 0) {
                         return true;
                 }
                 return false;
         }

         /**
         * Returns true if JROBIN config has DATA_POWER_CONSUMPTION elements.
         *
         * @return boolean
         */
        public boolean isDataPowerConumption() {
                 if (numberOfDataPowerConumption > 0) {
                         return true;
                 }
                 return false;
         }


        /**
         * @param add a data element.
         */
        private void addData (JRobinDataItem dataItem) {
                data.add(dataItem);
                numberOfData ++;
        }

        /**
         * @param add a dataAll element.
         */
        private void addDataAll(JRobinDataItem dataItem) {
                data.add(dataItem);
                numberOfDataAll++;
        }

        /**
         * @param add a DataPowerConumption element.
         */
        private void addDataPowerConumption(JRobinDataItem dataItem) {
                data.add(dataItem);
                numberOfDataPowerConumption++;
        }

        /**
         * Returns a JRobin data Item
         *
         * @param index int
         * @return JRobinDataItem
         */
        public JRobinDataItem getDataItem(int index) {
                JRobinDataItem jRobinDataItem;
                jRobinDataItem = (JRobinDataItem) data.get(index);
                return jRobinDataItem;
        }
        /**
         * Returns the first  JRobin data Item
         *
         * @param key String
         * @return JRobinDataItem
         */
       public JRobinDataItem getDataItem(String key) {
               if (data.contains(key)) {
                       int i = 0;
                       i = data.indexOf(key);
                       JRobinDataItem jRobinDataItem = (JRobinDataItem)data.get(i);
                       return jRobinDataItem;
               }
                return null;

                /*
                               Iterator eachItem = data.iterator();
                               while (eachItem.hasNext()) {
                                       JRobinDataItem jRobinDataItem = (JRobinDataItem)eachItem.next();
                                       if (jRobinDataItem.getDisplayName().equals(key)) {
                                               return jRobinDataItem;
                                       }
                               }
                               return null;
                 */
       }

       /**
        * Returns all JRobin data Item's with displayName
        *
        * @param key String
        * @return Arraylist of JRobinDataItem
        */
       public ArrayList getJRobinDataItems(String key) {

               ArrayList <JRobinDataItem>dataItemsAL = new ArrayList<JRobinDataItem>(data.size());
               Iterator eachItem = data.iterator();
               while (eachItem.hasNext()) {
                       JRobinDataItem jRobinDataItem = (JRobinDataItem) eachItem.next();
                       if (jRobinDataItem.getDisplayName().equals(key)) {
                               dataItemsAL.add(jRobinDataItem);
                       }
               }
               if (dataItemsAL.size() > 0) {
                       return dataItemsAL;
               }
               return null;
       }


       public ArrayList getJRobinDataItemVariables() {
               ArrayList <String>variables = new ArrayList<String>(20);
               Iterator eachItem = data.iterator();
               int i=0;
               while (eachItem.hasNext()) {
                       JRobinDataItem jRobinDataItem = (JRobinDataItem)eachItem.next();
                     //  variables.add(jRobinDataItem.getVariable());
                       variables.add(jRobinDataItem.getVariable() + "_~COUNT");
                       variables.add(jRobinDataItem.getVariable() + "_~TIME");
                       variables.add(jRobinDataItem.getVariable() + "_~CONSUME");

                       i++;
               }
               return variables;

       }

        /**
         * @param add a dataItem element.
         */
        public void addDataItem(String dataSource, String displayName, String variable, String source, String searchValue, String function, double rating) {
                JRobinDataItem dataItem;
                dataItem = new JRobinDataItem(dataSource, displayName, variable, source, searchValue, function, rating);
                data.add(dataItem);
                numberOfData++;
        }

        /**
         * @param add a dataAllItem element.
         */
        public void addDataItem(String displayName, String variable, String source, String searchValue, String function, double rating) {
                JRobinDataItem dataItem;
                dataItem = new JRobinDataItem(displayName, variable, source, searchValue, function, rating);
                data.add(dataItem);
                numberOfDataAll++;
        }


        /**
         * @param add a DataPowerConumption element.
         */
        public void addDataItem(String dataSource, String displayName, String variable, String source, double ratio, double rating) {
                JRobinDataItem dataItem;
                dataItem = new JRobinDataItem(dataSource, displayName, variable, source, ratio, rating);
                data.add(dataItem);
                numberOfDataPowerConumption++;
        }

        /**
         * @return Returns true if found.
         */
        public boolean findDisplayName(String key) {
                //check data

                Iterator eachItem = data.iterator();
                while (eachItem.hasNext()) {
                        JRobinDataItem jRobinDataItem = (JRobinDataItem) eachItem.next();
                        if (jRobinDataItem.getDisplayName().equals(key)) {
                                return true;
                        }
                }

                return false;
        }
        /**
         * @return Returns the rRDName.
         */
        public String getRRDName() {
                return RRDName;
        }
        /**
         * @param name The rRDName to set.
         */
        public void setRRDName(String name) {
                RRDName = name;
        }
        /**
         * @return Returns the updateInterval.
         */
        public long getUpdateInterval() {
                return updateInterval;
        }
        /**
         * @param updateInterval The updateInterval to set.
         */
        public void setUpdateInterval(long updateInterval) {
                this.updateInterval = updateInterval;
        }
}
