package au.com.BI.MultiMedia.SlimServer;

import static org.junit.Assert.assertEquals;

import java.util.LinkedList;

import org.junit.Before;
import org.junit.Test;

import au.com.BI.MultiMedia.SlimServer.Commands.AlbumTag;
import au.com.BI.MultiMedia.SlimServer.Commands.BrowseAlbums;
import au.com.BI.MultiMedia.SlimServer.Commands.BrowseAlbumsReply;
import au.com.BI.MultiMedia.SlimServer.Commands.BrowseArtists;
import au.com.BI.MultiMedia.SlimServer.Commands.BrowseArtistsReply;
import au.com.BI.MultiMedia.SlimServer.Commands.BrowseGenres;
import au.com.BI.MultiMedia.SlimServer.Commands.Login;
import au.com.BI.MultiMedia.SlimServer.Commands.PlayListCommand;
import au.com.BI.MultiMedia.SlimServer.Commands.PlayListControl;
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
		browseAlbums.setTags(new LinkedList<AlbumTag>());
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
	
	@Test
	public void playListControl() {
		PlayListControl control = new PlayListControl();
		control.setCommand(PlayListCommand.ADD);
		control.setPlayerId("65:4a:5e:d9:df:91");
		assertEquals(control.buildCommandString(),"65%3A4a%3A5e%3Ad9%3Adf%3A91 playlistcontrol cmd:add");
		
		control.setAlbum_id(325);
		assertEquals(control.buildCommandString(),"65%3A4a%3A5e%3Ad9%3Adf%3A91 playlistcontrol cmd:add album_id:325");
	}
	
	@Test
	public void browseArtists() {
		BrowseArtists browse = new BrowseArtists();
		browse.setStart(0);
		browse.setItemsPerResponse(20);
		browse.setAlbum(20);
		assertEquals(browse.buildCommandString(),"artists 0 20 album_id:20");
	}
	
	@Test
	public void browseArtistsReply() {
		String commandReply = "artists 0 5 count%3A7 id%3A2 artist%3AAnastacia id%3A3 artist%3ACalogero id%3A4 artist%3AEvanescence id%3A5 artist%3ALeftfield%20%26%20Lydon id%3A18 artist%3ALlorca";
		SlimServerCommand command = factory.getCommand(commandReply);
		assertEquals(command.getClass(), BrowseArtistsReply.class);
		
		BrowseArtistsReply reply = (BrowseArtistsReply)command;
		assertEquals(reply.getCount(),7);
		assertEquals(reply.getArtists().get(0).getId(),"2");
		assertEquals(reply.getArtists().get(0).getArtist(),"Anastacia");
	}

	@Test
	public void browseGenres() {
		BrowseGenres browse = new BrowseGenres();
		browse.setStart(0);
		browse.setItemsPerResponse(20);
		browse.setAlbum(20);
		browse.setArtist(2);
		assertEquals(browse.buildCommandString(),"genres 0 20 artist_id:2 album_id:20");
	}
	
}
