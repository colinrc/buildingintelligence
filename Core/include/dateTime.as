Date.prototype.dateTimeFormat = function (mask) {
	var months = ["January","February","March","April","May","June","July","August","September","October","November","December"];
	var days = ["Sunday","Monday","Tuesday","Wednesday","Thursday","Friday","Saturday"];
	var outputDate = "";
	var i = 0;
	while (i < mask.length) {
		// escaped characters
		if (mask.substr(i,1) eq "*") {
			outputDate += mask.substr(i+1,1);
			i += 2;
		// year
		} else if (mask.substr(i,4) eq "yyyy") {
			outputDate += this.getFullYear().toString();
			i += 4;
		} else if (mask.substr(i,2) eq "yy") {
			outputDate += this.getFullYear().toString().substr(2,2);
			i += 2;
		// month
		} else if (mask.substr(i,4) eq "mmmm") {
			outputDate += months[this.getMonth()];
			i += 4;
		} else if (mask.substr(i,3) eq "mmm") {
			outputDate += months[this.getMonth()];
			i += 3;
		} else if (mask.substr(i,2) eq "mm") {
			if (this.getMonth() < 9) {
				outputDate += "0";
			}
			outputDate += (this.getMonth() + 1);
			i += 2;
		} else if (mask.substr(i,1) eq "m") {
			outputDate += (this.getMonth() + 1);
			i++;
		// date
		} else if (mask.substr(i,4) eq "dddd") {
			outputDate += days[this.getDay()];
			i += 4;
		} else if (mask.substr(i,3) eq "ddd") {
			outputDate += days[this.getDay()];
			i += 3;
		} else if (mask.substr(i,2) eq "dd") {
			if (this.getDate() < 10) {
				outputDate += "0";
			}
			outputDate += this.getDate();
			i += 2;
		} else if (mask.substr(i,1) eq "d") {
			outputDate += this.getDate();
			i++;
		// th, rd, nd
		} else if (mask.substr(i,2) eq "ff") {
			if (this.getDate() == 1 || this.getDate() == 21 || this.getDate() == 31) {
				outputDate += "st";
			} else if (this.getDate() == 2 || this.getDate() == 22) {
				outputDate += "nd";
			} else if (this.getDate() == 3 || this.getDate() == 23) {
				outputDate += "rd";
			} else {
				outputDate += "th";
			}
			i += 2;
		// hours
		} else if (mask.substr(i,2) eq "HH") {
			if (this.getHours() < 10) {
				outputDate += "0";
			}
			outputDate += this.getHours();
			i += 2;
		} else if (mask.substr(i,2) eq "hh") {
			if ((this.getHours() < 10 and this.getHours() > 0) or (this.getHours() < 22 and this.getHours() > 12)) {
				outputDate += "0";
			}
			if (this.getHours() > 12) {
				outputDate += this.getHours() - 12;
			} else if (this.getHours() eq 0) {
				outputDate += "12";
			} else {
				outputDate += this.getHours();
			}
			i += 2;
		} else if (mask.substr(i,1) eq "H") {
			outputDate += this.getHours();
			i++;
		} else if (mask.substr(i,1) eq "h") {
			if (this.getHours() > 12) {
				outputDate += this.getHours() - 12;
			} else if (this.getHours() == 0) {
				outputDate += "12";
			} else {
				outputDate += this.getHours();
			}
			i++;
		// minutes
		} else if (mask.substr(i,2).toLowerCase() eq "nn") {
			if (this.getMinutes() < 10) {
				outputDate += "0";
			}
			outputDate += this.getMinutes();
			i += 2;
		} else if (mask.substr(i,1).toLowerCase() eq "n") {
			outputDate += this.getMinutes();
			i++;
		// seconds
		} else if (mask.substr(i,2).toLowerCase() eq "ss") {
			if (this.getSeconds() < 10) {
				outputDate += "0";
			}
			outputDate += this.getSeconds();
			i += 2;
		} else if (mask.substr(i,1).toLowerCase() eq "s") {
			outputDate += this.getSeconds();
			i++;
		// am - pm
		} else if (mask.substr(i,2) eq "tt") {
			if (this.getHours() < 12) {
				outputDate += "am";
			} else {
				outputDate += "pm";
			}
			i += 2;
		} else if (mask.substr(i,1) eq "t") {
			if (this.getHours() < 12) {
				outputDate += "a";
			} else {
				outputDate += "p";
			}
			i++;
		} else if (mask.substr(i,2) eq "TT") {
			if (this.getHours() < 12) {
				outputDate += "AM";
			} else {
				outputDate += "PM";
			}
			i += 2;
		} else if (mask.substr(i,1) eq "T") {
			if (this.getHours() < 12) {
				outputDate += "A";
			} else {
				outputDate += "P";
			}
			i++;
		// anything else
		} else {
			outputDate += mask.substr(i,1);
			i++
		}
	}
	return outputDate;
}

String.prototype.parseDate = function () {
	var d = this.split(" ")[0].split("-");
	var t = this.split(" ")[1].split(":");
	return new Date(d[0],d[1]-1,d[2],t[0],t[1],t[2]);
}

Number.prototype.timeFormat = function (mask) {
	var days = Math.floor(this / 86400000);
	var hours = Math.floor(this / 3600000) - (days * 24);
	var mins = Math.floor(this / 60000) - (hours * 60) - (days * 1440);
	var secs = Math.floor(this / 1000) - (mins * 60) - (hours * 3600) - (days * 86400);
	
	var output = "";
	
	if (days >= 0) {
		output += days + "d";
	}
	if (hours >= 0) {
		output += " " + hours + "h";
	}
	if (mins >= 0) {
		output += " " + mins + "m";
	}
	if (secs >= 0) {
		output += " " + secs + "s";
	}
	return output;
}