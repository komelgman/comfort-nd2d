package de.nulldesign.nd2d.display {
	import de.nulldesign.nd2d.utils.StatsObject;

	import flash.display3D.Context3D;

	public class Node2DContainer extends Node2D {

		public function Node2DContainer() {
			super();

			enable();
		}

		public function enable() : void {
			mouseEnabled = true;
		}

		public function disable() : void {
			mouseEnabled = false;
		}

		override internal function drawNode(context : Context3D, camera : Camera2D, parentMatrixChanged : Boolean, statsObject : StatsObject) : void {
			if (!_visible) {
				return;
			}

			if (invalidateColors) {
				updateColors();
			}

			var myMatrixChanged : Boolean = invalidateMatrix;
			if (invalidateMatrix) {
				updateLocalMatrix();
			}

			if (parentMatrixChanged || myMatrixChanged) {
				updateWorldMatrix();
			}

			for each(var child : Node2D in children) {
				child.drawNode(context, camera, myMatrixChanged, statsObject);
			}
		}

		override public function set width(value : Number) : void {
			_width = value;
		}

		override public function set height(value : Number) : void {
			_height = value;
		}
	}
}