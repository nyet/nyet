using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace Proto1
{
    public class FireEventTest
    {
        public static void Main()
        {
            // Create an instance of the class that will be firing an event.
            FireAlarm myFireAlarm = new FireAlarm();

            // Create an instance of the class that will be handling the event. Note that 
            // it receives the class that will fire the event as a parameter. 
            FireHandlerClass myFireHandler = new FireHandlerClass(myFireAlarm);

            //use our class to raise a few events and watch them get handled
            myFireAlarm.ActivateFireAlarm("Kitchen", 3);
            myFireAlarm.ActivateFireAlarm("Study", 1);
            myFireAlarm.ActivateFireAlarm("Porch", 5);

            return;
        }	//end of main
    }	// end of FireEventTest


    // FireEventArgs: a custom event inherited from EventArgs.
    public class FireEventArgs : EventArgs
    {
        public FireEventArgs(string room, int ferocity)
        {
            this.room = room;
            this.ferocity = ferocity;
        }

        // The fire event will have two pieces of information-- 
        // 1) Where the fire is, and 2) how "ferocious" it is.  

        public string room;
        public int ferocity;

    }	//end of class FireEventArgs

    // Class with a function that creates the eventargs and initiates the event
    public class FireAlarm
    {
        // Events are handled with delegates, so we must establish a FireEventHandler
        // as a delegate:
        public delegate void FireEventHandler(object sender, FireEventArgs fe);

        // Now, create a public event "FireEvent" whose type is our FireEventHandler delegate. 
        public event FireEventHandler FireEvent;

        // This will be the starting point of our event-- it will create FireEventArgs,
        // and then raise the event, passing FireEventArgs. 
        public void ActivateFireAlarm(string room, int ferocity)
        {
            FireEventArgs fireArgs = new FireEventArgs(room, ferocity);

            // Now, raise the event by invoking the delegate. Pass in 
            // the object that initated the event (this) as well as FireEventArgs. 
            // The call must match the signature of FireEventHandler.
            FireEvent(this, fireArgs);
        }
    }	// end of class FireAlarm
    
    // Class which handles the event
    class FireHandlerClass
    {
        // Create a FireAlarm to handle and raise the fire events. 
        public FireHandlerClass(FireAlarm fireAlarm)
        {
            // Add a delegate containing the ExtinguishFire function to the class'
            // event so that when FireAlarm is raised, it will subsequently execute 
            // ExtinguishFire.
            fireAlarm.FireEvent += new FireAlarm.FireEventHandler(ExtinguishFire);
        }

        // This is the function to be executed when a fire event is raised. 
        void ExtinguishFire(object sender, FireEventArgs fe)
        {
            Console.WriteLine("\nThe ExtinguishFire function was called by {0}.", sender.ToString());

            // Now, act in response to the event.
            if (fe.ferocity < 2)
                Console.WriteLine("This fire in the {0} is no problem.  I'm going to pour some water on it.", fe.room);
            else if (fe.ferocity < 5)
                Console.WriteLine("I'm using FireExtinguisher to put out the fire in the {0}.", fe.room);
            else
                Console.WriteLine("The fire in the {0} is out of control.  I'm calling the fire department!", fe.room);
        }
    }	//end of class FireHandlerClass
}
