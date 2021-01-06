using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerInteraction : MonoBehaviour
{




    List<Interactible> interactibles;
    public List<Interactible> GetInteractibles()
    {
        return new List<Interactible>(FindObjectsOfType<Interactible>());
    }



    public Interactible GetClosestIInteractible()
    {
        if (interactibles.Count > 0)
        {
            Interactible closest = interactibles[0];
            for (int i = 0; i < interactibles.Count; i++)
            {
                if (Vector3.Distance(transform.position, interactibles[i].transform.position) <= interactibles[i].InteractRadius)
                    if (Vector3.Distance(closest.transform.position, transform.position) > Vector3.Distance(interactibles[i].transform.position, transform.position))
                    {
                        closest = interactibles[i];
                    }
            }
            return closest;
        }
        // Debug.Log("Did not find any interactibles");
        return null;
    }


    // Update is called once per frame
    void Update()
    {
        if (Input.GetButtonDown("Interact"))
        {
            interactibles = GetInteractibles();
            closestInteractible = GetClosestIInteractible();
            if (closestInteractible != null && Vector3.Distance(transform.position, closestInteractible.transform.position) <= closestInteractible.InteractRadius)
            {
                Debug.Log("Interacting with " + closestInteractible.transform.name);
                closestInteractible.Interact();
            }
        }
    }
    Interactible closestInteractible;
    private void FixedUpdate()
    {



    }

}
