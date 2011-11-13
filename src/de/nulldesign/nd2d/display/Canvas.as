package de.nulldesign.nd2d.display {
	import de.nulldesign.nd2d.utils.StatsObject;

	import flash.display3D.Context3D;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Vector3D;

	public class Canvas extends Node2DContainer {

		internal var br : Number = 0.0;
		internal var bg : Number = 0.0;
		internal var bb : Number = 0.0;

		private var _backGroundColor : Number = 0x000000;

		public function get backGroundColor() : Number {
			return _backGroundColor;
		}

		public function set backGroundColor(value : Number) : void {
			_backGroundColor = value;
			br = (backGroundColor >> 16) / 255.0;
			bg = (backGroundColor >> 8 & 255) / 255.0;
			bb = (backGroundColor & 255) / 255.0;
		}

		public function createLayer() : Node2DContainer {
			return addChild(new Node2DContainer()) as Node2DContainer;
		}

		public function bindEvents() : void {
			addEventListener(Event.ADDED_TO_STAGE, function (event : Event) : void {
				stage.addEventListener(MouseEvent.CLICK, onMouseEventHandler);
				stage.addEventListener(MouseEvent.MOUSE_DOWN, onMouseEventHandler);
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseEventHandler);
				stage.addEventListener(MouseEvent.MOUSE_UP, onMouseEventHandler);
			});

			addEventListener(Event.REMOVED_FROM_STAGE, function(event : Event) : void {
				stage.removeEventListener(MouseEvent.CLICK, onMouseEventHandler);
				stage.removeEventListener(MouseEvent.MOUSE_DOWN, onMouseEventHandler);
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseEventHandler);
				stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseEventHandler);
			});
		}

		protected var mousePosition : Vector3D = new Vector3D(0.0, 0.0, 0.0, 1.0);
		protected var topMostMouseNode : Node2D = null;

		protected function onMouseEventHandler(event : MouseEvent) : void {
			if (mouseEnabled && stage && camera) {
				// transformation of normalized coordinates between -1 and 1
				mousePosition.x = (stage.mouseX - 0.0) / camera.sceneWidth * 2.0 - 1.0;
				mousePosition.y = -((stage.mouseY - 0.0) / camera.sceneHeight * 2.0 - 1.0);

				var newTopMostMouseNode : Node2D = processMouseEvent(mousePosition, event.type, camera.getViewProjectionMatrix());
				if (newTopMostMouseNode) {
					for each(var mouseEvent : MouseEvent in newTopMostMouseNode.mouseEvents) {

						if (topMostMouseNode && mouseEvent.type == MouseEvent.MOUSE_OVER) {
							topMostMouseNode.mouseInNode = false;
							topMostMouseNode.dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT, true, false, topMostMouseNode.mouseX, topMostMouseNode.mouseY));
							newTopMostMouseNode.mouseInNode = true;
						}

						newTopMostMouseNode.dispatchEvent(mouseEvent);
					}

					topMostMouseNode = newTopMostMouseNode;
				}
			}
		}

		override internal function drawNode(context : Context3D, camera : Camera2D, parentMatrixChanged : Boolean, statsObject : StatsObject) : void {
			for each(var child : Node2D in children) {
				child.drawNode(context, camera, false, statsObject);
			}
		}
	}
}