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
public class RRDValueObject implements RRDInterface{
  protected String graphName;
  protected String graphTemplate;
  protected int width;
  protected int height;
  protected String graphType;
  protected long startTime;
  protected long endTime;
  protected String title;
  protected String rrd;
  protected String dataSource;
  protected double rrdValue;
  protected float quality;
  protected double[] RRDvalues;

  public RRDValueObject() {
    //Initial values are all null
  }

    public void setGraphName(String graphName) {
      this.graphName = graphName;
    }

    public void setGraphTemplate(String graphTemplate) {
      this.graphTemplate = graphTemplate;
    }

    public void setWidth(int width) {
      this.width = width;
    }

    public void setHeight(int height) {
      this.height = height;
    }

    public void setGraphType(String graphType) {
      this.graphType = graphType;
    }

    public void setStartTime(long startTime) {
      this.startTime = startTime;
    }

    public void setEndTime(long endTime) {
      this.endTime = endTime;
    }

    public void setTitle(String title) {
      this.title = title;
    }

    public void setRRD(String rrd) {
      this.rrd = rrd;
    }

    public void setDataSource(String dataSource) {
      this.dataSource = dataSource;
    }

    public void setRRDValue(double rrdValue) {
      this.rrdValue = rrdValue;
    }

    public void setRRDValues(double[] rrdValues) {
        this.RRDvalues = rrdValues;
    }

    public void setQuality(float quality) {
         this.quality = quality;
    }

    public String getGraphName() {
      return this.graphName;
    }

    public String getGraphTemplate() {
      return this.graphTemplate;
    }

    public int getWidth() {
      return this.width;
    }

    public int getHeight() {
      return this.height;
    }

    public String getGraphType() {
      return this.graphType;
    }

    public long getStartTime() {
      return this.startTime;
    }

    public long getEndTime() {
      return this.endTime;
    }

    public String getTitle() {
      return this.title;
    }

    public String getRRD() {
      return this.rrd;
    }

    public String getDataSource() {
      return this.dataSource;
    }

    public double getRRDValue() {
      return this.rrdValue;
    }

    public double[] getRRDValues() {
      return this.RRDvalues;
    }

    public float getQuality() {
      return this.quality;
    }
  }
