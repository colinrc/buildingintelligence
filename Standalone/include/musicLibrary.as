openMusicLibrary = function (key) {
	var window_mc = showWindow({width:"full", height:"full", title:"Music Library", iconName:"find"});
	_global.windows["openMusicLibrary"] = "open";
	window_mc.onClose = function () {
		unsubscribe(this.key, this);
		delete _global.windows["openMusicLibrary"];
		for (var i=0; i<this.contentClip.tabs_mc.contentClips.length; i++) {
			this.contentClip.tabs_mc.contentClips[i].onClose();
		}
	}
	
	subscribe(key, window_mc);
	window_mc.key = key;
	window_mc.update = function (key, dataSetName) {
		var dataSet = _global.controls[key][dataSetName];
		switch (dataSetName) {
			case "nowplaying":
				var tab_mc = this.contentClip.tabs_mc.contentClips[0];
				break;
			case "albums":
				var row = 0;
				var col = 0;
				var artWidth = 100;
				var artHeight = 100;
				var padding = 27;
				var tab_mc = this.contentClip.tabs_mc.contentClips[1];
				tab_mc.createEmptyMovieClip("albums_mc", 10);
				var albums_mc = tab_mc.albums_mc;
				for (var i=0; i<dataSet.length; i++) {
					var album = dataSet[i];
					var album_mc = albums_mc.createEmptyMovieClip("album" + i + "_mc", i);
					album_mc._x = col * (artWidth + padding);
					album_mc._y = row * (artHeight + (padding * 2));
					album_mc.key = key;
					album_mc.album = album;
					var cover_mc = album_mc.createEmptyMovieClip("cover_mc", 0);
					if (album.thumbCoverArt.indexOf("-1") > -1) {
						cover_mc.loadMovie("http://" + _global.settings.squeezeAddress + ":" + _global.settings.squeezePort + "/music/0/thumb.jpg");
					} else {
						cover_mc.loadMovie(album.thumbCoverArt);
					}
					album_mc.onPress2 = function () {
						selectTracks(this.key, "album", this.album.id, this.album.album);
					}
					album_mc.attachMovie("bi.ui.Label", "title_lb", 10, {settings:{text:album.album, align:"center", width:100, fontSize:10}, _y:105});
					col++;
					if (col == Math.floor((tab_mc.width + padding) / (artWidth + padding))) {
						col = 0;
						row++;
					}
				}
				tab_mc.buttons_mc.previous_btn.enabled = (tab_mc.page > _global.settings.albumsPerPage);
				tab_mc.buttons_mc.next_btn.enabled = (dataSet.length >= _global.settings.albumsPerPage);
				break;
			case "artists":
				var row = 0;
				var col = 0;
				var itemWidth = 230;
				var itemHeight = 30;
				var colPadding = 20;
				var rowPadding = 21;
				var tab_mc = this.contentClip.tabs_mc.contentClips[2];
				tab_mc.createEmptyMovieClip("items_mc", 10);
				var items_mc = tab_mc.items_mc;
				for (var i=0; i<dataSet.length; i++) {
					var artist = dataSet[i];
					var item_mc = items_mc.createEmptyMovieClip("item" + i + "_mc", i);
					item_mc._x = col * (itemWidth + colPadding);
					item_mc._y = row * (itemHeight + rowPadding);
					item_mc.key = key;
					item_mc.artist = artist;
					item_mc.attachMovie("bi.ui.Label", "title_lb", 10, {settings:{text:artist.artist, align:"left", width:itemWidth, fontSize:14}});
					item_mc.onPress2 = function () {
						selectTracks(this.key, "artist", this.artist.id, this.artist.artist);
					}
					row++;
					if (row == Math.floor((tab_mc.height + rowPadding - 40) / (itemHeight + rowPadding))) {
						row = 0;
						col++;
					}
				}
				tab_mc.buttons_mc.previous_btn.enabled = (tab_mc.page > _global.settings.artistsPerPage);
				tab_mc.buttons_mc.next_btn.enabled = (dataSet.length >= _global.settings.artistsPerPage);
				break;
			case "genres":
				var row = 0;
				var col = 0;
				var itemWidth = 230;
				var itemHeight = 30;
				var colPadding = 20;
				var rowPadding = 21;
				var tab_mc = this.contentClip.tabs_mc.contentClips[3];
				tab_mc.createEmptyMovieClip("items_mc", 10);
				var items_mc = tab_mc.items_mc;
				for (var i=0; i<dataSet.length; i++) {
					var genre = dataSet[i];
					var item_mc = items_mc.createEmptyMovieClip("item" + i + "_mc", i);
					item_mc._x = col * (itemWidth + colPadding);
					item_mc._y = row * (itemHeight + rowPadding);
					item_mc.key = key;
					item_mc.genre = genre;
					item_mc.attachMovie("bi.ui.Label", "title_lb", 10, {settings:{text:genre.genre, align:"left", width:itemWidth, fontSize:14}});
					item_mc.onPress2 = function () {
						selectTracks(this.key, "genre", this.genre.id, this.genre.genre);
					}
					row++;
					if (row == Math.floor((tab_mc.height + rowPadding - 40) / (itemHeight + rowPadding))) {
						row = 0;
						col++;
					}
				}
				tab_mc.buttons_mc.previous_btn.enabled = (tab_mc.page > _global.settings.genresPerPage);
				tab_mc.buttons_mc.next_btn.enabled = (dataSet.length >= _global.settings.genresPerPage);
				break;
		}
	}
	
	var tabs_mc = window_mc.contentClip.attachMovie("bi.ui.Tabs", "tabs_mc", 0, {settings:{width:window_mc.contentClip.width, height:window_mc.contentClip.height, tabPosition:"top", tabDisplayAs:"labels"}});
		
	var tabData = new Array();
	tabData.push({name:"Now Playing", mode:"playlist"});
	tabData.push({name:"Albums", mode:"albums"});
	tabData.push({name:"Artists", mode:"artists"});
	tabData.push({name:"Genres", mode:"genres"});
	tabs_mc.tabData = tabData;
	
	tabs_mc.originalTitle = "Music Library";
	tabs_mc.changeTab = function (eventObj) {
		// set window title
		this._parent._parent.title = this.originalTitle + ": " + eventObj.name;
		switch (eventObj.mode) {
			case "nowplaying":
				break;
			case "albums":
				// <CONTROL KEY="<player key>" COMMAND="getAlbums" EXTRA="<page>" EXTRA2="<items per page>" EXTRA3="<optional filter>" EXTRA4="<search>" EXTRA5=""/>
				sendCmd(this._parent._parent.key, "getAlbums", "1", [_global.settings.albumsPerPage]);
				break;
			case "artists":
				sendCmd(this._parent._parent.key, "getArtists", "1", [_global.settings.artistsPerPage]);
				break;
			case "genres":
				sendCmd(this._parent._parent.key, "getGenres", "1", [_global.settings.genresPerPage]);
				break;
		}
	}
	tabs_mc.addEventListener("changeTab", tabs_mc);
	tabs_mc.activeTab = 0;
	
	for (var i=1; i<tabData.length; i++) {
		tabs_mc.contentClips[i].page = 1;
		
		var buttons_mc = tabs_mc.contentClips[i].createEmptyMovieClip("buttons_mc", 20);
		buttons_mc._y = tabs_mc.contentClips[i].height - 30;
		buttons_mc.itemsPerPage = _global.settings[tabData[i].mode + "PerPage"];
		buttons_mc.func = "get" + tabData[i].name;
		buttons_mc.attachMovie("bi.ui.Button", "previous_btn", 10, {settings:{width:100, height:30, label:"< Previous"}, key:key});
		buttons_mc.previous_btn.press = function () {
			var tab_mc = this._parent._parent;
			tab_mc.page -= this._parent.itemsPerPage;
			sendCmd(this.key, this._parent.func, tab_mc.page, [this._parent.itemsPerPage]);
		}
		buttons_mc.previous_btn.addEventListener("press", buttons_mc.previous_btn);
		buttons_mc.attachMovie("bi.ui.Button", "next_btn", 20, {settings:{width:100, height:30, label:"Next >"}, _x:tabs_mc.contentClips[i].width - 100, key:key});
		buttons_mc.next_btn.press = function () {
			var tab_mc = this._parent._parent;
			tab_mc.page += this._parent.itemsPerPage;
			sendCmd(this.key, this._parent.func, tab_mc.page, [this._parent.itemsPerPage]);
		}
		buttons_mc.next_btn.addEventListener("press", buttons_mc.next_btn);
	}
	
	selectTracks = function (key, filter, id, title) {
		var window_mc = showWindow({width:400, height:450, title:title, iconName:"music-note", align:"center"});
		
		var content_mc = window_mc.content_mc;
		
		content_mc.attachMovie("bi.ui.Button", "queueAll_btn", 10, {settings:{width:content_mc.width, height:30, label:"Queue all tracks"}, key:key, filter:filter, id:id});
		content_mc.queueAll_btn.press = function () {
			sendCmd(this.key, "queueItem", this.filter + ":" + this.id);
		}
		content_mc.queueAll_btn.addEventListener("press", content_mc.queueAll_btn);
	}
}