/**
 * Janitor by Grant Skinner. Sep 22, 2009
 * Visit www.gskinner.com/blog for documentation, updates and more free code.
 *
 *
 * Copyright (c) 2009 Grant Skinner
 * 
 * Permission is hereby granted, free of charge, to any person
 * obtaining a copy of this software and associated documentation
 * files (the "Software"), to deal in the Software without
 * restriction, including without limitation the rights to use,
 * copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following
 * conditions:
 * 
 * The above copyright notice and this permission notice shall be
 * included in all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
 * OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 * NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
 * HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
 * WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 **/

/*
Things not tracked:
* null out any Camera or Microphones
- too little use, and too easy to clear (VERY rare that you would have more than one reference in an app)

Tracked:
* removeEventListeners
- currently a little convoluted to avoid issues with strongly referencing dispatchers
- best method (appended at end) will not work in current player, because of issues with Dictionary and methods
* unload any swf's that were loaded so they can also clean up on unload
* close any LocalConnections, NetConnections, NetStreams
* stop any sounds from playing
* stop an running multiframe movieclips on the time line
* stop the timeline if multiframe and playing
* clearIntervals
* stop any Timers
*/


package com.gskinner.utils {
	
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.Loader;
	import flash.display.MovieClip;
	import flash.events.EventDispatcher;
	import flash.media.SoundChannel;
	import flash.utils.clearInterval;
	import flash.utils.clearTimeout;
	import flash.utils.Dictionary;
	import flash.utils.Timer;
	import com.gskinner.utils.IDisposable;
	
	
	public class Janitor {
		private var soundChannels:Dictionary;
		private var listeners:Dictionary;
		private var intervalIDs:Dictionary; //
		private var timeoutIDs:Dictionary; //
		private var timers:Dictionary; //
		private var disposables:Dictionary; //
		private var connections:Dictionary;
		
		private var target:Object;
		
		
		
		public function Janitor(p_target:Object):void {
			target = p_target;
		}
		
		// general:
		public function cleanUp():void {
			cleanUpIntervalIDs();
			cleanUpTimeoutIDs();
			cleanUpEventListeners(); // tested
			cleanUpTimers();
			cleanUpSoundChannels();
			cleanUpChildren(); // tested
			cleanUpConnections();
			cleanUpDisposables();
			cleanUpTarget();
		}
		
		public function cleanUpTarget():void {
			if (target is MovieClip) {
				var mc:MovieClip = target as MovieClip;
				mc.stop();
			}
		}
		
		// children:
		public function cleanUpChildren():void {
			if (!(target is DisplayObjectContainer)) { return; }
			var doc:DisplayObjectContainer = target as DisplayObjectContainer;
			while (doc.numChildren > 0) {
				var c:DisplayObject = doc.removeChildAt(0);
				if (c is MovieClip) {
					(c as MovieClip).stop();
				}
				/*
				if (c is Bitmap && (c as Bitmap).bitmapData != null) {
				(c as Bitmap).bitmapData.dispose();
				}
				*/
				if (c is Loader) {
					cleanUpConnection(c as Loader);
				}
				// use try/catch instead of IDisposable so that we can define dispose in timeline code:
				try {
					(c as Object).dispose();
				} catch (e:*) {}
			}
		}
		
		// disposables:
		public function addDisposable(p_object:IDisposable):void {
			if (disposables == null) { disposables = new Dictionary(true); }
			disposables[p_object] = true;
		}
		
		public function removeDisposable(p_object:IDisposable):void {
			if (disposables == null) { return; }
			delete(disposables[p_object]);
		}
		
		public function cleanUpDisposables():void {
			for (var o:Object in disposables) {
				(o as IDisposable).dispose();
			}
		}
		
		// intervals:
		public function addIntervalID(p_intervalID:uint):void {
			if (intervalIDs == null) { intervalIDs = new Dictionary(false); }
			intervalIDs[p_intervalID] = true;
		}
		
		public function removeIntervalID(p_intervalID:uint):void {
			if (intervalIDs == null) { return; }
			delete(intervalIDs[p_intervalID]);
		}
		
		public function cleanUpIntervalIDs():void {
			for (var o:Object in intervalIDs) {
				clearInterval(Number(o));
			}
		}
		
		// timeouts:
		public function addTimeoutID(p_timeoutID:uint):void {
			if (timeoutIDs == null) { timeoutIDs = new Dictionary(false); }
			timeoutIDs[p_timeoutID] = true;
		}
		
		public function removeTimeoutID(p_timeoutID:uint):void {
			if (intervalIDs == null) { return; }
			delete(timeoutIDs[p_timeoutID]);
		}
		
		public function cleanUpTimeoutIDs():void {
			for (var o:Object in timeoutIDs) {
				clearTimeout(Number(o));
			}
		}
		
		// timers:
		public function addTimer(p_timer:Timer):void {
			if (timers == null) { timers = new Dictionary(true); }
			timers[p_timer] = true;
		}
		
		public function removeTimer(p_timer:Timer):void {
			if (timers == null) { return; }
			delete(timers[p_timer]);
		}
		
		public function cleanUpTimers():void {
			for (var o:Object in timers) {
				(o as Timer).stop();
			}
		}
		
		// sound channels:
		public function addSoundChannel(p_soundChannel:SoundChannel):void {
			if (soundChannels == null) { soundChannels = new Dictionary(true); }
			soundChannels[p_soundChannel] = true;
		}
		
		public function removeSoundChannel(p_soundChannel:Timer):void {
			if (soundChannels == null) { return; }
			delete(soundChannels[p_soundChannel]);
		}
		
		public function cleanUpSoundChannels():void {
			for (var o:Object in soundChannels) {
				(o as SoundChannel).stop();
			}
		}
		
		// connections:
		public function addConnection(p_conn:Object):void {
			if (connections == null) { connections = new Dictionary(true); }
			connections[p_conn] = true;
		}
		
		public function removeConnection(p_conn:Timer):void {
			if (connections == null) { return; }
			delete(connections[p_conn]);
		}
		
		public function cleanUpConnections():void {
			for (var o:Object in connections) {
				cleanUpConnection(o);
			}
		}
		
		public function cleanUpConnection(p_conn:Object):void {
			// because we're unsure what type of connection we have, and what it's status is, we have to use try catch:
			try {
				var content:Object = p_conn.content;
				if (content is IDisposable) { content.dispose(); }
			} catch (e:*) {}
			try {
				p_conn.close();
			} catch (e:*) {}
			try {
				p_conn.unload();
			} catch (e:*) {}
			try {
				p_conn.cancel();
			} catch (e:*) {}
		}
		
		// event listeners:
		// this is a bit convoluted, but we don't want to maintain strong references back to event dispatchers.
		public function addEventListener(p_dispatcher:EventDispatcher,p_type:String,p_listener:Function,p_useCapture:Boolean=false,p_add:Boolean=false):void {
			if (p_add) {
				p_dispatcher.addEventListener(p_type,p_listener,p_useCapture,0,true);
			}
			if (listeners == null) { listeners = new Dictionary(true); }
			var hash:Object = listeners[p_dispatcher];
			if (hash == null) { hash = listeners[p_dispatcher] = {}; }
			var arr:Array = hash[p_type];
			if (arr == null) { hash[p_type] = arr = []; }
			// check for duplicates:
			var l:uint = arr.length;
			for (var i:uint=0; i<l; i++) {
				var o:Object = arr[i];
				if (o.l == p_listener && o.u == p_useCapture) { return; }
			}
			arr.push({l:p_listener, u:p_useCapture});
		}
		
		public function removeEventListener(p_dispatcher:EventDispatcher,p_type:String,p_listener:Function,p_useCapture:Boolean=false,p_remove:Boolean=false):void {
			if (p_remove) {
				p_dispatcher.removeEventListener(p_type,p_listener,p_useCapture);
			}
			if (listeners == null || listeners[p_dispatcher] == null || listeners[p_dispatcher][p_type] == null) { return; }
			var arr:Array = listeners[p_dispatcher][p_type];
			var l:uint = arr.length;
			for (var i:uint=0; i<l; i++) {
				var o:Object = arr[i];
				if (o.l == p_listener && o.u == p_useCapture) {
					arr.splice(i,1);
					return;
				}
			}
		}
		
		public function cleanUpEventListeners():void {
			for (var o:Object in listeners) {
				var types:Object = listeners[o];
				for (var type:String in types) {
					var arr:Array = types[type];
					while (arr.length > 0) {
						var obj:Object = arr.pop();
						try {
							(o as EventDispatcher).removeEventListener(type,(obj.l as Function),Boolean(obj.u));
						} catch (e:*) {}
						
					}
				}
			}
		}
		
		/*
		// event listeners:
		// this is a better model, but won't work due to a bug in the current player.
		// this is a bit convoluted, but we don't want to maintain strong references back to event dispatchers.
		public function addEventListener(p_dispatcher:EventDispatcher,p_type:String,p_listener:Function,p_useCapture:Boolean=false):void {
		if (listeners == null) { listeners = new Dictionary(true); }
		if (listeners[p_dispatcher] == null) { listeners[dispatcher] = new Dictionary(false); }
		if (listeners[p_dispatcher][p_type] == null) { listeners[p_dispatcher][p_type] = new Dictionary(true); }
		listeners[p_dispatcher][p_type][p_listener] = p_useCapture;
		}
		
		public function removeEventListener(p_dispatcher:EventDispatcher,p_type:String,p_listener:Function,p_useCapture:Boolean=false):void {
		try {
		delete(listeners[p_dispatcher][p_type][p_listener]);
		} catch (e:*) {}
		}
		
		public function cleanUpEventListeners():void {
		for (var o:Object in listeners) {
		var events:Dictionary = listeners[o];
		for (var e:Object in events) {
		var functions:Dictionary = events[e];
		for (var f:Object in functions) {
		try {
		(o as EventDispatcher).removeListener(String(e),(f as Function),Boolean(functions[f]));
		} catch (e:*) {}
		}
		
		}
		}
		}
		
		*/
		
	}
	
}
