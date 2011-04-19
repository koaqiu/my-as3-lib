package xBei.Helper {
	import flash.utils.Proxy;
	import flash.utils.flash_proxy;
	/**
	 * 扩展日期类
	 * @author KoaQiu
	 */
	public class extDate{
		private var _date:Date;
		public function extDate(year:* = null, month:* = null, date:* = null, hours:* = null, minutes:* = null, seconds:* = null, ms:* = null){
			_date=new Date(year, month, date, hours, minutes, seconds, ms);
		}
		/// The day of the month (an integer from 1 to 31) specified by a Date object according to local time.
		public function get date () : Number{
			return _date.date;
		}
		public function set date (value:Number) : void{
			_date.date = value;
		}

		/// The day of the month (an integer from 1 to 31) of a Date object according to universal time (UTC).
		public function get dateUTC () : Number{
			return _date.dateUTC;
		}
		public function set dateUTC (value:Number) : void{
			_date.dateUTC = value;
		}

		/// The day of the week (0 for Sunday, 1 for Monday, and so on) specified by this Date according to local time.
		public function get day () : Number{
			return _date.day;
		}

		/// The day of the week (0 for Sunday, 1 for Monday, and so on) of this Date  according to universal time (UTC).
		public function get dayUTC () : Number{
			return _date.dayUTC;
		}

		/// The full year (a four-digit number, such as 2000) of a Date object according to local time.
		public function get fullYear () : Number{
			return _date.fullYear;
		}
		public function set fullYear (value:Number) : void{
			_date.fullYear = value;
		}

		/// The four-digit year of a Date object according to universal time (UTC).
		public function get fullYearUTC () : Number{
			return _date.fullYearUTC;
		}
		public function set fullYearUTC (value:Number) : void{
			_date.fullYearUTC = value;
		}

		/// The hour (an integer from 0 to 23) of the day portion of a Date object according to local time.
		public function get hours () : Number{
			return _date.hours;
		}
		public function set hours (value:Number) : void{
			_date.hours = value;
		}

		/// The hour (an integer from 0 to 23) of the day of a Date object according to universal time (UTC).
		public function get hoursUTC () : Number{
			return _date.hoursUTC;
		}
		public function set hoursUTC (value:Number) : void{
			_date.hoursUTC = value;
		}

		/// The milliseconds (an integer from 0 to 999) portion of a Date object according to local time.
		public function get milliseconds () : Number{
			return _date.milliseconds;
		}
		public function set milliseconds (value:Number) : void{
			_date.milliseconds = value;
		}

		/// The milliseconds (an integer from 0 to 999) portion of a Date object according to universal time (UTC).
		public function get millisecondsUTC () : Number{
			return _date.millisecondsUTC;
		}
		public function set millisecondsUTC (value:Number) : void{
			_date.millisecondsUTC = value;
		}

		/// The minutes (an integer from 0 to 59) portion of a Date object according to local time.
		public function get minutes () : Number{
			return _date.minutes;
		}
		public function set minutes (value:Number) : void{
			_date.minutes = value;
		}

		/// The minutes (an integer from 0 to 59) portion of a Date object according to universal time (UTC).
		public function get minutesUTC () : Number{
			return _date.minutesUTC;
		}
		public function set minutesUTC (value:Number) : void{
			_date.minutesUTC = value;
		}

		/// The month (0 for January, 1 for February, and so on) portion of a  Date object according to local time.
		public function get month () : Number{
			return _date.month;
		}
		public function set month (value:Number) : void{
			_date.month = value;
		}

		/// The month (0 [January] to 11 [December]) portion of a Date object according to universal time (UTC).
		public function get monthUTC () : Number{
			return _date.monthUTC;
		}
		public function set monthUTC (value:Number) : void{
			_date.monthUTC = value;
		}

		/// The seconds (an integer from 0 to 59) portion of a Date object according to local time.
		public function get seconds () : Number{
			return _date.seconds;
		}
		public function set seconds (value:Number) : void{
			_date.seconds = value;
		}

		/// The seconds (an integer from 0 to 59) portion of a Date object according to universal time (UTC).
		public function get secondsUTC () : Number{
			return _date.secondsUTC;
		}
		public function set secondsUTC (value:Number) : void{
			_date.secondsUTC = value;
		}

		/// The number of milliseconds since midnight January 1, 1970, universal time, for a Date object.
		public function get time () : Number {
			return _date.time;
		}
		public function set time (value:Number) : void {
			_date.time = value;
		}
		
		public function get timezoneOffset():Number {
			return _date.timezoneOffset;
		}
		
		/// Returns the day of the month (an integer from 1 to 31) specified by a Date object according to local time.
		public function getDate () : Number {
			return _date.getDate();
		}

		/// Returns the day of the week (0 for Sunday, 1 for Monday, and so on) specified by this Date according to local time.
		public function getDay () : Number{
			return _date.getDay();
		}

		/// Returns the full year (a four-digit number, such as 2000) of a Date object according to local time.
		public function getFullYear () : Number{
			return _date.getFullYear();
		}

		/// Returns the hour (an integer from 0 to 23) of the day portion of a Date object according to local time.
		public function getHours () : Number{
			return _date.getHours();
		}

		/// Returns the milliseconds (an integer from 0 to 999) portion of a Date object according to local time.
		public function getMilliseconds () : Number{
			return _date.getMilliseconds();
		}

		/// Returns the minutes (an integer from 0 to 59) portion of a Date object according to local time.
		public function getMinutes () : Number{
			return _date.getMinutes();
		}

		/// Returns the month (0 for January, 1 for February, and so on) portion of this  Date according to local time.
		public function getMonth () : Number{
			return _date.getMonth();
		}

		/// Returns the seconds (an integer from 0 to 59) portion of a Date object according to local time.
		public function getSeconds () : Number{
			return _date.getSeconds();
		}

		/// Returns the number of milliseconds since midnight January 1, 1970, universal time, for a Date object.
		public function getTime () : Number{
			return _date.getTime();
		}

		/// Returns the difference, in minutes, between universal time (UTC) and the computer's local time.
		public function getTimezoneOffset () : Number{
			return _date.getTimezoneOffset();
		}

		/// Returns the day of the month (an integer from 1 to 31) of a Date object, according to universal time (UTC).
		public function getUTCDate () : Number{
			return _date.getUTCDate();
		}

		/// Returns the day of the week (0 for Sunday, 1 for Monday, and so on) of this Date  according to universal time (UTC).
		public function getUTCDay () : Number{
			return _date.getUTCDay();
		}

		/// Returns the four-digit year of a Date object according to universal time (UTC).
		public function getUTCFullYear () : Number{
			return _date.getUTCFullYear();
		}

		/// Returns the hour (an integer from 0 to 23) of the day of a Date object according to universal time (UTC).
		public function getUTCHours () : Number{
			return _date.getUTCHours();
		}

		/// Returns the milliseconds (an integer from 0 to 999) portion of a Date object according to universal time (UTC).
		public function getUTCMilliseconds () : Number{
			return _date.getUTCMilliseconds();
		}

		/// Returns the minutes (an integer from 0 to 59) portion of a Date object according to universal time (UTC).
		public function getUTCMinutes () : Number{
			return _date.getUTCMinutes();
		}

		/// Returns the month (0 [January] to 11 [December]) portion of a Date object according to universal time (UTC).
		public function getUTCMonth () : Number{
			return _date.getUTCMonth();
		}

		/// Returns the seconds (an integer from 0 to 59) portion of a Date object according to universal time (UTC).
		public function getUTCSeconds () : Number{
			return _date.getUTCSeconds();
		}

		/// Converts a string representing a date into a number equaling the number of milliseconds elapsed since January 1, 1970, UTC.
		public static function parse (s:*) : Number{
			return Date.parse(s);
		}

		/// Sets the day of the month, according to local time, and returns the new time in milliseconds.
		public function setDate (date:* = null) : Number{
			return _date.setDate(date);
		}

		/// Sets the year, according to local time, and returns the new time in milliseconds.
		public function setFullYear (year:* = null, month:* = null, date:* = null) : Number{
			return _date.setFullYear(year, month, date);
		}

		/// Sets the hour, according to local time, and returns the new time in milliseconds.
		public function setHours (hour:* = null, min:* = null, sec:* = null, ms:* = null) : Number{
			return _date.setHours(hour, min, sec, ms);
		}

		/// Sets the milliseconds, according to local time, and returns the new time in milliseconds.
		public function setMilliseconds (ms:* = null) : Number{
			return _date.setMilliseconds(ms);
		}

		/// Sets the minutes, according to local time, and returns the new time in milliseconds.
		public function setMinutes (min:* = null, sec:* = null, ms:* = null) : Number{
			return _date.setMinutes(min, sec, ms);
		}

		/// Sets the month and optionally the day of the month, according to local time, and returns the new time in milliseconds.
		public function setMonth (month:* = null, date:* = null) : Number{
			return _date.setMonth(month, date);
		}

		/// Sets the seconds, according to local time, and returns the new time in milliseconds.
		public function setSeconds (sec:* = null, ms:* = null) : Number{
			return _date.setSeconds(sec, ms);
		}

		/// Sets the date in milliseconds since midnight on January 1, 1970, and returns the new time in milliseconds.
		public function setTime (t:* = null) : Number{
			return _date.setTime(t);
		}

		/// Sets the day of the month, in universal time (UTC), and returns the new time in milliseconds.
		public function setUTCDate (date:* = null) : Number{
			return _date.setUTCDate(date);
		}

		/// Sets the year, in universal time (UTC), and returns the new time in milliseconds.
		public function setUTCFullYear (year:* = null, month:* = null, date:* = null) : Number{
			return _date.setUTCFullYear(year, month, date);
		}

		/// Sets the hour, in universal time (UTC), and returns the new time in milliseconds.
		public function setUTCHours (hour:* = null, min:* = null, sec:* = null, ms:* = null) : Number{
			return _date.setUTCHours(hour, min, sec, ms);
		}

		/// Sets the milliseconds, in universal time (UTC), and returns the new time in milliseconds.
		public function setUTCMilliseconds (ms:* = null) : Number{
			return _date.setUTCMilliseconds(ms);
		}

		/// Sets the minutes, in universal time (UTC), and returns the new time in milliseconds.
		public function setUTCMinutes (min:* = null, sec:* = null, ms:* = null) : Number{
			return _date.setUTCMinutes(min, sec, ms);
		}

		/// Sets the month, and optionally the day, in universal time(UTC) and returns the new time in milliseconds.
		public function setUTCMonth (month:* = null, date:* = null) : Number{
			return _date.setUTCMonth(month, date);
		}

		/// Sets the seconds, and optionally the milliseconds, in universal time (UTC) and returns the new time in milliseconds.
		public function setUTCSeconds (sec:* = null, ms:* = null) : Number {
			return _date.setUTCSeconds(sec, ms);
		}

		/// Returns a string representation of the day and date only, and does not include the time or timezone.
		public function toDateString () : String{
			return _date.toDateString();
		}

		/// Returns a String representation of the day and date only, and does not include the time or timezone.
		public function toLocaleDateString () : String{
			return _date.toLocaleDateString();
		}

		/// Returns a String representation of the day, date, time, given in local time.
		public function toLocaleString () : String{
			return _date.toLocaleString();
		}

		/// Returns a String representation of the time only, and does not include the day, date, year, or timezone.
		public function toLocaleTimeString () : String{
			return _date.toLocaleTimeString();
		}

		/// Returns a String representation of the time and timezone only, and does not include the day and date.
		public function toTimeString () : String{
			return _date.toTimeString();
		}

		/// Returns a String representation of the day, date, and time in universal time (UTC).
		public function toUTCString () : String{
			return _date.toUTCString();
		}

		/// Returns the number of milliseconds between midnight on January 1, 1970, universal time, and the time specified in the parameters.
		public static function UTC (year:*, month:*, date:* = 1, hours:* = 0, minutes:* = 0, seconds:* = 0, ms:* = 0, ...rest) : Number {
			return Date.UTC(year, month, date, hours, minutes, seconds, ms, rest);
		}

		/// Returns the number of milliseconds since midnight January 1, 1970, universal time, for a Date object.
		public function valueOf () : Number{
			return _date.valueOf();
		}
		
		/**
		 * 从Date中创建 
		 * @param v		Date	输入值
		 * @return 
		 * 
		 */
		public static function CreateFromDate(v:Date):extDate{
			var d:extDate=new extDate();
			d.setTime(v.time);
			return d;
		}
		/**
		 * 秒数到日期
		 * @param	v
		 * @return
		 */
		public static function ParseFromSeconds(v:int):extDate {
			var d:extDate = new extDate();
			d.setTime(v * 1000);
			return d;
		}
		
		/**
		 * 是否闰年
		 * @return
		 */
		public function IsLeapYear():Boolean {
			var y:Number = this.getFullYear();
			return (y%4==0 && y%100!=0) || y%400==0;
		}
		/**
		 * 某个月份里有多少天
		 * @return
		 */
		public function GetDaysInMonth(month:int = 0):int {
			if (month > 12) {
				month = 0;
			}
			return [31, (this.IsLeapYear() ? 29:28), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31][
				month<=0?
				this.getMonth():
				month-1
			];
		}
		/**
		 * 格式化输出<br/>
		 * yyyy	
		 * MM
		 * M
		 * dd
		 * d
		 * HH
		 * H
		 * hh
		 * h
		 * mm
		 * m
		 * ss
		 * s
		 * nnn
		 * nn
		 * n
		 * @param	String	format
		 * @return
		 */
		public function Format(format:String=""):String {
			if (StringHelper.IsNullOrEmpty(format)) {
				return this.toString();
			}else {
				return format.replace(/yyyy/ig, this.getFullYear()).
					replace(/MM/g, this._f2(this.getMonth())).
					replace(/M/g, this.getMonth()).
					replace(/dd/g, this._f2(this.getDate())).
					replace(/d/g, this.getDate()).
					replace(/HH/g, this._f2(this.getHours())).
					replace(/H/g, this.getHours()).
					replace(/hh/g, this._getShortHour(true)).
					replace(/h/g, this._getShortHour(false)).
					replace(/mm/g, this._f2(this.getMinutes())).
					replace(/m/g, this.getMinutes()).
					replace(/ss/ig, this._f2(this.getSeconds())).
					replace(/s/ig, this.getSeconds()).
					replace(/nnn/ig, this._f2(this.getMilliseconds(),3)).
					replace(/nn/ig, this._f2(this.getMilliseconds())).
					replace(/n/ig, this.getMilliseconds());
			}
		}
		private function _getShortHour(F:Boolean):String {
			var h:int = this.getHours();
			var s:String = "";
			if (h > 12) {
				h -= 12;
				s = "PM ";
			}else {
				s = "AM ";
			}
			return s + F?this._f2(h):String(h);
		}
		private function _f2(v:int, l:int = 2):String {
			if (l <= 1) { return String(v);}
			var len:int = Math.pow(10, l - 1);
			return v >= len?String(v):"0" + this._f2(v, l - 1);
		}
		public function toString():String {
			return _date.toString();
		}
	}

}