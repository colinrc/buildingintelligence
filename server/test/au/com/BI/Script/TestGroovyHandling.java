package au.com.BI.Script;

import junit.framework.TestCase;
import java.util.*;

import au.com.BI.Command.Cache;
import au.com.BI.Command.Command;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Command.CommandQueue;
import au.com.BI.LabelMgr.LabelMgr;

public class TestGroovyHandling extends TestCase {
	Model scriptModel = null;
	ScriptHandler sciptHandler = null;
	Map scriptRunBlockList = null;
	LabelMgr labelMgr = null;
	Cache cache = null;
	

	protected void setUp() throws Exception {
		super.setUp();
		scriptModel = new Model();
		labelMgr = new LabelMgr();
		CommandQueue commandQueue = new CommandQueue();
		cache = new Cache(null);
		scriptModel.setCommandQueue(commandQueue);
		scriptModel.setCache(cache);
		scriptModel.setLabelMgr(labelMgr);
		scriptModel.loadGroovyScripts();
		sciptHandler = scriptModel.getScriptHandler();
		scriptRunBlockList = scriptModel.groovyScriptRunBlockList;
	}

	protected void tearDown() throws Exception {
		super.tearDown();
	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.loadScriptFile()'
	 */
	public void testLoadScriptFile() {
		// 

	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.saveScriptFile()'
	 */
	public void testSaveScriptFile() {
		// 

	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.setStatus(String, String)'
	 */
	public void testSetStatus() {
		// 
		scriptModel.getGroovyScriptHandler().setStatus("TimeTest","HIDDEN,OTHER,SOME");
		scriptModel.loadGroovyScripts();
		GroovyScriptRunBlock scriptRunBlock = (GroovyScriptRunBlock)scriptRunBlockList.get("TimeTest");
		assertEquals("HIDDEN,OTHER,SOME",scriptRunBlock.getStatusString());

	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.setScriptEnable(String, User, boolean)'
	 */
	public void testSetScriptEnable() {
		// 

	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.isScriptStillRunning(String)'
	 */
	public void testIsScriptStillRunning() {
		// 

	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.buildListElement(String)'
	 */
	public void testBuildListElement() {
		// 

	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.parseElement(Element)'
	 */
	public void testParseElement() {
		// 

	}

	/*
	 * Test method for 'au.com.BI.Script.ScriptHandler.isScriptRunning(String)'
	 */
	public void testIsScriptRunning() {
		// 

	}
	

	public void testRunScript() {
		// 
		CommandInterface triggeringCommand = new Command();
		triggeringCommand.setDisplayName("DLT_1");
		triggeringCommand.setCommand("on");
		labelMgr.setLabelState("DLT_1", "ON");
		scriptModel.loadGroovyScripts();
		ScriptParams params = new ScriptParams("", null);
		params.setTriggeringCommand(triggeringCommand);
		
		GroovyScriptRunBlock scriptRunBlock = (GroovyScriptRunBlock)scriptRunBlockList.get("TimeTest");
		
		scriptModel.groovyScriptHandler.runScript(scriptRunBlock, scriptModel, params,false);
	}
	

}
