package au.com.BI.JRobin;

/**
 * <p>Title: </p>
 *
 * <p>Description: </p>
 *
 * <p>Copyright: Copyright (c) 2004</p>
 *
 * <p>Company: Building Intelligence</p>
 *
 * @author Jeff Kitchener
 * @version 1.0
 */
public class JRobinDataItem {
        private String dataSource;
        private String displayName;
        private String variable;
        private String source;
        private String searchValue;
        private String function;
        private double ratio;
        private double powerRating;
        private int itemType;
        final int DATATYPE = 1;
        final int DATAALLTYPE = 2;
        final int DATAPOWERCONSUMPTIONTYPE = 3;

        /**
         *
         */
        public JRobinDataItem(){
                this.dataSource = "";
                this.displayName = "";
                this.variable = "";
                this.source = "";
                this.searchValue = "";
                this.function = "";
                this.ratio = 0;
                this.itemType = 0;
                this.powerRating = 0;

        }

        public JRobinDataItem(String dataSource,String displayName,String variable,String source,String searchValue,String function, double rating) {
                setDataSource(dataSource);
                setDisplayNames(displayName);
                setVariable(variable);
                setSource(source);
                setSearchValue(searchValue);
                setFunction(function);
                setPowerRating(rating);
                this.itemType = DATATYPE;
        }

        public JRobinDataItem(String displayName,String variable,String source,String searchValue,String function, double rating) {
               setDataSource("");
               setDisplayNames(displayName);
               setVariable(variable);
               setSource(source);
               setSearchValue(searchValue);
               setFunction(function);
               setPowerRating(rating);
               this.itemType = DATAALLTYPE;
       }

        public JRobinDataItem(String dataSource,String displayName,String variable,String source, double ratio, double rating) {
                setDataSource(dataSource);
                setDisplayNames(displayName);
                setVariable(variable);
                setSource(source);
                setSearchValue("");
                setFunction("");
                setRatio(ratio);
                setPowerRating(rating);
                this.itemType = DATAPOWERCONSUMPTIONTYPE;
        }



        public String getDataSource() {
                return dataSource;
        }

        public String getDisplayName() {
                return displayName;
        }

        public String getVariable() {
                return variable;
        }

        public String getSource() {
                return source;
        }

        public String getSearchValue() {
                return searchValue;
        }

        public String getFunction() {
                return function;
        }

        public double getRatio() {
                return ratio;
        }

        public int getItemType() {
                return itemType;
        }

        public double getPowerRating() {
                return powerRating;
        }

        public void setDataSource(String dataSource) {
               this.dataSource = dataSource;
        }
        public void setDisplayNames(String displayName) {
               this.displayName = displayName;
        }
        public void setVariable(String variable) {
                this.variable = variable;
        }
        public void setSource(String source) {
                this.source = source;
        }
        public void setSearchValue(String searchValue) {
                this.searchValue = searchValue;
        }
        public void setFunction(String function) {
                this.function = function;
        }
        public void setRatio(double ratio) {
                this.ratio = ratio;
        }

        public void setPowerRating(double rating) {
               this.powerRating = rating;
        }

        public String toString() {
                 String showValues;
                 showValues = "RRD Values.............. \nRRD DataSource: "+ this.dataSource + "\n" +
                     "RRD displayName: "+ this.displayName + "\n" +
                     "RRD variable: "+ this.variable + "\n" +
                     "RRD source: "+ this.source + "\n" +
                     "RRD searchValue: "+ this.searchValue + "\n" +
                     "RRD function: "+ this.function + "\n" +
                     "RRD PowerRating: "+ Double.toString(this.powerRating) + "\n" +
                     "RRD ratio: "+ Double.toString(this.ratio) + "\n";

                 return showValues;
         }


}
