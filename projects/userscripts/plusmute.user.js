// ==UserScript==
// @name          Google+ Mute Keyboard Shortcut
// @namespace     http://antimatter15.com/
// @description   Mute conversations in your stream by hitting "m"
// @include       https://plus.google.com/*
// @include       http://plus.google.com/*
// @require       https://ajax.googleapis.com/ajax/libs/jquery/1.6.1/jquery.min.js
// @version       1.3
// ==/UserScript==

document.addEventListener('keydown', function(e){
	//console.log('keydown fired'); <- console log doesn't work, use alert to debug.
	
	if(e.keyCode == 77) {
		console.log('Press m');
		
		function mouse(name){
			var evt = document.createEvent("MouseEvents");
			evt.initMouseEvent(name ? ('mouse'+name) : 'click', true, true, window, 0, 0, 0, 5, 5, false, false, false, false, 0, null);
			return evt;
		}
		
		if (!(document.activeElement.isContentEditable || /input|textarea/i.test(document.activeElement.tagName))){
			var selected = [].slice.call(document.querySelectorAll('#contentPane div[id^=update]'),0).filter(function(i){
				return getComputedStyle(i).getPropertyValue('border-left-color') == 'rgb(77, 144, 240)' //#4D90F0
			})[0];
			
			if(!selected) return;
			var undo_mute = selected.querySelector("span[title=Undo]");
			if(!undo_mute || window.getComputedStyle(undo_mute.parentNode.parentNode.parentNode).display == 'none'){
				var opt = selected.querySelector('span[title="Options menu"]');
				opt.click();
				
				var mute = [].slice.call(selected.querySelectorAll('div[role=menuitem]'),0).filter(function(e){
					return ~e.innerHTML.indexOf('Mute this post')
				})[0];
				mute.dispatchEvent(mouse('down'));
				mute.dispatchEvent(mouse('up'));
			}
		}
		else{
			undo_mute.dispatchEvent(mouse());
		}
	}
}, true);