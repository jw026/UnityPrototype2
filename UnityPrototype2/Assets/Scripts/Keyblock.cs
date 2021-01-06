using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;
public class Keyblock : MonoBehaviour
{
    //List of objects that count as keys to trigger events
    [SerializeField] List<Item> keyObjects;


    public bool doOnce = false;
    bool doneThing = false;
    bool doneRemoveThing = false;

    public UnityEvent placedEvent;
    public UnityEvent removedEvent;


    Rigidbody objectPlaced = null;



    public void OnObjectPlaced()
    {
        placedEvent.Invoke();
    }
    public void OnObjectRemoved()
    {
        removedEvent.Invoke();
    }
    private void OnTriggerEnter(Collider other)
    {
  //      Debug.Log(other.gameObject.name + " entered");

        if (!objectPlaced && other.gameObject.GetComponent<Pickupable>() && keyObjects.Contains(other.gameObject.GetComponent<Pickupable>().item))
        {
           
            if (!doOnce || doOnce && !doneThing)
            {
                objectPlaced = other.gameObject.GetComponent<Rigidbody>();
                if (doOnce) doneThing = true;
                OnObjectPlaced();
            }
        }
    }

    private void OnTriggerExit(Collider other)
    {
      
 Debug.Log(other.gameObject.name + " left");
        if (other.gameObject.GetComponent<Rigidbody>() == objectPlaced)
        {
            if (!doOnce || doOnce && !doneRemoveThing)
            {
                if (doOnce) doneRemoveThing = true;
                removedEvent.Invoke();
            }

        }
    }

}
