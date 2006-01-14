/*
 * Created on Feb 8, 2004
 *
 */
package au.com.BI.AWTHarness;

/**
 * @author Colin Canfield
 *
 **/
import java.awt.*;
import au.com.BI.Util.*;

import java.util.*;
import au.com.BI.User.User;
import au.com.BI.Command.*;
import au.com.BI.Comms.*;
import au.com.BI.Config.Bootstrap;
import au.com.BI.Config.ConfigHelper;
import au.com.BI.GC100.IRCodeDB;
import au.com.BI.Macro.*;
import javax.swing.*;
import javax.swing.border.*;
import java.util.logging.*;

public class AWTHarness extends JFrame implements DeviceModel , GUIModel
{
	public JButton exitButton;
	public JButton flashButton;
	public JButton readConfig;
	public JButton pause;
	public JButton learnIR;
        public JButton loadScripts;

	public Box debugPanel;


	protected Map rawDefs;

	public Box    messagePanel;
	public JTextArea messageAreaOut;
	public JTextArea messageAreaIn;
	protected AWTListener guiHandler;
	protected HashMap controlledItems;
	protected HashMap outputItems;
	protected Logger logger;
	protected java.util.List commandQueue;
	protected String name;
	protected String serialPort;
	protected ConfigHelper configHelper;
	protected HashMap parameters;
	protected ArrayList debugMenus;
	protected Level defaultLevel = Level.INFO;
	protected MacroHandler macroHandler;
	protected Collection modelList;
	protected Bootstrap bootstrap;

	protected int instanceID;

	protected au.com.BI.Command.Cache cache;

	public int connectionType = DeviceModel.IP;
	public String IPAddress = "";
	public String devicePort = "10000";

	protected String displayName;
	protected Container contentsPane;
	protected JScrollPane scrollPaneIn;

	final int HEIGHT = 500;
	final int WIDTH  = 800;

	public  AWTHarness ()
	{
		debugMenus = new ArrayList (10);

		//		 Set to exit on close
	    this.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);

		Dimension screenSize = Toolkit.getDefaultToolkit().getScreenSize();
		guiHandler = new AWTListener ();
		guiHandler.setAWTHarness(this);
		setSize(WIDTH, HEIGHT);

		Color backgroundColor = new Color (29,75,152);

		this.setTitle("Building Intelligence");
		contentsPane  = this.getContentPane();
		//contentsPane.setBackground(backgroundColor);
		contentsPane.setLayout(new BoxLayout(contentsPane,BoxLayout.PAGE_AXIS));

		messageAreaIn = new JTextArea();
		scrollPaneIn = new JScrollPane (messageAreaIn);
		//scrollPaneIn.getViewport().setBackground(Color.BLUE);
		scrollPaneIn.setVerticalScrollBarPolicy(JScrollPane.VERTICAL_SCROLLBAR_ALWAYS);
		scrollPaneIn.setHorizontalScrollBarPolicy(JScrollPane.HORIZONTAL_SCROLLBAR_ALWAYS);
		scrollPaneIn.setPreferredSize(new Dimension(WIDTH-20,HEIGHT-180));
    		scrollPaneIn.setMinimumSize(new Dimension(10, 10));
		messageAreaIn.setEditable(false);

		TitledBorder scrollBorder = BorderFactory.createTitledBorder(BorderFactory.createBevelBorder(BevelBorder.LOWERED),"Debug trace");
		//scrollBorder.setTitleColor(Color.WHITE);
		scrollPaneIn.setBorder(scrollBorder);
		contentsPane.add(scrollPaneIn);

		debugPanel = new Box(BoxLayout.LINE_AXIS);
		debugPanel.setPreferredSize(new Dimension(WIDTH-10,124));

		debugPanel.add (Box.createRigidArea(new Dimension(5,50)));
		TitledBorder debugBorder = BorderFactory.createTitledBorder(BorderFactory.createBevelBorder(BevelBorder.LOWERED),"Debug Level");
		//debugBorder.setTitleColor(Color.WHITE);
		debugPanel.setBorder(debugBorder);
		contentsPane.add (debugPanel);


		Box buttonPanel = new Box(BoxLayout.X_AXIS);

		exitButton = new JButton("Exit");
		exitButton.addActionListener(guiHandler);
		buttonPanel.add(exitButton);

		readConfig = new JButton("Read Configuration");
		readConfig.addActionListener(guiHandler);
		readConfig.setEnabled(true);
		buttonPanel.add(readConfig);

        loadScripts = new JButton("Load Scripts");
        loadScripts.addActionListener(guiHandler);
        loadScripts.setEnabled(true);
        buttonPanel.add(loadScripts);

		learnIR = new JButton("Learn IR");
		learnIR.addActionListener(guiHandler);
		learnIR.setEnabled(true);
		buttonPanel.add(learnIR);

		buttonPanel.add (Box.createHorizontalStrut(5));

		JTextField irName = new JTextField(12);
		irName.setMaximumSize(new Dimension (200,24));
		irName.setText("AV Device Name.Action");
		irName.setActionCommand ("irName");
		irName.addActionListener(guiHandler);
		guiHandler.setIrNameField (irName);
		buttonPanel.add(irName);
		buttonPanel.add (Box.createHorizontalStrut(5));

		pause = new JButton("Pause Logging");
		pause.addActionListener(guiHandler);
		pause.setEnabled(true);
		buttonPanel.add(pause);

		//buttonPanel.setBackground(backgroundColor);

		contentsPane.add (buttonPanel);
		setLocation(screenSize.width/2 - WIDTH/2,
				screenSize.height/2 - HEIGHT/2);

		configHelper = new ConfigHelper ();
		configHelper.addControlledItem("READ_CONFIG_BUTTON",readConfig,DeviceType.MONITORED);

		rawDefs = new HashMap (NUMBER_CATALOGUES);
		parameters = new HashMap (NUMBER_PARAMETERS);

		Logger globalLogger = Logger.getLogger("au.com.BI");
		LogHandler logHandler = new LogHandler (this);
		globalLogger.addHandler(logHandler);
		guiHandler.setLogHandler(logHandler);
		globalLogger.setLevel(this.defaultLevel);
	}

	public void addDebugMenu (String fullClassName) {
		int lastSeperator = fullClassName.lastIndexOf('.');
		String packageName = fullClassName.substring(0,lastSeperator);
		this.addPackageDebugMenu(packageName);
		contentsPane.validate();
	}

	public void addPackageDebugMenu (String packageName) {

		int lastSeperator = packageName.lastIndexOf('.');
		String packageShortName = "";
		packageShortName = packageName.substring(lastSeperator+1);
		if (packageShortName.equals("BI"))
			packageShortName = "Global";

		Logger logger = Logger.getLogger(packageName);
		logger.setLevel(defaultLevel);

		DefaultListModel theList = new DefaultListModel ();
		theList.addElement("Info");
		theList.addElement("Fine");
		theList.addElement("Finer");
		theList.addElement("Finest");

		JList newMenu = new JList (theList);
		newMenu.setBorder(BorderFactory.createTitledBorder(BorderFactory.createEtchedBorder(Color.LIGHT_GRAY,Color.BLUE),packageShortName));
		newMenu.setSelectionMode(ListSelectionModel.SINGLE_SELECTION);
		newMenu.setLayoutOrientation(JList.VERTICAL_WRAP);
		newMenu.setSelectedIndex(0);
		newMenu.setVisibleRowCount(4);
		newMenu.setName(packageName);
		newMenu.addListSelectionListener(guiHandler);
		debugPanel.add(Box.createVerticalGlue());
		debugPanel.add (newMenu);
		debugPanel.add(Box.createRigidArea(new Dimension(3,0)));

	}


	public void addDebugMenu (ArrayList objectList) {
		Iterator eachClass = objectList.iterator();
		while (eachClass.hasNext()) {
			String className = eachClass.next().getClass().getName();
			addDebugMenu (className);
		}
		contentsPane.validate();
	}

	public void clearDebugMenus () {
		debugPanel.removeAll();
		contentsPane.validate();
	}

	public boolean touchPanel () {
		return false;
	}

	public JTextArea getLogPane () {
		return messageAreaIn;
	}

	public void clearItems () {
		configHelper.clearItems();
	}


	public void setCache (au.com.BI.Command.Cache cache){
		this.cache = cache;
	}

        public void setVariableCache(HashMap variableCache){
        }

	public void IRLearnComplete () {
	    synchronized (learnIR){
	        learnIR.setEnabled(true);
	    }
	}

	public void attatchComms(java.util.List commandQueue) {
		// meaningless for this
	}
	/**
	 * Name is used by the config reader to tie a particular device to configuration
	 * @param name The identifying string for this device handler
	 */
	public void setName (String name) {
		this.name = name;
	}

	public void doClientStartup(java.util.List commandQueue, long targetFlashDeviceID){};
	public void doStartup(java.util.List commandQueue){};

	public boolean reEstablishConnection () {
		//if this one has dropped out the app is dead so panic
		return false;
	}

	public String getName() {
		return name;
	}

	/**
	 Closes the connection	 */
	public void closeComms() throws ConnectionFail {
	}

	public void setCommandQueue (java.util.List commandQueue) {
		this.commandQueue = commandQueue;
	}

	public int login (User user) throws CommsFail {
		return DeviceModel.SUCCESS; // No security for the GUI
	}

	public int logout (User user) throws CommsFail {
		return DeviceModel.SUCCESS; // No security for the GUI
	}

	public void setSerialPort (String serialPort){
		this.serialPort = serialPort;
	}

	public void enableAllFunctions () {
	}

	public void start (){
		logger = Logger.getLogger(this.getClass().getPackage().getName());
		guiHandler.setControllerInfo(commandQueue);
		guiHandler.setMessageAreaOut(messageAreaOut);
		guiHandler.setFrame (this);
		guiHandler.run();
	}

	public void addControlledItem (String name, Object details, int controllType){
		configHelper.addControlledItem (name, details, controllType);
	}


	public boolean doIControl (String key,boolean isClientCommand){
		if (configHelper.checkForControlledItem(key)) {
			logger.info ("AWT controlls " + key);
			return true;
		}
		else {

		        return false;
		}
	}

	public void doCommand (CommandInterface command){

	}

	/**
	 * @return Returns the connectionType.
	 */
	public final int getConnectionType() {
		return connectionType;
	}
	/**
	 * @param connectionType The connectionType to set.
	 */
	public final void setConnectionType(int connectionType) {
		this.connectionType = connectionType;
	}


	/**
	 * @return Returns the rawDefs.
	 */
	public final Map getCatalogueDef(String name) {
		return (Map)rawDefs.get (name);
	}
	/**
	 * @param rawDefs The rawDefs to set.
	 */
	public final void setCatalogueDefs(String name, Map rawDefs) {
		this.rawDefs.put (name,rawDefs);
	}

	public void setParameter (String name, Object value, String groupName) {
		parameters.put(name,value);
	}

	/**
	 * Groups are ignored for AWT
	 */
	public Object getParameter (String Name, String groupName){
		return parameters.get(name);
	}
	/**
	 * @return Returns the instanceID.
	 */
	public int getInstanceID() {
		return instanceID;
	}
	/**
	 * @param instanceID The instanceID to set.
	 */
	public void setInstanceID(int instanceID) {
		this.instanceID = instanceID;
	}

	public void addStartupQueryItem (String name, Object details, int controlType){};

	public void finishedReadingConfig () {};

	/**
	 * @return Returns the displayName.
	 */
	public String getDisplayName() {
		return displayName;
	}
	/**
	 * @param displayName The displayName to set.
	 */
	public void setDescription(String displayName) {
		this.displayName = displayName;
	}

	public void close () {}

	public boolean doIPHeartbeat () {
	    return false;
	}

	public boolean doIControlIR () {
	    return false;
	}

	public void setIrLearner (DeviceModel irLearner) {
	    guiHandler.setIrLearner (irLearner);
	}

    /**
     * @return Returns the irCodeDB.
     */
    public IRCodeDB getIrCodeDB() {
        return null;
    }
    /**
     * @param irCodeDB The irCodeDB to set.
     */
    public void setIrCodeDB(IRCodeDB irCodeDB) {
    }
    /**
     * @return Returns the gUIModel.
     */
    public GUIModel getGUIModel() {
        return null;
    }
    /**
     * @param model The gUIModel to set.
     */
    public void setGUIModel(GUIModel model){};


    public boolean isGUI() {
        return true;
    }
    /**
     * @return Returns the macroHandler.
     */
    public MacroHandler getMacroHandler() {
        return macroHandler;
    }
    /**
     * @param macroHandler The macroHandler to set.
     */
    public void setMacroHandler(MacroHandler macroHandler) {
        this.macroHandler = macroHandler;
    }

    public boolean removeModelOnConfigReload () {
    	return false;
    }
	/**
	 * @return Returns the modelList.
	 */
	public Collection getModelList() {
		return modelList;
	}
	/**
	 * @param modelList The modelList to set.
	 */
	public void setModelList(Collection modelList) {
		this.modelList = modelList;
	}

	/**
	 * @return Returns the configHelper.
	 */
	public ConfigHelper getConfigHelper() {
		return configHelper;
	}
	/**
	 * @param configHelper The configHelper to set.
	 */
	public void setConfigHelper(ConfigHelper configHelper) {
		this.configHelper = configHelper;
	}
	/**
	 * @return Returns the defaultLevel.
	 */
	public Level getDefaultLevel() {
		return defaultLevel;
	}
	/**
	 * @param defaultLevel The defaultLevel to set.
	 */
	public void setDefaultLevel(Level defaultLevel) {
		this.defaultLevel = defaultLevel;
	}

	/**
	 * @return Returns the bootstrap.
	 */
	public Bootstrap getBootstrap() {
		return bootstrap;
	}
	/**
	 * @param bootstrap The bootstrap to set.
	 */
	public void setBootstrap(Bootstrap bootstrap) {
		this.bootstrap = bootstrap;
	}

	public boolean isConnected () {
		return true;
	}
	
	public void setConnected(boolean value) {}
	
	public String getHeartbeatString () {
		return "\n";
	}
	
	public boolean isTryingToConnect() {
		return false;
	}

	public void setTryingToConnect(boolean tryingToConnect) {};

}


