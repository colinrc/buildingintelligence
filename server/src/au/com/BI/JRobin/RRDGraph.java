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

import java.util.logging.*;
import java.io.File;
import java.io.IOException;
import java.text.*;

import org.jrobin.core.*;
import org.jrobin.graph.RrdGraph;
import org.jrobin.graph.RrdGraphDef;
import org.jrobin.graph.RrdGraphDefTemplate;

import au.com.BI.Home.Controller;
import au.com.BI.JRobin.RRDValueObject;

public class RRDGraph {

  protected SimpleDateFormat sdf;
  protected Logger logger;
  protected String fileName;
  protected static String RRDBDIRECTORY = ".\\JRobin\\";
  protected static String RRDGRAPHDIRECTORY = ".\\JRobin\\GraphDefinition\\";
  protected String RRDGRAPH;
  protected Controller myController;

  public RRDGraph() {
    logger = Logger.getLogger(this.getClass().getPackage().getName());
    RRDGRAPH = ".\\JRobin\\Graph\\"; //for testing only

  }

  public RRDGraph(String rrdGraph) {
   logger = Logger.getLogger(this.getClass().getPackage().getName());
   RRDGRAPH = rrdGraph;
 }


  public void setController(au.com.BI.Home.Controller controller) {
    myController = controller;
  }

  /**
   * @param graphName The name of the Graph that you wish to build, ensure a file extension is used if required.
   * @param graphTemplate The name of the template to use to build the graph, ensure a file extension is used if required.
   * @param width The width of the image.
   * @param height The height of the image.
   * @param quality Value between 0 and 1.0, 1.0 being highest.
   * This method is overloaded to provide flexability in use. The default is to produce a jpg file if not specified.
   */
  public void getGraph(String graphName, String graphTemplate, int width,
                       int height, float quality) {
    try {
      RrdGraphDefTemplate rrdGraphTemplate = new RrdGraphDefTemplate(new File(
          RRDGRAPHDIRECTORY + graphTemplate));
      // set variables here
      rrdGraphTemplate.setVariable("rrdPath", RRDBDIRECTORY);
      RrdGraphDef rrdGraphDef = rrdGraphTemplate.getRrdGraphDef();
      RrdGraph graph = new RrdGraph(rrdGraphDef,true);
      graph.saveAsJPEG(RRDGRAPH + graphName, width, height, quality);
    }
    catch (IOException e) {
      logger.log(Level.SEVERE,
                 "IO Exception error " + e.getMessage() + e.toString());
    }
    catch (RrdException e) {
      logger.log(Level.SEVERE,
                 "RRD Exception error " + e.getMessage() + e.toString());
    }
  }

  /**
   * @param graphName The name of the Graph that you wish to build, ensure a file extension is used if required.
   * @param graphTemplate The name of the template to use to build the graph, ensure a file extension is used if required.
   * @param width The width of the image.
   * @param height The height of the image.
   * This invocation will produce the highest quality.
   * This method is overloaded to provide flexability in use. The default is to produce a jpg file if not specified.
   */
  public void getGraph(String graphName, String graphTemplate, int width,
                       int height) {
    try {
      RrdGraphDefTemplate rrdGraphTemplate = new RrdGraphDefTemplate(new File(
          RRDGRAPHDIRECTORY + graphTemplate));
      // set variables here
      rrdGraphTemplate.setVariable("rrdPath", RRDBDIRECTORY);
      RrdGraphDef rrdGraphDef = rrdGraphTemplate.getRrdGraphDef();
      RrdGraph graph = new RrdGraph(rrdGraphDef,true);
      graph.saveAsJPEG(RRDGRAPH + graphName, width, height, 1.0f);
    }
    catch (IOException e) {
      logger.log(Level.SEVERE,
                 "IO Exception error " + e.getMessage() + e.toString());
    }
    catch (RrdException e) {
      logger.log(Level.SEVERE,
                 "RRD Exception error " + e.getMessage() + e.toString());
    }
  }

  /**
   * @param graphName The name of the Graph that you wish to build, ensure a file extension is used if required.
   * @param graphTemplate The name of the template to use to build the graph, ensure a file extension is used if required.
   * @param quality Value between 0 and 1.0, 1.0 being highest.
   * This method is overloaded to provide flexability in use. The default is to produce a jpg file if not specified.
   */
  public void getGraph(String graphName, String graphTemplate, float quality) {
    try {
      RrdGraphDefTemplate rrdGraphTemplate = new RrdGraphDefTemplate(new File(
          RRDGRAPHDIRECTORY + graphTemplate));
      // set variables here
      rrdGraphTemplate.setVariable("rrdPath", RRDBDIRECTORY);
      RrdGraphDef rrdGraphDef = rrdGraphTemplate.getRrdGraphDef();
      RrdGraph graph = new RrdGraph(rrdGraphDef,true);
      graph.saveAsJPEG(RRDGRAPH + graphName, quality);
    }
    catch (IOException e) {
      logger.log(Level.SEVERE,
                 "IO Exception error " + e.getMessage() + e.toString());
    }
    catch (RrdException e) {
      logger.log(Level.SEVERE,
                 "RRD Exception error " + e.getMessage() + e.toString());
    }
  }

  /**
   * @param graphName The name of the Graph that you wish to build, ensure a file extension is used if required.
   * @param graphTemplate The name of the template to use to build the graph, ensure a file extension is used if required.
   * This invocation will produce the highest quality with the default sizes.
   * This method is overloaded to provide flexability in use. The default is to produce a jpg file if not specified.
   */
  public void getGraph(String graphName, String graphTemplate) {
    try {
      RrdGraphDefTemplate rrdGraphTemplate = new RrdGraphDefTemplate(new File(
          RRDGRAPHDIRECTORY + graphTemplate));
      // set variables here
      rrdGraphTemplate.setVariable("rrdPath", RRDBDIRECTORY);
      RrdGraphDef rrdGraphDef = rrdGraphTemplate.getRrdGraphDef();
      RrdGraph graph = new RrdGraph(rrdGraphDef,true);
      graph.saveAsJPEG(RRDGRAPH + graphName, 1.0f);
    }
    catch (IOException e) {
      logger.log(Level.SEVERE,
                 "IO Exception error " + e.getMessage() + e.toString());
    }
    catch (RrdException e) {
      logger.log(Level.SEVERE,
                 "RRD Exception error " + e.getMessage() + e.toString());
    }
  }

  /**
   * @param graphName The name of the Graph that you wish to build, ensure a file extension is used if required.
   * @param graphTemplate The name of the template to use to build the graph, ensure a file extension is used if required.
   * @param width The width of the image.
   * @param height The height of the image.
   * @param quality Value between 0 and 1.0, 1.0 being highest.
   * @param graphType Use 'PNG', 'JPEG' or 'GIF' as a string to request image type.
   * This method is overloaded to provide flexability in use.
   */
  public void getGraph(String graphName, String graphTemplate, int width,
                       int height, float quality, String graphType) {
    try {
      RrdGraphDefTemplate rrdGraphTemplate = new RrdGraphDefTemplate(new File(
          RRDGRAPHDIRECTORY + graphTemplate));
      // set variables here
      rrdGraphTemplate.setVariable("rrdPath", RRDBDIRECTORY);
      RrdGraphDef rrdGraphDef = rrdGraphTemplate.getRrdGraphDef();
      RrdGraph graph = new RrdGraph(rrdGraphDef,true);
      if (graphType == "PNG") {
        graph.saveAsPNG(RRDGRAPH + graphName, width, height);
      }
      else if (graphType == "JPEG") {
        graph.saveAsJPEG(RRDGRAPH + graphName, width, height, quality);
      }
      else if (graphType == "GIF") {
        graph.saveAsGIF(RRDGRAPH + graphName, width, height);
      }
    }
    catch (IOException e) {
      logger.log(Level.SEVERE,
                 "IO Exception error " + e.getMessage() + e.toString());
    }
    catch (RrdException e) {
      logger.log(Level.SEVERE,
                 "RRD Exception error " + e.getMessage() + e.toString());
    }

  }

  //-------------------------------------------------------------------------------

  /**
   * @param graphName The name of the Graph that you wish to build, ensure a file extension is used if required.
   * @param graphTemplate The name of the template to use to build the graph, ensure a file extension is used if required.
   * @param width The width of the image.
   * @param height The height of the image.
   * @param quality Value between 0 and 1.0, 1.0 being highest.
   * This method is overloaded to provide flexability in use. The default is to produce a jpg file if not specified.
   */
  public void getGraph(String graphName, String graphTemplate, int width,
                       int height, float quality, long startTime, long endTime) {
    try {
      RrdGraphDefTemplate rrdGraphTemplate = new RrdGraphDefTemplate(new File(
          RRDGRAPHDIRECTORY + graphTemplate));
      // set variables here
      rrdGraphTemplate.setVariable("rrdPath", RRDBDIRECTORY);
      rrdGraphTemplate.setVariable("startTime", startTime);
      rrdGraphTemplate.setVariable("endTime", endTime);
      RrdGraphDef rrdGraphDef = rrdGraphTemplate.getRrdGraphDef();
      RrdGraph graph = new RrdGraph(rrdGraphDef,true);
      graph.saveAsJPEG(RRDGRAPH + graphName, width, height, quality);
    }
    catch (IOException e) {
      logger.log(Level.SEVERE,
                 "IO Exception error " + e.getMessage() + e.toString());
    }
    catch (RrdException e) {
      logger.log(Level.SEVERE,
                 "RRD Exception error " + e.getMessage() + e.toString());
    }
  }

  /**
   * @param graphName The name of the Graph that you wish to build, ensure a file extension is used if required.
   * @param graphTemplate The name of the template to use to build the graph, ensure a file extension is used if required.
   * @param width The width of the image.
   * @param height The height of the image.
   * This invocation will produce the highest quality.
   * This method is overloaded to provide flexability in use. The default is to produce a jpg file if not specified.
   */
  public void getGraph(String graphName, String graphTemplate, int width,
                       int height, long startTime, long endTime) {
    try {
      RrdGraphDefTemplate rrdGraphTemplate = new RrdGraphDefTemplate(new File(
          RRDGRAPHDIRECTORY + graphTemplate));
      // set variables here
      rrdGraphTemplate.setVariable("rrdPath", RRDBDIRECTORY);
      rrdGraphTemplate.setVariable("startTime", startTime);
      rrdGraphTemplate.setVariable("endTime", endTime);
      RrdGraphDef rrdGraphDef = rrdGraphTemplate.getRrdGraphDef();
      RrdGraph graph = new RrdGraph(rrdGraphDef,true);
      graph.saveAsJPEG(RRDGRAPH + graphName, width, height, 1.0f);
    }
    catch (IOException e) {
      logger.log(Level.SEVERE,
                 "IO Exception error " + e.getMessage() + e.toString());
    }
    catch (RrdException e) {
      logger.log(Level.SEVERE,
                 "RRD Exception error " + e.getMessage() + e.toString());
    }
  }

  /**
   * @param graphName The name of the Graph that you wish to build, ensure a file extension is used if required.
   * @param graphTemplate The name of the template to use to build the graph, ensure a file extension is used if required.
   * @param quality Value between 0 and 1.0, 1.0 being highest.
   * This method is overloaded to provide flexability in use. The default is to produce a jpg file if not specified.
   */
  public void getGraph(String graphName, String graphTemplate, float quality,
                       long startTime, long endTime) {
    try {
      RrdGraphDefTemplate rrdGraphTemplate = new RrdGraphDefTemplate(new File(
          RRDGRAPHDIRECTORY + graphTemplate));
      // set variables here
      rrdGraphTemplate.setVariable("rrdPath", RRDBDIRECTORY);
      rrdGraphTemplate.setVariable("startTime", startTime);
      rrdGraphTemplate.setVariable("endTime", endTime);
      RrdGraphDef rrdGraphDef = rrdGraphTemplate.getRrdGraphDef();
      RrdGraph graph = new RrdGraph(rrdGraphDef,true);
      graph.saveAsJPEG(RRDGRAPH + graphName, quality);
    }
    catch (IOException e) {
      logger.log(Level.SEVERE,
                 "IO Exception error " + e.getMessage() + e.toString());
    }
    catch (RrdException e) {
      logger.log(Level.SEVERE,
                 "RRD Exception error " + e.getMessage() + e.toString());
    }
  }

  /**
   * @param graphName The name of the Graph that you wish to build, ensure a file extension is used if required.
   * @param graphTemplate The name of the template to use to build the graph, ensure a file extension is used if required.
   * This invocation will produce the highest quality with the default sizes.
   * This method is overloaded to provide flexability in use. The default is to produce a jpg file if not specified.
   */
  public void getGraph(String graphName, String graphTemplate, long startTime,
                       long endTime) {
    try {
      RrdGraphDefTemplate rrdGraphTemplate = new RrdGraphDefTemplate(new File(
          RRDGRAPHDIRECTORY + graphTemplate));
      // set variables here
      rrdGraphTemplate.setVariable("rrdPath", RRDBDIRECTORY);
      rrdGraphTemplate.setVariable("startTime", startTime);
      rrdGraphTemplate.setVariable("endTime", endTime);
      RrdGraphDef rrdGraphDef = rrdGraphTemplate.getRrdGraphDef();
      RrdGraph graph = new RrdGraph(rrdGraphDef,true);
      graph.saveAsJPEG(RRDGRAPH + graphName, 1.0f);
    }
    catch (IOException e) {
      logger.log(Level.SEVERE,
                 "IO Exception error " + e.getMessage() + e.toString());
    }
    catch (RrdException e) {
      logger.log(Level.SEVERE,
                 "RRD Exception error " + e.getMessage() + e.toString());
    }
  }

  /**
   * @param graphName The name of the Graph that you wish to build, ensure a file extension is used if required.
   * @param graphTemplate The name of the template to use to build the graph, ensure a file extension is used if required.
   * @param width The width of the image.
   * @param height The height of the image.
   * @param quality Value between 0 and 1.0, 1.0 being highest.
   * @param graphType Use 'PNG', 'JPEG' or 'GIF' as a string to request image type.
   * This method is overloaded to provide flexability in use.
   */
  public void getGraph(String graphName, String graphTemplate, int width,
                       int height, float quality, String graphType,
                       long startTime, long endTime) {
    try {
      RrdGraphDefTemplate rrdGraphTemplate = new RrdGraphDefTemplate(new File(
          RRDGRAPHDIRECTORY + graphTemplate));
      // set variables here
      rrdGraphTemplate.setVariable("rrdPath", RRDBDIRECTORY);
      rrdGraphTemplate.setVariable("startTime", startTime);
      rrdGraphTemplate.setVariable("endTime", endTime);
      RrdGraphDef rrdGraphDef = rrdGraphTemplate.getRrdGraphDef();
      RrdGraph graph = new RrdGraph(rrdGraphDef,true);
      if (graphType == "PNG") {
        graph.saveAsPNG(RRDGRAPH + graphName, width, height);
      }
      else if (graphType == "JPEG") {
        graph.saveAsJPEG(RRDGRAPH + graphName, width, height, quality);
      }
      else if (graphType == "GIF") {
        graph.saveAsGIF(RRDGRAPH + graphName, width, height);
      }
    }
    catch (IOException e) {
      logger.log(Level.SEVERE,
                 "IO Exception error " + e.getMessage() + e.toString());
    }
    catch (RrdException e) {
      logger.log(Level.SEVERE,
                 "RRD Exception error " + e.getMessage() + e.toString());
    }
  }

  //-------------------------------------------------------------------------------

  /**
   * @param graphName The name of the Graph that you wish to build, ensure a file extension is used if required.
   * @param graphTemplate The name of the template to use to build the graph, ensure a file extension is used if required.
   * @param width The width of the image.
   * @param height The height of the image.
   * @param quality Value between 0 and 1.0, 1.0 being highest.
   * This method is overloaded to provide flexability in use. The default is to produce a jpg file if not specified.
   */
  public void getGraph(String graphName, String graphTemplate, int width,
                       int height, float quality, long startTime, long endTime,
                       String title) {
    try {
      RrdGraphDefTemplate rrdGraphTemplate = new RrdGraphDefTemplate(new File(
          RRDGRAPHDIRECTORY + graphTemplate));
      // set variables here
      rrdGraphTemplate.setVariable("rrdPath", RRDBDIRECTORY);
      rrdGraphTemplate.setVariable("startTime", startTime);
      rrdGraphTemplate.setVariable("endTime", endTime);
      rrdGraphTemplate.setVariable("title", title);
      RrdGraphDef rrdGraphDef = rrdGraphTemplate.getRrdGraphDef();
      RrdGraph graph = new RrdGraph(rrdGraphDef,true);
      graph.saveAsJPEG(RRDGRAPH + graphName, width, height, quality);
    }
    catch (IOException e) {
      logger.log(Level.SEVERE,
                 "IO Exception error " + e.getMessage() + e.toString());
    }
    catch (RrdException e) {
      logger.log(Level.SEVERE,
                 "RRD Exception error " + e.getMessage() + e.toString());
    }
  }

  /**
   * @param graphName The name of the Graph that you wish to build, ensure a file extension is used if required.
   * @param graphTemplate The name of the template to use to build the graph, ensure a file extension is used if required.
   * @param width The width of the image.
   * @param height The height of the image.
   * This invocation will produce the highest quality.
   * This method is overloaded to provide flexability in use. The default is to produce a jpg file if not specified.
   */
  public void getGraph(String graphName, String graphTemplate, int width,
                       int height, long startTime, long endTime, String title) {
    try {
      RrdGraphDefTemplate rrdGraphTemplate = new RrdGraphDefTemplate(new File(
          RRDGRAPHDIRECTORY + graphTemplate));
      // set variables here
      rrdGraphTemplate.setVariable("rrdPath", RRDBDIRECTORY);
      rrdGraphTemplate.setVariable("startTime", startTime);
      rrdGraphTemplate.setVariable("endTime", endTime);
      rrdGraphTemplate.setVariable("title", title);
      RrdGraphDef rrdGraphDef = rrdGraphTemplate.getRrdGraphDef();
      RrdGraph graph = new RrdGraph(rrdGraphDef,true);
      graph.saveAsJPEG(RRDGRAPH + graphName, width, height, 1.0f);
    }
    catch (IOException e) {
      logger.log(Level.SEVERE,
                 "IO Exception error " + e.getMessage() + e.toString());
    }
    catch (RrdException e) {
      logger.log(Level.SEVERE,
                 "RRD Exception error " + e.getMessage() + e.toString());
    }
  }

  /**
   * @param graphName The name of the Graph that you wish to build, ensure a file extension is used if required.
   * @param graphTemplate The name of the template to use to build the graph, ensure a file extension is used if required.
   * @param quality Value between 0 and 1.0, 1.0 being highest.
   * This method is overloaded to provide flexability in use. The default is to produce a jpg file if not specified.
   */
  public void getGraph(String graphName, String graphTemplate, float quality,
                       long startTime, long endTime, String title) {
    try {
      RrdGraphDefTemplate rrdGraphTemplate = new RrdGraphDefTemplate(new File(
          RRDGRAPHDIRECTORY + graphTemplate));
      // set variables here
      rrdGraphTemplate.setVariable("rrdPath", RRDBDIRECTORY);
      rrdGraphTemplate.setVariable("startTime", startTime);
      rrdGraphTemplate.setVariable("endTime", endTime);
      rrdGraphTemplate.setVariable("title", title);
      RrdGraphDef rrdGraphDef = rrdGraphTemplate.getRrdGraphDef();
      RrdGraph graph = new RrdGraph(rrdGraphDef,true);
      graph.saveAsJPEG(RRDGRAPH + graphName, quality);
    }
    catch (IOException e) {
      logger.log(Level.SEVERE,
                 "IO Exception error " + e.getMessage() + e.toString());
    }
    catch (RrdException e) {
      logger.log(Level.SEVERE,
                 "RRD Exception error " + e.getMessage() + e.toString());
    }
  }

  /**
   * @param graphName The name of the Graph that you wish to build, ensure a file extension is used if required.
   * @param graphTemplate The name of the template to use to build the graph, ensure a file extension is used if required.
   * This invocation will produce the highest quality with the default sizes.
   * This method is overloaded to provide flexability in use. The default is to produce a jpg file if not specified.
   */
  public void getGraph(String graphName, String graphTemplate, long startTime,
                       long endTime, String title) {
    try {
      RrdGraphDefTemplate rrdGraphTemplate = new RrdGraphDefTemplate(new File(
          RRDGRAPHDIRECTORY + graphTemplate));
      // set variables here
      rrdGraphTemplate.setVariable("rrdPath", RRDBDIRECTORY);
      rrdGraphTemplate.setVariable("startTime", startTime);
      rrdGraphTemplate.setVariable("endTime", endTime);
      rrdGraphTemplate.setVariable("title", title);
      RrdGraphDef rrdGraphDef = rrdGraphTemplate.getRrdGraphDef();
      RrdGraph graph = new RrdGraph(rrdGraphDef,true);
      graph.saveAsJPEG(RRDGRAPH + graphName, 1.0f);
    }
    catch (IOException e) {
      logger.log(Level.SEVERE,
                 "IO Exception error " + e.getMessage() + e.toString());
    }
    catch (RrdException e) {
      logger.log(Level.SEVERE,
                 "RRD Exception error " + e.getMessage() + e.toString());
    }
  }

  /**
   * @param graphName The name of the Graph that you wish to build, ensure a file extension is used if required.
   * @param graphTemplate The name of the template to use to build the graph, ensure a file extension is used if required.
   * @param width The width of the image.
   * @param height The height of the image.
   * @param quality Value between 0 and 1.0, 1.0 being highest.
   * @param graphType Use 'PNG', 'JPEG' or 'GIF' as a string to request image type.
   * This method is overloaded to provide flexability in use.
   */
  public void getGraph(String graphName, String graphTemplate, int width,
                       int height, float quality, String graphType,
                       long startTime, long endTime, String title) {
    try {
      RrdGraphDefTemplate rrdGraphTemplate = new RrdGraphDefTemplate(new File(
          RRDGRAPHDIRECTORY + graphTemplate));
      // set variables here
      rrdGraphTemplate.setVariable("rrdPath", RRDBDIRECTORY);
      rrdGraphTemplate.setVariable("startTime", startTime);
      rrdGraphTemplate.setVariable("endTime", endTime);
      rrdGraphTemplate.setVariable("title", title);
      RrdGraphDef rrdGraphDef = rrdGraphTemplate.getRrdGraphDef();
      RrdGraph graph = new RrdGraph(rrdGraphDef,true);
      if (graphType == "PNG") {
        graph.saveAsPNG(RRDGRAPH + graphName, width, height);
      }
      else if (graphType == "JPEG") {
        graph.saveAsJPEG(RRDGRAPH + graphName, width, height, quality);
      }
      else if (graphType == "GIF") {
        graph.saveAsGIF(RRDGRAPH + graphName, width, height);
      }
    }
    catch (IOException e) {
      logger.log(Level.SEVERE,
                 "IO Exception error " + e.getMessage() + e.toString());
    }
    catch (RrdException e) {
      logger.log(Level.SEVERE,
                 "RRD Exception error " + e.getMessage() + e.toString());
    }
  }

  /**
   * @param graphName The name of the Graph that you wish to build, ensure a file extension is used if required.
   * @param graphTemplate The name of the template to use to build the graph, ensure a file extension is used if required.
   * @param width The width of the image.
   * @param height The height of the image.
   * @param quality Value between 0 and 1.0, 1.0 being highest.
   * @param graphType Use 'PNG', 'JPEG' or 'GIF' as a string to request image type.
   * This method is overloaded to provide flexability in use.
   */
  public void getGraph(RRDValueObject rrdVO) {
    try {
      String graphName;
      String graphTemplate;
      int width;
      int height;
      float quality;
      String graphType;
      long startTime;
      long endTime;
      String title;

      graphName = rrdVO.getGraphName();
      graphTemplate = rrdVO.getGraphTemplate();
      width = rrdVO.getWidth();
      height = rrdVO.getHeight();
      quality = rrdVO.getQuality();
      graphType = rrdVO.getGraphType();
      startTime = rrdVO.getStartTime();
      endTime = rrdVO.getEndTime();
      title = rrdVO.getTitle();

      RrdGraphDefTemplate rrdGraphTemplate = new RrdGraphDefTemplate(new File(
          RRDGRAPHDIRECTORY + graphTemplate + ".xml"));
      // set variables here
      rrdGraphTemplate.setVariable("rrdPath", RRDBDIRECTORY);
      if (startTime > 0) {
        rrdGraphTemplate.setVariable("startTime", startTime);
      }
      if (endTime > 0) {
        rrdGraphTemplate.setVariable("endTime", endTime);
      }
      if (title != null) {
        rrdGraphTemplate.setVariable("title", title);
      }
      RrdGraphDef rrdGraphDef = rrdGraphTemplate.getRrdGraphDef();
      RrdGraph graph = new RrdGraph(rrdGraphDef,true);

      if (graphType == "PNG") {
        graph.saveAsPNG(RRDGRAPH + graphName + ".png", width, height);
      }
      else if (graphType == "GIF") {
        graph.saveAsGIF(RRDGRAPH + graphName + ".gif", width, height);
      }
      else { //anthing else including jpg
        graph.saveAsJPEG(RRDGRAPH + graphName + ".jpg", width, height, quality);
      }

    }
    catch (IOException e) {
      logger.log(Level.SEVERE,
                 "IO Exception error " + e.getMessage() + e.toString());
    }
    catch (RrdException e) {
      logger.log(Level.SEVERE,
                 "RRD Exception error " + e.getMessage() + e.toString());
    }
    catch (IllegalArgumentException e) {
      logger.log(Level.SEVERE,
                 "Illegal Argument Exception error " + e.getMessage() + e.toString());

    }
  }
}
