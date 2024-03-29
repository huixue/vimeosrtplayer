package org.mindpirates.websubs
{ 
	import org.osflash.thunderbolt.Logger;
	 
	public class LocalizationXML extends XMLProxy
	{
		public function LocalizationXML(url:String=null)
		{
			super(url);
		}
		public function get languages():Array
		{ 
			var result:Array = []; 
			for each (var prop:XML in data.srt) 
			{ 
				result.push( String(prop.@lang) ); 
			}
			return result;
		}
		public function get files():Array
		{
			var result:Array = [];
			for each (var prop:XML in data.srt) 
			{ 
				result.push( prop.toString() ); 
			}
			return result;
		}
		public function getLangByFile(file:String):String
		{
			for each (var srt:XML in data.srt) {
				if (srt.toString() == file) {
					return srt.@lang;
				}
			}
			return null;
		}
		public function getFileByLang(lang:String):String
		{
			return data.srt.(@lang==lang).toString();
		}
		public function getTitleByLang(lang:String):String
		{ 
			return data.srt.(@lang==lang).@title;
		}
		public function getDescriptionByLang(lang:String):String
		{ 
			return data.srt.(@lang==lang).@description;
		}
		public function getFontNameByLang(lang:String):String
		{
			return data.srt.(@lang==lang).@fontName;
		}
		public function getFontFileByLang(lang:String):String
		{
			return String(data.srt.(@lang==lang).@fontFile);
		}
		public function getFontSizeByLang(lang:String):Number
		{
			return Number(data.srt.(@lang==lang).@fontSize);
		}
		 
		public function get defaultLang():String
		{
			return data.@defaultLang;
		}
	}
}