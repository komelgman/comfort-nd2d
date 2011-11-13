package kom.fort.ui {

	import de.nulldesign.nd2d.display.Node2D;

	import flash.display.DisplayObjectContainer;

	import flash.display.Stage;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.EventPhase;
	import flash.utils.Dictionary;

	import kom.fort.ui.events.UIComponentEvent;
	import kom.promise.Deferred;
	import kom.promise.IPromise;

	public class InterfaceManager extends EventDispatcher {

		private var _wasInit : Boolean = false;
		private var _components : Dictionary = new Dictionary();

		private var _stage : Stage;
		private var _viewport3D : Node2D;
		private var _viewportNative : DisplayObjectContainer;

		public function InterfaceManager(stage : Stage, viewport3D : Node2D, viewportNative : DisplayObjectContainer = null) {
			if (_wasInit) {
				throw new IllegalOperationError();
			}

			if (stage == null) {
				throw new ArgumentError();
			}

			_stage = stage;
			_viewport3D = viewport3D;
			_viewportNative = viewportNative ? viewportNative : stage;

			_wasInit = true;
		}

		public function addComponent(component : ManagedComponent) : void {
			if (component == null || hasComponent(component.getName())) {
				throw new ArgumentError();
			}

			_components[component.getName()] = component;

			component.addEventListener(UIComponentEvent.HIDE_FINISH, redispatchEvent, false, 0, true);
			component.addEventListener(UIComponentEvent.HIDE_INIT, redispatchEvent, false, 0, true);
			component.addEventListener(UIComponentEvent.SHOW_FINISH, redispatchEvent, false, 0, true);
			component.addEventListener(UIComponentEvent.SHOW_INIT, redispatchEvent, false, 0, true);
		}

		protected function redispatchEvent(event : Event) : void {
			if (hasEventListener(event.type)) {
				dispatchEvent(event);
			}
		}

		public function removeComponent(name : String) : void {
			if (!hasComponent(name)) {
				return;
			}

			var component : ManagedComponent = _components[name] as ManagedComponent;

			if (component.visible) {
				throw new IllegalOperationError('Can\'t remove visible component.');
			}

			component.removeEventListener(UIComponentEvent.HIDE_FINISH, redispatchEvent);
			component.removeEventListener(UIComponentEvent.HIDE_INIT, redispatchEvent);
			component.removeEventListener(UIComponentEvent.SHOW_FINISH, redispatchEvent);
			component.removeEventListener(UIComponentEvent.SHOW_INIT, redispatchEvent);

			component.dispose();

			delete _components[name];
		}

		public function hasComponent(name : String) : Boolean {
			return name in _components;
		}


		public function showComponent(component : ManagedComponent) : void {
			if (invalidForShow(component)) {
				return;
			}

			addToViewport(component).done(function() : void {
				component.build().done(function() : void {
					component.show();
				});
			});
		}

		private function invalidForShow(component : ManagedComponent) : Boolean {
			if (!hasComponent(component.getName())) {
				throw new ArgumentError();
			}

			return component.visible || component.isAnimated() || component.isBuilding();
		}

		private function addToViewport(component : ManagedComponent) : IPromise {
			return listViewportEvent(component,  Event.ADDED_TO_STAGE);
		}

		private function listViewportEvent(component : ManagedComponent, eventName : String) : IPromise {
			var deferred : Deferred = new Deferred(), trigger : Number = 1;

			if (component.displayObject) {
				component.displayObject.addEventListener(eventName, addedToStageHandler);
				_viewportNative.addChild(component.displayObject);
				trigger++;
			}

			component.addEventListener(eventName, addedToStageHandler, false, 0, true);
			_viewport3D.addChild(component);

			return deferred.promise;




			function addedToStageHandler(e : Event) : void {
				e.currentTarget.removeEventListener(eventName, arguments.callee, e.eventPhase == EventPhase.CAPTURING_PHASE);
				if (--trigger == 0) {
					deferred.resolve();
				}
			}
		}



		public function hideComponent(component : ManagedComponent) : void {
			if (invalidForHide(component)) {
				return;
			}

			component.hide().done(function() : void {
				removeFromViewport(component).done(function() : void {
					component.destroy();
				});
			});
		}

		private function invalidForHide(component : ManagedComponent) : Boolean {
			if (!hasComponent(component.getName())) {
				throw new ArgumentError();
			}

			return (!component.visible) || component.isAnimated();
		}

		private function removeFromViewport(component : ManagedComponent) : IPromise {
			return listViewportEvent(component,  Event.REMOVED_FROM_STAGE);
		}


		public function switchComponent(current : ManagedComponent, next : ManagedComponent) : void {
			if (invalidForHide(current) || invalidForShow(next) || (current == next)) {
				return;
			}

			addToViewport(next).done(function() : void {
				Deferred.parallel(
					current.hide(),
					next.build()
				).done(function() : void {
					removeFromViewport(current).done(function() : void {
						current.destroy();
					});

					next.show();
				});
			});
		}


		public function getComponent(name : String) : ManagedComponent {
			if (name in _components) {
				return _components[name];
			}

			throw new ArgumentError();
		}


		public function getStage() : Stage {
			if (!_wasInit) {
				throw new IllegalOperationError();
			}

			return _stage;
		}

		public function getViewport3D() : Node2D {
			if (!_wasInit) {
				throw new IllegalOperationError();
			}

			return _viewport3D;
		}

		public function getViewportNative() : DisplayObjectContainer {
			if (!_wasInit) {
				throw new IllegalOperationError();
			}

			return _viewportNative;
		}
	}
}