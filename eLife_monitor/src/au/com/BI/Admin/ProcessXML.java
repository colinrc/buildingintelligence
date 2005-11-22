/*
 * Created on Dec 8 2004
 *
 */
package au.com.BI.Admin;
import java.io.*;
import java.net.*;

import java.util.logging.*;
import java.util.*;

import org.jdom.*;
import org.jdom.input.SAXBuilder;
import org.jdom.output.Format;
import org.jdom.output.XMLOutputter;
/**
 * @author Colin Canfield
 *
 **/
public class ProcessXML extends Thread
{
	
	public String IPAddress = "";
	public String devicePort = "10002";
	protected Level defaultDebugLevel = Level.INFO;
	protected boolean running = true;
	Logger logger;
	boolean gettingLines = false;
	protected String eSmart_install;
	protected Socket adminConnection;
	private InputStream in;
	private OutputStream out;
    private BufferedReader rd;
    private boolean isLoggedIn = true;
	
	public ProcessXML (Socket adminConnection,String eSmart_install) {
		logger = Logger.getLogger("eLife_monitor");
		this.eSmart_install = eSmart_install;
		try {
			synchronized (adminConnection) {
				this.adminConnection = adminConnection;
				in = adminConnection.getInputStream();
				out = adminConnection.getOutputStream();		        			
				rd = new BufferedReader(new InputStreamReader(in));
				doConnectionStartup();
			}
		} catch (IOException ex) {
			gettingLines = false;
		}
	}
	
	public void setGettingLines (boolean gettingLines){
		this.gettingLines = false;
		running = false;
	}
	
	public void doConnectionStartup() {
		String startupFile = getStartupFile(eSmart_install,out);
		if (startupFile != null) {
			try {
				String outString = "<STARTUP_FILE NAME=\""+startupFile+"\" />\n";
				synchronized (out){
					out.write (outString.getBytes());
					out.write((byte)0);
					out.flush();
				}
			} catch (IOException ex){};
		}
	}
	
	public void findSchemas (String dir, Vector fileList,Vector dirList) {
		File dirReader = new File(this.eSmart_install + "/" + dir);
		File files[] = dirReader.listFiles();
		if (files != null) {
			for (int i = 0; i < files.length; i ++ ) {
				String name = files[i].getName();
				if (name.startsWith(".") || name.equals("CVS"))
					continue;
				if (files[i].isDirectory()) {
					findSchemas (dir + "/" + name,fileList,dirList);
				}else {
					if (name.endsWith("xsd") || name.endsWith ("dtd")) {
						fileList.add(eSmart_install + "/" + dir + "/" + name);
						dirList.add(dir);
					}		
				}
			}
		}
	}
	
	public void findTemplates (String dir, Vector fileList,Vector dirList,String destDir) {
		File dirReader = new File(this.eSmart_install + "/" + dir);
		File files[] = dirReader.listFiles();
		if (files != null) {
			for (int i = 0; i < files.length; i ++ ) {
				String name = files[i].getName();
				if (name.startsWith(".") || name.equals("CVS"))
					continue;
				if (files[i].isDirectory()) {
					findTemplates (dir + "/" + name,fileList,dirList,destDir);
				}else {
					if (name.endsWith("xsd") || name.endsWith ("dtd") || name.endsWith("xml")) {
						fileList.add(eSmart_install + "/" + dir + "/" + name);
						dirList.add(destDir + "/" + dir);
					}		
				}
			}
		}
	}
	
	public void sendSchemas () {
		Vector fileList = new Vector (5);
		Vector dirList = new Vector (5);
		findSchemas ("server/templates" ,fileList,dirList);
		Object files[] = fileList.toArray();
		Object dirs[] = dirList.toArray();
		for (int i = 0; i < files.length; i ++ ) {
			downloadFile ((String)files[i],out,(String)dirs[i],"FILE_TRANSFER",false);
		}
		
	}
	
	public void sendTemplates () {
		Vector fileList = new Vector (5);
		Vector dirList = new Vector (5);
		findTemplates ("server/templates" ,fileList,dirList,"templates");
		Object files[] = fileList.toArray();
		Object dirs[] = dirList.toArray();
		for (int i = 0; i < files.length; i ++ ) {
			downloadFile ((String)files[i],out,(String)dirs[i],"FILE_TRANSFER",false);
		}
		
	}
		
	public void run () {
		StringBuffer soFar = new StringBuffer();
		int lenBuf = 1024;
		byte[] buf = new byte[lenBuf];
		boolean isConnected = true;

		sendSchemas();
		sendTemplates();
		while(isConnected) {
		    try {
				// play nice with the other threads and surrender the CPU
				Thread.sleep(1000);
			} catch (InterruptedException e) {}
			
		    // collect all the bytes waiting on the input stream
		    int avail;
			try {
				avail = in.available();

				while (avail > 0) {
					int amt = avail;
					if (amt > lenBuf) {
						amt = lenBuf;
					}
					amt = in.read(buf, 0, amt);
	
			        int marker = 0;
			        for (int i=0; i<amt; i++) {
			            // scan for the zero-byte EOM delimiter
			            if (buf[i] == (byte)0) {
			                String tmp = new String(buf, marker, i - marker);
			                soFar.append(tmp);
			                int length = soFar.length();
			                if (length > 0) {
			                		processBuffer ( soFar.toString().getBytes(),soFar.length(),out);
			                }
			                soFar.setLength(0);
			                marker = i + 1;
			            }
			        }
			        if (marker < amt) {
			            // save all so far, still waiting for the final EOM
			            soFar.append( new String(buf, marker, amt-marker) );
			        }
				avail = in.available();
				}
			} catch (IOException e) {
				isConnected = false;
		    		logger.log (Level.FINE,"Lost connection closing " + e.getMessage());
			}
		}
	}

	public void checkPassword (String user, String password){
		if (user != null && password != null && user.equals(password)){
			isLoggedIn = true;
		} else {
			isLoggedIn = false;
		}
	}
	
	public boolean processBuffer (byte [] readBuffer,int count,OutputStream output){
		SAXBuilder saxb = new SAXBuilder(false); //get a SAXBuilder
		Document xmlDoc;           // xml document object to work with

		logger.log(Level.FINEST,"Received string from client, processing");
		// the array sent to the XML builder cannot have any extra space at the end
		// so we create a new array and copy everything accumulated in "readBuffer"
		
		byte[] xmlByte = new byte[count];
		System.arraycopy(readBuffer,0,xmlByte,0,count);

		//build a Stream from the array
		ByteArrayInputStream bais = new ByteArrayInputStream(xmlByte);
		
		Process p = null;
		boolean abort = false;
		boolean commandFound = false;

		try {
		    Document newDoc = saxb.build(bais);
			Element topCommand = newDoc.getRootElement();
			String xmlName = topCommand.getName();
		    
		    if (xmlName.equals("HEARTBEAT")){
		    		commandFound = true;
		    }
		    if (xmlName.equals("USER")){
		    		checkPassword(topCommand.getAttributeValue("USER") ,topCommand.getAttributeValue("PASSWORD"));
	    			loginResult(output);

	    			commandFound = true;
		    } 
		    
		    if (!isLoggedIn && !commandFound) {
    				loginResult(output);
		    		return false; 
		    }
		    
		    if (!commandFound && xmlName.equals("ADMIN")){
		        String commandName = topCommand.getAttributeValue("COMMAND");
		        String dir = topCommand.getAttributeValue("DIR");
		        if (dir == null) dir = "";
		        String extra = topCommand.getAttributeValue("EXTRA");
		        if (extra == null) extra = "";
		        
		        if (commandName != null && !commandName.equals ("")) {			    
					if (commandName.equals ("START")) {
						logger.log (Level.INFO,"Starting eLife service");
						p = Runtime.getRuntime().exec ("net start eLife");
						displayProcessResults (p,output);
						commandFound = true;
					}
			
					if (commandName.equals ("STOP")) {
						logger.log (Level.INFO,"Stopping eLife service");
						p = Runtime.getRuntime().exec ("net stop eLife");			
						displayProcessResults (p,output);
						commandFound = true;
					}
			
					if (commandName.equals ("EXIT")) {
						logger.log (Level.INFO,"Stopping monitor service");
						synchronized (output){
							output.write (("<ADMIN>Stopping monitor service</ADMIN>\n").getBytes());	
						}
						abort = true;
						commandFound = true;
					}
					
					if (commandName.equals ("RESTART")) {
						logger.log (Level.INFO,"Restarting eLife service");
						p = Runtime.getRuntime().exec ("net stop eLife");
						displayProcessResults (p,output);
						p = Runtime.getRuntime().exec ("net start eLife");
						displayProcessResults (p,output);
						commandFound = true;
					}
					if (commandName.equals ("ARBITRARY")) {
					    if (!extra.equals("")){
					        logger.log (Level.FINER,"Running command " + extra);
							p = Runtime.getRuntime().exec (extra);
							displayProcessResults (p,output);
							commandFound = true;
					    } else {
							sendError ("Run command requested but no command was specified in the EXTRA field",output);	
						}
					}
					if (commandName.equals ("CLIENT_RESTART")) {
						logger.log (Level.INFO,"Restarting client service");
						p = Runtime.getRuntime().exec ("taskkill /F /IM elife.exe");			
						displayProcessResults (p,output);
						commandFound = true;
					}
					if (commandName.equals ("DOWNLOAD")) {
						String fileName = this.eSmart_install + "/" + dir + "/" + extra;
					    if (!extra.equals ("")) {
					        logger.log (Level.FINER,"Downloading XML file " + extra);

					        if (dir.indexOf("log") > 0) 
				        			downloadFile(fileName,output,dir,"FILE",true);
					        else
					        		downloadFile(fileName,output,dir,"FILE",false);
							commandFound = true;
						} else {
					        logger.log (Level.WARNING,"Illegal filename requested to download " + fileName);
							sendError ("Could not download file " + fileName,output);	
						}
					}
					if (commandName.equals ("UPLOAD")) {
				        logger.log (Level.FINER,"Uploading XML configuration file " + extra);
						commandFound = true;
	        			uploadFile (topCommand, output);
					}
					if (commandName.equals ("LIST")) {
					    if (!dir.equals ("") ) {
						    	String filter = topCommand.getAttributeValue("FILTER");
						    	if (filter == null) filter = "";
						    	logger.log (Level.FINER,"Listing directory " + dir);
						    String  fullPath = eSmart_install + "/" + dir; 
						    listDir (fullPath,dir, output,filter);
							commandFound = true;
						} else {
							sendError ("Directory list request did not contain DIR element",output);	
						}
					}
					if (commandName.equals ("DELETE")) {
					    if (!dir.equals ("") || !extra.equals ("")) {
				    			String fileName = eSmart_install + "/" + dir +"/" + extra;
						        logger.log (Level.FINER,fileName);
								File fileToDelete = new File(fileName);
								if (fileToDelete.delete()) {
									String returnString = "<DELETE RESULT=\"SUCCESS\" DIR=\"" + dir + "\">"+ extra + " deleted</DELETE>\n";
									synchronized (output){
										output.write (returnString.getBytes());
									}
								}
								else {
									sendError ("Could not delete file " + fileName ,output);	
								}
									
							commandFound = true;
						} else {
							sendError ("Delete requested but no filename was specified in the EXTRA field" ,output);	
						}
					}
					if (commandName.equals ("SELECT")) {
					    if (!extra.equals ("") ) {
					        logger.log (Level.FINER,"Setting XML configuration file for startup " + extra);
							commandFound = true;
					        if (!setBootstrapFile (this.eSmart_install,extra,output)) {
						        String returnString = "<SELECT>Startup file changed : " + extra + "</SELECT>\n";
								synchronized (output){ 
									output.write (returnString.getBytes());
								}
					        }
						} else {
					        logger.log (Level.WARNING,"Select XML configuration file requested, but no filename was specified in the EXTRA field");
						}
					}
			    }

		    }
			if (!commandFound) {
				sendError ("Unknown command" ,output);	
			}
			synchronized (output){
				output.write((byte)0);
				output.flush();
			}
		} catch (IOException io) {
			logger.log (Level.WARNING,"An IO error occured reading the XML file " + io.getMessage());
		} catch (JDOMException e) {
			sendError ("Invalid XML sent to monitor " + e.getMessage()  ,output);	
        }
		return abort;
	}

	public void downloadFile (String fileName, OutputStream output, String dir,String elementName,boolean base64Encode) {
		File fileToDownload = new File (fileName);
		
		try {
			if (fileToDownload.canRead()) {
				FileReader in = new FileReader (fileToDownload);
				StringBuffer soFar = new StringBuffer();
				char[] fileBuf = new char [4000];
				int currentOffset = 0;
				
				while (in.ready()) {
						int numberBytes = in.read (fileBuf,0,4000);
						if (numberBytes > -1) {
			                String tmp = new String(fileBuf, 0, numberBytes);
			                //currentOffset += numberBytes;
			                soFar.append(tmp);
						}
				}
				
				in.close();
				
				Document newDoc = new Document ();
				Element newRoot = new Element (elementName);
				newRoot.setAttribute("NAME",fileName);
				newRoot.setAttribute("DIR",dir);
				String fileStr = new String (soFar);
				fileStr = fileStr.trim();
				if (base64Encode) {
					newRoot.setAttribute("BASE64","Y");		
					fileStr = Base64Coder.encode(fileStr);
					
				} else {
					newRoot.setAttribute("BASE64","N");		

				}
				
				String checked = Verifier.checkCDATASection(fileStr);
				if (checked != null) {
					logger.log (Level.WARNING,"cdata error " + checked);
				}
				newRoot.addContent(new CDATA (fileStr));
				
				synchronized (output){
					XMLOutputter xmlOut = new XMLOutputter (Format.getPrettyFormat());
					xmlOut.output(newRoot, output) ;
					output.write((byte)0);
					output.flush();
				}
				
			} else {
				sendError ("Cannot read requested file " + fileName ,output);		

			}
		} catch (IOException e) {
			sendError ("Cannot read requested file " + fileName ,output);			
		}

	}
	
	public void loginResult(OutputStream output){
		Document newDoc = new Document ();
		Element newRoot = new Element ("LOGIN");
		if (isLoggedIn)
			newRoot.setAttribute("RESULT","Y");
		else 
			newRoot.setAttribute("RESULT","Y");

		try {
			synchronized (output){
				XMLOutputter xmlOut = new XMLOutputter (Format.getPrettyFormat());
				xmlOut.output(newRoot, output) ;
				output.write((byte)0);
				output.flush();
			}
		} catch (IOException ex){}
	}
	
	
	public String getStartupFile (String eSmart_install, OutputStream output) {
    	boolean errorCode = false;

    	String startupFile = null;
	try {
		String fileName = eSmart_install + "/server/datafiles/bootstrap.xml";
		File theFile = new File (fileName);
		
		SAXBuilder saxb = new SAXBuilder(false); 
		Document bootstrap = saxb.build (theFile);
		
		Element topBoot = bootstrap.getRootElement();
		Element bootup = topBoot.getChild("CONFIG_FILE");
		
		startupFile = bootup.getAttributeValue("NAME");
		
			
	} catch (IOException e) {
		sendError ("IO Error writing the file " + e.getMessage(),output);

	} catch (JDOMException e1) {
		sendError ("XML parse error on the bootstrap file " + e1.getMessage(),output);
	}


	return startupFile;
    }
	

	
    public boolean setBootstrapFile (String eSmart_install, String extra,OutputStream output) {
    	boolean errorCode = false;
	try {
		String fileName = eSmart_install + "/server/datafiles/bootstrap.xml";
		File theFile = new File (fileName);
		
		SAXBuilder saxb = new SAXBuilder(false); 
		Document bootstrap = saxb.build (theFile);
		
		Element topBoot = bootstrap.getRootElement();
		Element bootup = topBoot.getChild("CONFIG_FILE");
		bootup.setAttribute("NAME",extra);
		
		File fileToUpload = new File (fileName+".new");
		Document doc = new Document ();
		topBoot.detach();
		doc.setRootElement(topBoot);

		XMLOutputter xmlOut = new XMLOutputter (Format.getPrettyFormat());
		FileWriter out = new FileWriter(fileToUpload);
		xmlOut.output(doc, out) ;
		out.flush();
		out.close();
		logger.log (Level.FINE,"File write succeeded.");
		
		File oldFile = new File (fileName);
		File newName = new File (fileName+".old");
		
		if (oldFile.exists()) {
		    if (newName.exists() && !newName.delete()) {
				sendError ("Could not delete old file "+oldFile.getName(),output);

				errorCode = true;
			    logger.log (Level.SEVERE, "Could not delete old file "+oldFile.getName());
		    }
			if (!oldFile.renameTo (newName)) { 
				sendError ("Could not rename new file "+fileToUpload.getName()+" to " + oldFile.getName(),output);
			    logger.log (Level.SEVERE, "Could not rename old file "+oldFile.getName()+" to " + newName.getName());
				errorCode = true;
			}
		}

		if (!fileToUpload.renameTo(oldFile)) {
			sendError ("Could not rename new file "+fileToUpload.getName()+" to " + oldFile.getName(),output);
		    logger.log (Level.SEVERE, "Could not rename new file "+fileToUpload.getName()+" to " + oldFile.getName());
			errorCode = true;
		}
			    
		File finalName = new File (fileName+".old");
	    if (finalName.exists() && !finalName.delete()) {
			sendError ("Could not delete old file "+finalName.getName(),output);

		    logger.log (Level.SEVERE, "Could not delete old file "+finalName.getName());
			errorCode = true;
	    }
		synchronized (output){
			output.write((byte)0);
			output.flush();
		}

			
	} catch (IOException e) {
		sendError ("IO Error writing the file " + e.getMessage(),output);
		errorCode = true;
	} catch (JDOMException e1) {
		sendError ("XML parse error on the bootstrap file " + e1.getMessage(),output);
		errorCode = true;

	}


	return errorCode;
    }
    
    public void sendError (String error,OutputStream output){
    		String wholeMessage = "<ERROR><![CDATA["+error+" ]]></ERROR>\n";
    		try {
    			synchronized (output){
		    		output.write (wholeMessage.getBytes());
		    		output.write(0);
		    		output.flush();
    			}
	    	} catch (IOException io){};
    	}

	public void uploadFile (Element messageXML, OutputStream output) {
		try {
			String dir = messageXML.getAttributeValue("DIR");
			String fileName = messageXML.getAttributeValue ("NAME");
			String theFile = messageXML.getText();
			
			String fullPath = eSmart_install + "/" + dir + "/" + fileName;

			File fileToUpload = new File (fullPath+".new");
			
			if (!fileToUpload.exists () || fileToUpload.canWrite()) {
				FileWriter out = new FileWriter (fileToUpload);
					
				out.write(theFile);
				out.close();
		
				logger.log (Level.FINE,"File write succeeded.");
				
				File oldFile = new File (fullPath);
				File newName = new File (fullPath+".old");
				
				if (oldFile.exists()) {
				    if (newName.exists() && !newName.delete()) {
						synchronized (output){
							output.write (("<UPLOAD RESULT=\"ERROR\">Could not delete old file "+oldFile.getName() + "</UPLOAD>\n").getBytes());
						}
					    logger.log (Level.SEVERE, "Could not delete old file "+oldFile.getName());
				    }
					if (!oldFile.renameTo (newName)) { 
						synchronized (output){
							output.write (("<UPLOAD RESULT=\"ERROR\">Could not rename new file "+fileToUpload.getName()+" to " + oldFile.getName() + "</UPLOAD>\n").getBytes());
						}
					    logger.log (Level.SEVERE, "Could not rename old file "+oldFile.getName()+" to " + newName.getName());
					    
					}
				}
	
				if (!fileToUpload.renameTo(oldFile)) {
					synchronized (output){
						output.write (("<UPLOAD RESULT=\"ERROR\">Could not rename new file "+fileToUpload.getName()+" to " + oldFile.getName() + "</UPLOAD>\n").getBytes());
					}
				    logger.log (Level.SEVERE, "Could not rename new file "+fileToUpload.getName()+" to " + oldFile.getName());
				}
					    
				File finalName = new File (fullPath+".old");
			    if (finalName.exists() && !finalName.delete()) {
					synchronized (output){
						output.write (("<UPLOAD RESULT=\"ERROR\">Could not delete old file "+finalName.getName() + "</UPLOAD>\n").getBytes());
					}
				    logger.log (Level.SEVERE, "Could not delete old file "+finalName.getName());
			    }
				synchronized (output){
					String message = "<UPLOAD RESULT=\"SUCCESS\" DIR=\"" + dir + "\" />\n";
					output.write (message.getBytes());
				}
			} else {
				String message = "<UPLOAD RESULT=\"ERROR\">Cannot write " + fileName + "</UPLOAD>\n";
				synchronized (output){
					output.write (message.getBytes());
				}
			}

			synchronized (output){
				output.write((byte)0);
				output.flush();
			}
				
		} catch (IOException e) {
			try {
				synchronized (output){
					output.write (("<UPLOAD RESULT=\"ERROR\">IO Error writing the file " + e.getMessage() + "</UPLOAD>\n").getBytes());
					output.write((byte)0);
					output.flush();
				}
			} catch (IOException e1) {

			}
		}
	}
	
	public void displayProcessResults (Process p, OutputStream output) {
		if (p != null ) {
			String s= "";
			BufferedReader stdInput = new BufferedReader (new InputStreamReader (p.getInputStream()));
			BufferedReader stdError = new BufferedReader (new InputStreamReader (p.getErrorStream()));
			try {
				String outLine = "<EXEC>\n";
				outLine += "<EXEC_OUTPUT>\n";
				outLine += "<![CDATA[";
				while ((s = stdInput.readLine()) != null) {
					outLine += s + "\n";
				}
				outLine += " ]]>\n";
				outLine += "</EXEC_OUTPUT>\n";
				
				outLine +="<EXEC_ERROR>\n";
				outLine += "<![CDATA[";
				while ((s = stdError.readLine()) != null) {
					outLine += s + "\n";
				}
				outLine += " ]]>\n";
				outLine += "</EXEC_ERROR>\n";
				outLine += "</EXEC>\n";
				synchronized (output){
					output.write (outLine.getBytes());
					output.write((byte)0);
					output.flush();
				}
			} catch (IOException e) {

			}
		}
	}
	
	private class MyFilenameFilter implements FilenameFilter  {
		private String filterStr;
		private boolean wildcard = false;
		
		public void setFilterStr (String filterStr) {
			this.filterStr = filterStr;
			if (filterStr.indexOf('*') >= 0) wildcard = true;
			if (filterStr.indexOf('?') >= 0) wildcard = true;
			
		}
		
        public boolean accept(File dir, String name) {
        		if (!wildcard) {
        			return name.endsWith(filterStr);
        		}
        		else {
        			return name.matches(filterStr);
        		}
        }
		
	}
	
	public void listDir (String dir,String lastPath, OutputStream output,String filterStr) {
		MyFilenameFilter filter = new MyFilenameFilter();
	    filter.setFilterStr (filterStr);
	
		File dirReader = new File(dir);
		if (!dirReader.canRead()) {
			logger.log(Level.WARNING,"Could not open the directory " + dir);
			sendError ("Could not open directory " + dir,output);	

		}
		File [] files;
		if (!filterStr.equals (""))
			files = dirReader.listFiles(filter);
		else
			files = dirReader.listFiles();
			
		SAXBuilder saxb = new SAXBuilder(false); 
		try {
			String lineHeader = "<FILES DIR=\""+lastPath+"\" >"; 
			
			if (files != null) {
				for (int i = 0; i < files.length; i ++ ) {
					String name = files[i].getName();
					long timeStamp = files[i].lastModified();
					long fileLength = files[i].length();
					String desc = "";
					if (name.endsWith("xml")) {
						try {
							Document newDoc = saxb.build (files[i]);
							if (newDoc != null) {
								Element root = newDoc.getRootElement();
								if (root != null) desc = root.getChildText("DESC");
							}
						} catch (JDOMException je) {
							logger.log (Level.WARNING,"Error in XML file " + name + " " + je.getMessage());
						} catch (IOException e) {
							logger.log (Level.WARNING,"Error in XML file " + name + " " + e.getMessage());
						}
					} 
						
					if (desc == null) desc = "";
					lineHeader += "<FILE NAME=\""+name+"\" DESC=\"" + desc + "\" MOD=\"" + timeStamp +"\" LENGTH=\"" + fileLength + "\" />";
						

				}
			}
			lineHeader += "</FILES >\n";
			synchronized (output){
				output.write(lineHeader.getBytes());
				output.write((byte)0);
				output.flush();
			}
		} catch (IOException e) {
			logger.log (Level.WARNING,"Could not list directory " + e.getMessage());
		}
	}

}