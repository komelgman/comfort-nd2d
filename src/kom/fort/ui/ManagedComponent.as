package kom.fort.ui {

	import de.nulldesign.nd2d.display.*;

	import flash.utils.getQualifiedClassName;

	import kom.exceptions.AbstractClassError;
	import kom.fort.ui.events.UIComponentEvent;
	import kom.promise.Deferred;
	import kom.promise.IPromise;

	public class ManagedComponent extends Node2DContainer {

		private static var _componentNumber : int = 0;

		private var _animated : Boolean = false;
		private var _building : Boolean = false;
		private var _buildComplete : Boolean = false;

		protected var _name : String;

		/**
		 * @param name - the name of the component
		 */
		public function ManagedComponent(name : String = null) {
			super();

			if (getQualifiedClassName(this) == "kom.fort.ui::ManagedComponent")
				throw new AbstractClassError();

			_name = name == null ? ("default_" + (++_componentNumber)) : name;

			visible = false;
		}


		/**
		 * Force the show of this component
		 */
		final public function show() : IPromise {
			var deferred : Deferred = new Deferred();

			beforeShow();
			showEffect().then(function() : void {
				afterShow();
				deferred.resolve();
			}, deferred.reject);

			return deferred.promise;
		}

		/**
		 * Override this method
		 * This method is called to activate the transition In
		 * @example
		 * <listing version="3.0">
		 *    override protected function showEffect() : void {
		 *        var d : Deferred = new Deferred();
		 *
		 *        this.alpha = 0;
		 *        Tweener.addTween(this, { alpha: 1, time: 1.5, onComplete: d.resolve });
		 *
		 *        return d.promise;
		 *    }
		 * </listing>
		 */
		protected function showEffect() : IPromise {
			return Deferred.fakePromise();
		}

		private function beforeShow() : void {
			disable();
			visible = true;
			_animated = true;

			if (hasEventListener(UIComponentEvent.SHOW_INIT)) {
				dispatchEvent(new UIComponentEvent(UIComponentEvent.SHOW_INIT, this));
			}
		}

		private function afterShow() : void {
			_animated = false;
			enable();

			if (hasEventListener(UIComponentEvent.SHOW_FINISH)) {
				dispatchEvent(new UIComponentEvent(UIComponentEvent.SHOW_FINISH, this));
			}
		}

		/**
		 * Force this component to be hided
		 */
		final public function hide() : IPromise {
			var deferred : Deferred = new Deferred();

			beforeHide();
			hideEffect().then(function() : void {
				afterHide();
				deferred.resolve();
			}, deferred.reject);

			return deferred.promise;
		}

		/**
		 * Override this method
		 * This method is called to activate the transition Out
		 * @example
		 * <listing version="3.0">
		 *    override protected function hideEffect() : IPromise {
		 *        var d : Deferred = new Deferred();
		 *        this.alpha = 1;
		 *        Tweener.addTween(this, { alpha: 0, time: 1.5, onComplete: d.resolve });
		 *
		 *        return d.promise;
		 *    }
		 * </listing>
		 */
		protected function hideEffect() : IPromise {
			return Deferred.fakePromise();
		}

		private function beforeHide() : void {
			_animated = true;
			disable();

			if (hasEventListener(UIComponentEvent.HIDE_INIT)) {
				dispatchEvent(new UIComponentEvent(UIComponentEvent.HIDE_INIT, this));
			}
		}

		private function afterHide() : void {
			_animated = false;
			visible = false;

			if (hasEventListener(UIComponentEvent.HIDE_FINISH)) {
				dispatchEvent(new UIComponentEvent(UIComponentEvent.HIDE_FINISH, this));
			}
		}

		/**
		 * Force this component to be build
		 */
		final public function build() : IPromise {
			_building = true;
			return construct().done(function() : void {
				_building = false;
				_buildComplete = true;
			});
		}

		/**
		 * Override this method to custom construct component
		 * @example
		 * <listing version="3.0">
		 *    override protected function construct() : IPromise {
		 *        _mainMenu = AssetManager.createClip('mainMenu');
		 *        addChild(_mainMenu);
		 *
		 *        _mainMenu.someitem1.addEventListener(...);
		 *
		 *        return Deferred.fakePromise();
		 *    }
		 * </listing>
		 */
		protected function construct() : IPromise {
			return Deferred.fakePromise();
		}

		/**
		 * Override the destroy method
		 * This method is used in the finalization (after hide) of the component
		 * Warning : Use DISPOSE method for finalization after component removed
		 *
		 * @example
		 * <listing version="3.0">
		 *    override protected function destroy() : void {
		 *        _mainMenu = null;
		 *        super.destroy();
		 *    }
		 * </listing>
		 */
		public function destroy() : void {
			_buildComplete = false;
		}

		public function getName() : String {
			return _name;
		}

		public function isAnimated() : Boolean {
			return _animated;
		}

		public function isBuilding() : Boolean {
			return _building;
		}

		public function isBuildComplete() : Boolean {
			return _buildComplete;
		}
	}
}