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
			default:
				var tab_mc = this.contentClip.tabs_mc.contentClips[0];
				tab_mc.control_mc.update(key, dataSetName);
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
			case "playlist":
				sendCmd(this._parent._parent.key, "getTracks", "0", ["20", "currentplaylist"]);
				break;
			case "albums":
				// <CONTROL KEY="<player key>" COMMAND="getAlbums" EXTRA="<page>" EXTRA2="<items per page>" EXTRA3="<optional filter>" EXTRA4="<search>" EXTRA5=""/>
				sendCmd(this._parent._parent.key, "getAlbums", "0", [_global.settings.albumsPerPage]);
				break;
			case "artists":
				sendCmd(this._parent._parent.key, "getArtists", "0", [_global.settings.artistsPerPage]);
				break;
			case "genres":
				sendCmd(this._parent._parent.key, "getGenres", "0", [_global.settings.genresPerPage]);
				break;
		}
	}
	tabs_mc.addEventListener("changeTab", tabs_mc);
	tabs_mc.activeTab = 0;
	
	// build now playing tab
	var tab_mc = tabs_mc.contentClips[0];
	tab_mc.attachMovie("bi.ui.Label", "nowPlayer_lb", 10, {settings:{text:"Now Playing", width:150, fontSize:16}});
	var control_mc = tab_mc.createEmptyMovieClip("control_mc", 20);
	control_mc._y = 40;
	control_mc.width = tab_mc.width / 2 - 20;
	control_mc.height - tab_mc.height - tab_mc.control_mc._y;
	renderControl({key:key, type:"squeezePanelFull"}, control_mc, control_mc.width);
	
	tab_mc.attachMovie("bi.ui.Label", "currentPlaylist_lb", 30, {settings:{text:"Current Playlist", width:150, fontSize:16}, _x:Math.round(tab_mc.width / 2)});

	tab_mc.key = key;
	tab_mc.update = function (key, dataSetName) {
		if (dataSetName && dataSetName != "tracks") return;

		var dataSet = _global.controls[this.key]["tracks"];
		
		var labels_mc = this.createEmptyMovieClip("labels_mc", 40);
		labels_mc._x = Math.round(this.width / 2);
		labels_mc._y = 40;

		var label_tf = new TextFormat();
		label_tf.color = 0xFFFFFF;
		label_tf.size = 16;
		label_tf.bold = true;
		label_tf.font = "bi.ui.Fonts:" + _global.settings.defaultFont;

		this.maxItems = dataSet.length;
		if (dataSet.length > this.itemsPerPage) {
			this.scrollBar_mc._visible = true;
			this.scrollBar_mc.scrollUp_mc.enabled = this.startRow > 0;
			this.scrollBar_mc.scrollDown_mc.enabled = this.startRow + this.itemsPerPage < this.maxItems;
			var labelWidth = Math.round(this.width / 2) - 40;
		} else {
			var labelWidth = Math.round(this.width / 2);
			this.scrollBar_mc._visible = false;
		}

		var counter = 0;
		while (counter < this.itemsPerPage && this.startRow + counter < this.maxItems) {
			var track = dataSet[this.startRow + counter];
			var label_mc = labels_mc.createEmptyMovieClip("label" + counter + "_mc", counter);
			label_mc._y = counter * 35;
			label_mc.key = this.key;
			label_mc.filter = this.filter;
			label_mc.id = track.id;
			label_mc.index = this.startRow + counter;
						
			label_mc.createTextField("label" + counter + "_txt", 20, 3, 3, labelWidth - 30, 20);
			var label_txt = label_mc["label" + counter + "_txt"];
			label_txt.embedFonts = true;
			label_txt.selectable = false;
			label_txt.setNewTextFormat(label_tf);
			label_txt.text = (this.startRow + counter + 1) + ". " + track.artist + " - " + track.title;

			var bg_mc = label_mc.createEmptyMovieClip("bg_mc", 0);
			bg_mc.beginFill(0x4E75B5);
			bg_mc.drawRect(0, 0, labelWidth, 30, 5);
			bg_mc.endFill();
			
			label_mc.onPress2 = function () {
				// <CONTROL KEY="<key>" COMMAND="jumpToPosition" EXTRA="<index in playlist>" EXTRA2="" EXTRA3="" EXTRA4="" EXTRA5="" />
				sendCmd(this.key, "jumpToPosition", this.index);
			}

			counter++;
		}
	}
	
	var scrollBar_mc = tab_mc.createEmptyMovieClip("scrollBar_mc", 50);
	createScrollBar(scrollBar_mc, tab_mc.height - 45, "update");
	scrollBar_mc._x = tab_mc.width - scrollBar_mc._width;
	scrollBar_mc._y = 40;
	scrollBar_mc._visible = false;
	tab_mc.key = key;
	tab_mc.startRow = 0;
	tab_mc.itemsPerPage = Math.floor((tab_mc.height - 40 + 5) / 35);
	
	subscribe(key, tab_mc);
		
	tab_mc.onClose = function () {
		unsubscribe(this.key, this);
	}
	
	// build other tabs
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

		content_mc.key = key;
		content_mc.filter = filter;
		content_mc.update = function (key, dataSetName) {
			if (key) this.key = key;
			if (dataSetName) this.dataSetName = dataSetName;

			if (this.dataSetName != "tracks") return;
			var dataSet = _global.controls[this.key][this.dataSetName];
			
			var labels_mc = this.createEmptyMovieClip("labels_mc", 50);
			labels_mc._y = 40;
	
			var label_tf = new TextFormat();
			label_tf.color = 0xFFFFFF;
			label_tf.size = 16;
			label_tf.bold = true;
			label_tf.font = "bi.ui.Fonts:" + _global.settings.defaultFont;
	
			this.maxItems = dataSet.length;
			if (dataSet.length > this.itemsPerPage) {
				this.scrollBar_mc._visible = true;
				this.scrollBar_mc.scrollUp_mc.enabled = this.startRow > 0;
				this.scrollBar_mc.scrollDown_mc.enabled = this.startRow + this.itemsPerPage < this.maxItems;
				var labelWidth = this.width - 40;
			} else {
				var labelWidth = this.width;
				this.scrollBar_mc._visible = false;
			}
	
			var counter = 0;
			while (counter < this.itemsPerPage && this.startRow + counter < this.maxItems) {
				var track = dataSet[this.startRow + counter];
				var label_mc = labels_mc.createEmptyMovieClip("label" + counter + "_mc", counter);
				label_mc._y = counter * 35;
				label_mc.key = this.key;
				label_mc.filter = this.filter;
				label_mc.id = track.id;
							
				label_mc.createTextField("label" + counter + "_txt", 20, 3, 3, labelWidth - 30, 20);
				var label_txt = label_mc["label" + counter + "_txt"];
				label_txt.embedFonts = true;
				label_txt.selectable = false;
				label_txt.setNewTextFormat(label_tf);
				if (this.filter == "album" && track.trackNum) {
					label_txt.text = track.trackNum + ". " + track.title;
				} else {
					label_txt.text = track.title;
				}
	
				var bg_mc = label_mc.createEmptyMovieClip("bg_mc", 0);
				bg_mc.beginFill(0x4E75B5);
				bg_mc.drawRect(0, 0, labelWidth, 30, 5);
				bg_mc.endFill();
				
				label_mc.onPress2 = function () {
					sendCmd(this.key, "queueItem", "track:" + this.id);
				}
	
				counter++;
			}
		}
		
		var scrollBar_mc = content_mc.createEmptyMovieClip("scrollBar_mc", 20);
		createScrollBar(scrollBar_mc, content_mc.height - 45, "update");
		scrollBar_mc._x = content_mc.width - scrollBar_mc._width;
		scrollBar_mc._y = 40;
		scrollBar_mc._visible = false;
		content_mc.startRow = 0;
		content_mc.itemsPerPage = Math.floor((content_mc.height - 40 + 5) / 35);

		subscribe(key, content_mc);
		
		window_mc.onClose = function () {
			unsubscribe(this.content_mc.key, this.content_mc);
		}
		
		sendCmd(key, "getTracks", "0", ["20", filter + ":" + id]);
	}
}