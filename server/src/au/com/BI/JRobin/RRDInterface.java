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
public interface RRDInterface {

  public void setGraphName (String GraphName);

  public void setGraphTemplate (String GraphTemplate);

  public void setWidth (int GraphName);

  public void setHeight (int GraphTemplate);

  public void setGraphType (String graphType);

  public void setStartTime (long startTime);

  public void setEndTime (long endTime);

  public void setTitle (String title);

  public void setRRD (String rrd);

  public void setDataSource (String dataSource);

  public void setRRDValue (double RRDvalue);

  public void setRRDValues (double[] RRDvalues);

  public void setQuality (float quality);


 public String getGraphName ();

 public String getGraphTemplate ();

 public int getWidth ();

 public int getHeight ();

 public String getGraphType ();

 public long getStartTime ();

 public long getEndTime ();

 public String getTitle ();

 public String getRRD ();

 public String getDataSource ();

 public double getRRDValue ();

 public double[] getRRDValues ();

 public float getQuality ();

}
