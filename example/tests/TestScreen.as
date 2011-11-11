package tests {
	import caurina.transitions.Tweener;

	import kom.fort.ui.screen.Screen;
	import kom.promise.Deferred;
	import kom.promise.IPromise;

	public class TestScreen extends Screen {

		public function TestScreen(name : String) {
			super(name);
		}

		override protected function showEffect() : IPromise {
			var deferred : Deferred = new Deferred();

			this.alpha = 0.0;
			Tweener.addTween(this, { alpha: 1.0, time: 1.5, onComplete: deferred.resolve, transition: "easeInQuart" });

			return deferred.promise;
		}

		override protected function hideEffect() : IPromise {
			var d : Deferred = new Deferred();

			this.alpha = 1.0;
			Tweener.addTween(this, { alpha: 0.0, time: 2.0, onComplete: d.resolve, transition: "easeInQuart" });

			return d.promise;
		}

		override protected function construct() : IPromise {
			addChild(new Map());

			return Deferred.fakePromise();
		}

		override public function destroy() : void {
			dispose();
			removeAllChildren();
			super.destroy();
		}
	}
}


import de.nulldesign.nd2d.display.Node2DContainer;
import de.nulldesign.nd2d.display.Sprite2D;
import de.nulldesign.nd2d.materials.BlendModePresets;
import de.nulldesign.nd2d.materials.texture.Texture2D;

import flash.display.BitmapData;
import flash.events.Event;
import flash.events.MouseEvent;
import flash.geom.Point;

class Map extends Node2DContainer {

	[Embed(source="/assets/starfield.jpg")]
	private var starFieldTexture : Class;

	[Embed(source="/assets/starfield.png")]
	private var starFieldTexture2 : Class;

	[Embed(source="/assets/test.png")]
	private var testTexture : Class;

	private var backgroundSlice0 : Sprite2D;
	private var backgroundSlice1 : Sprite2D;
	private var map : Node2DContainer;

	public function Map() {
		super();

		width = 10000;
		height = 10000;

		backgroundSlice0 = new Sprite2D(Texture2D.textureFromBitmapData(new starFieldTexture().bitmapData, true));
		addChild(backgroundSlice0);

		backgroundSlice1 = new Sprite2D(Texture2D.textureFromBitmapData(new starFieldTexture2().bitmapData, true));
		backgroundSlice1.blendMode = BlendModePresets.ADD;
		addChild(backgroundSlice1);

		map = new Node2DContainer();
		addChild(map);

		var test2 : Sprite2D;
		for (var i : Number = 0; i < 10; ++i) {
			var bitmap : BitmapData = (new testTexture()).bitmapData;

			test2 = new Sprite2D(Texture2D.textureFromBitmapData(bitmap));
			test2.width = test2.height = 70;

			test2.x = (i - 5) * 80 + 40;
			map.addChild(test2);
		}

		addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		addEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);

		addEventListener(MouseEvent.MOUSE_DOWN, startMoveHandler);
		addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
		addEventListener(MouseEvent.MOUSE_UP, endMoveHandler);
	}

	private var isDrag : Boolean = false;
	private var startPoint : Point = new Point();
	private var mapCoord : Point = new Point();
	private var mapDelta : Point = new Point();

	private function startMoveHandler(event : MouseEvent) : void {
		isDrag = true;
		startPoint.x = event.localX;
		startPoint.y = event.localY;
		mapCoord.x = map.x;
		mapCoord.y = map.y;
	}

	private function moveHandler(event : MouseEvent) : void {
		if (isDrag) {
			move(mapCoord.x - (startPoint.x - event.localX), mapCoord.y - (startPoint.y - event.localY));
		}
	}

	private function move(mapX : Number, mapY : Number) : void {
		map.x = mapX;
		map.y = mapY;

		var dX : Number = ((stage.stageWidth >> 1) - mapX) / map.scaleX;
		var dY : Number = ((stage.stageHeight >> 1) - mapY) / map.scaleY;

		backgroundSlice0.material.uvOffsetX = dX * 0.00004;
		backgroundSlice0.material.uvOffsetY = dY * 0.00004;

		backgroundSlice1.material.uvOffsetX = dX * 0.0005;
		backgroundSlice1.material.uvOffsetY = dY * 0.0005;
	}

	private function endMoveHandler(event : MouseEvent) : void {
		isDrag = false;
		mapDelta.x = (map.x - (stage.stageWidth >> 1)) / (stage.stageWidth >> 1);
		mapDelta.y = (map.y - (stage.stageHeight >> 1)) / (stage.stageHeight >> 1);
	}


	private function addedToStage(e : Event) : void {
		removeEventListener(Event.ADDED_TO_STAGE, addedToStage);

		stage.addEventListener(Event.RESIZE, stageResized);
		stageResized();

		map.x = stage.stageWidth >> 1;
		map.y = stage.stageHeight >> 1;
	}

	private function removedFromStage(event : Event) : void {
		removeEventListener(Event.REMOVED_FROM_STAGE, removedFromStage);
		stage.removeEventListener(Event.RESIZE, stageResized);

		backgroundSlice0.dispose();
		backgroundSlice1.dispose();

		map.dispose();
		map.removeAllChildren();
	}


	private function stageResized(e : Event = null) : void {

		map.scaleX = map.scaleY = stage.stageWidth / 800;

		if (stage.stageWidth > stage.stageHeight) {
			backgroundSlice0.width = backgroundSlice1.width = stage.stageWidth;

			backgroundSlice0.scaleY = backgroundSlice0.scaleX;
			backgroundSlice1.scaleY = backgroundSlice1.scaleX;
		} else {
			backgroundSlice0.height = backgroundSlice1.height = stage.stageHeight;

			backgroundSlice0.scaleX = backgroundSlice0.scaleY;
			backgroundSlice1.scaleX = backgroundSlice1.scaleY;
		}

		backgroundSlice0.x = backgroundSlice1.x = stage.stageWidth >> 1;
		backgroundSlice0.y = backgroundSlice1.y = stage.stageHeight >> 1;

		move(mapDelta.x * (stage.stageWidth >> 1) + (stage.stageWidth >> 1), mapDelta.y * (stage.stageHeight >> 1) + (stage.stageHeight >> 1));
	}


	override public function handleDeviceLoss() : void {
		super.handleDeviceLoss();

		backgroundSlice0.texture.bitmap = new starFieldTexture().bitmapData;
		backgroundSlice1.texture.bitmap = new starFieldTexture2().bitmapData;
	}
}