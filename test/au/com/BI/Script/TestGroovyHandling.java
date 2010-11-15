package au.com.BI.Script;


import static org.junit.Assert.*;
import org.junit.Before;
import org.junit.Test;

import java.util.*;

import au.com.BI.Command.Cache;
import au.com.BI.Command.Command;
import au.com.BI.Command.CommandInterface;
import au.com.BI.Command.CommandQueue;
import au.com.BI.LabelMgr.LabelMgr;

public class TestGroovyHandling {
	Model scriptModel = null;
	ScriptHandler sciptHandler = null;
	Map scriptRunBlockList = null;
	LabelMgr labelMgr = null;
	Cache cache = null;
	

	public void setUp() throws Exception {

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

	// FIXME null pointer exception on test
	public void testSetStatus() {
		// 
		scriptModel.getGroovyScriptHandler().setStatus("TimeTest","HIDDEN,OTHER,SOME");
		scriptModel.loadGroovyScripts();
		GroovyScriptRunBlock scriptRunBlock = (GroovyScriptRunBlock)scriptRunBlockList.get("TimeTest");
		assertEquals("HIDDEN,OTHER,SOME",scriptRunBlock.getStatusString());

	}

	@Test
	public void testSetScriptEnable() {
		// 

	}

	@Test
	public void testIsScriptStillRunning() {
		// 

	}

	@Test
	public void testBuildListElement() {
		// 

	}

	@Test
	public void testParseElement() {
		// 

	}

	@Test
	public void testIsScriptRunning() {
		// 

	}
	
	// FIXME null pointer exception on test
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
