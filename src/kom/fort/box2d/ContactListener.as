package kom.fort.box2d {
	public class ContactListener extends b2ContactListener {

		override public function BeginContact(contact : b2Contact) : void {
			// getting the fixtures that collided
			var fixtureA : b2Fixture = contact.GetFixtureA();
			var fixtureB : b2Fixture = contact.GetFixtureB();

			var objA : * = fixtureA.GetBody().GetUserData();
			var objB : * = fixtureB.GetBody().GetUserData();

			if (objA is Box2DConnector && objB is Box2DConnector) {
				(objA as Box2DConnector).contact(objB);
				(objB as Box2DConnector).contact(objA);
			}
		}
	}
}