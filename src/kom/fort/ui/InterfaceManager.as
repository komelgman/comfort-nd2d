package kom.fort.ui {

	import de.nulldesign.nd2d.display.Node2D;

	import flash.display.Stage;
	import flash.errors.IllegalOperationError;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;

	import kom.fort.ui.events.UIComponentEvent;
	import kom.promise.Deferred;
	import kom.promise.IPromise;

	public class InterfaceManager extends EventDispatcher {

		private var _wasInit : Boolean = false;
		private var _stage : Stage;
		private var _viewport : Node2D;
		private var _components : Dictionary = new Dictionary();

		public function InterfaceManager(stage : Stage, viewport : Node2D) {
			if (_wasInit) {
				throw new IllegalOperationError();
			}

			if (stage == null) {
				throw new ArgumentError();
			}

			_stage = stage;
			_viewport = viewport;

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
			var deferred : Deferred = new Deferred();

			component.addEventListener(Event.ADDED_TO_STAGE, function(e : Event) : void {
				component.removeEventListener(Event.ADDED_TO_STAGE, arguments.callee);
				deferred.resolve();
			});

			_viewport.addChild(component);

			return deferred.promise;
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
			var deferred : Deferred = new Deferred();

			component.addEventListener(Event.REMOVED_FROM_STAGE, function(event : Event) : void {
				component.removeEventListener(Event.REMOVED_FROM_STAGE, arguments.callee);
				deferred.resolve();
			}, false, 0, true);

			_viewport.removeChild(component);

			return deferred.promise;
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

		public function getViewport() : Node2D {
			if (!_wasInit) {
				throw new IllegalOperationError();
			}

			return _viewport;
		}
	}
}