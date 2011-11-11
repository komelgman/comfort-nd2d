package kom.fort.ui.widget {
	import de.nulldesign.nd2d.display.Node2D;

	import flash.display.Stage;
	import flash.events.Event;

	import kom.fort.ui.InterfaceManager;
	import kom.fort.ui.ManagedComponent;

	public class WidgetManager {

		/*
		 * Initialization
		 */


		protected static var _manager : InterfaceManager;

		public static function init(stage : Stage, viewport : Node2D = null) : void {
			_manager = new InterfaceManager(stage, viewport);
		}


		/*
		 * Base functional
		 */


		public static function addWidget(widget : Widget) : void {
			_manager.addComponent(widget as ManagedComponent);
		}

		public static function removeWidget(name : String) : void {
			_manager.removeComponent(name);
		}

		public static function hasWidget(name : String) : Boolean {
			return _manager.hasComponent(name);
		}

		public static function showWidget(name : String) : void {
			var widget : ManagedComponent = _manager.getComponent(name);
			_manager.showComponent(widget);
		}

		public static function hideWidget(name : String) : void {
			var widget : ManagedComponent = _manager.getComponent(name);
			_manager.hideComponent(widget);
		}

		public static function getWidget(name : String) : Widget {
			return _manager.getComponent(name) as Widget;
		}


		/*
		 * Some helpers
		 */

		public static function addEventListener(type : String, listener : Function, useCapture : Boolean = false, priority : int = 0, useWeakReference : Boolean = false) : void {
			_manager.addEventListener(type, listener, useCapture, priority, useWeakReference);
		}

		public static function removeEventListener(type : String, listener : Function, useCapture : Boolean = false) : void {
			_manager.removeEventListener(type, listener, useCapture);
		}

		public static function dispatchEvent(event : Event) : Boolean {
			return _manager.dispatchEvent(event);
		}

		public static function hasEventListener(type : String) : Boolean {
			return _manager.hasEventListener(type);
		}


		public static function getStage() : Stage {
			return _manager.getStage();
		}

		public static function getViewport() : Node2D {
			return _manager.getViewport();
		}
	}
}