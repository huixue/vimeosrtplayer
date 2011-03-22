package org.mindpirates.websubs
{    
	import com.greensock.layout.ScaleMode;
	
	import de.derhess.video.vimeo.VimeoPlayer;
	
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.external.ExternalInterface;
	import flash.net.getClassByAlias;
	import flash.net.registerClassAlias;
	import flash.utils.getDefinitionByName;
	
	import org.mindpirates.video.VideoEvent;
	import org.mindpirates.video.interfaces.IVideoPlayer;
	import org.mindpirates.video.vimeo.MoogaloopWrapper;
	import org.mindpirates.video.vimeo.MoogaloverWrapper;
	import org.osflash.thunderbolt.Logger;
	
	  
	
	/** 
	 * VimeoSrtPlayer
	 * Displays .srt subtitles with moogaloop.swf
	 * http://code.google.com/p/vimeosrtplayer/
	 * 
	 * @author Jovica Aleksic
	 */
	[SWF(width="450", height="225")]
	public class VimeoSrtPlayer extends Sprite
	{  
		public var params:Params;
		public var player:IVideoPlayer;  
		public var subtitles:SubtitlesLayer;
		public var js:WebsubsJsInterface;
		public static var instance:VimeoSrtPlayer;
		public var PlayerClass:Class = VimeoPlayer;
		/* keep references for compiler */
		private static const PLAYER_TYPES:Array = [VimeoPlayer, MoogaloopWrapper, MoogaloverWrapper];
		
		public function VimeoSrtPlayer()
		{ 		 
			addEventListener(Event.ADDED_TO_STAGE, handleAddedToStage, false, 0, true);
			params =  new Params(loaderInfo);
			registerClassAlias('MoogaloverWrapper', org.mindpirates.video.vimeo.MoogaloverWrapper);
		}
		
		internal function handleAddedToStage(e:Event):void
		{    
			if (ExternalInterface.available) {
				js = new WebsubsJsInterface();
			}   
			if (params.playerClass) {
				PlayerClass = getClassByAlias(params.playerClass); 
			}
			player = new PlayerClass(loaderInfo, stage.stageWidth, stage.stageHeight, js);//new VimeoPlayer(loaderInfo, stage.stageWidth, stage.stageHeight, js); 
			player.addEventListener(VideoEvent.PLAYER_LOADED, handlePlayerLoaded, false, 0, true); 
			addChild(player as DisplayObject); 
			
			addEventListener(MouseEvent.MOUSE_DOWN, handleMouseDown, true, 0, true);
		} 
		  
		private function handleMouseDown(e:MouseEvent):void
		{ 
			if (ExternalInterface.available) {
				try { 
					ExternalInterface.call('window.onPlayerMouseDown') 
				}
				catch (err:Error) { 
					// nothing
				}
			}
		}
		private function handlePlayerLoaded(e:Event):void
		{         
			subtitles = new SubtitlesLayer(player);
			subtitles.init( params );
			addChild(subtitles);
			js.initCallbacks(this);
		}  
		
		public function destroy():void
		{
			subtitles.destroy();
			player.destroy();
		}
		
	}
}