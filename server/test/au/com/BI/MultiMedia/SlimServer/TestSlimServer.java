package au.com.BI.MultiMedia.SlimServer;

import static org.junit.Assert.assertEquals;

import org.junit.Before;
import org.junit.Test;

import au.com.BI.MultiMedia.SlimServer.Commands.BrowseAlbums;
import au.com.BI.MultiMedia.SlimServer.Commands.BrowseAlbumsReply;
import au.com.BI.MultiMedia.SlimServer.Commands.Login;
import au.com.BI.MultiMedia.SlimServer.Commands.SlimServerCommand;
import au.com.BI.MultiMedia.SlimServer.Commands.SlimServerCommandFactory;

public class TestSlimServer {
	
	private SlimServerCommandFactory factory;
	
	@Before
	public void setUp() {
		factory = SlimServerCommandFactory.getInstance();
	}
	
	@Test
	public void login() {
		Login login = new Login();
		assertEquals("login", login.buildCommandString());
		login.setUser("admin");
		login.setPassword("admin");
		assertEquals("login admin admin", login.buildCommandString());
	}
	
	@Test
	public void browseAlbums() {
		BrowseAlbums browseAlbums = new BrowseAlbums();
		browseAlbums.setStart(0);
		browseAlbums.setItemsPerResponse(20);
		browseAlbums.setArtist(2);
		browseAlbums.setCompilation(false);
		assertEquals(browseAlbums.buildCommandString(),"albums 0 20 artist_id:2 compilation:0");
		
		browseAlbums.setGenre(0);
		assertEquals(browseAlbums.buildCommandString(),"albums 0 20 genre_id:0 artist_id:2 compilation:0");
	}
	
	@Test
	public void browseAlbumsReply() {
		String commandReply = "albums 0 5 compilation%3A0 count%3A770 id%3A325 album%3A003%20Nick%20Warren%20-%20Live%20In%20Prague%20Disk%201 id%3A326 album%3A003%20Nick%20Warren%20-%20Live%20In%20Prague%20Disk%202 id%3A419 album%3A02.02.01 id%3A245 album%3AThe%2006%20Remix id%3A455 album%3A10";
		SlimServerCommand command = factory.getCommand(commandReply);
		assertEquals(command.getClass(), BrowseAlbumsReply.class);
		
		BrowseAlbumsReply reply = (BrowseAlbumsReply)command;
		assertEquals(reply.getCount(),770);
		assertEquals(reply.getAlbums().size(),5);
		assertEquals(reply.getAlbums().get(0).getAlbum(),"003 Nick Warren - Live In Prague Disk 1");
	}
}
