using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerInteraction : MonoBehaviour
{
    List<IInteractible> interactibles;
    public List<IInteractible> GetInteractibles()
    {
        return new List<IInteractible>(GetComponents<IInteractible>());
    }


    public IInteractible GetClosestIInteractible()
    {
        if (interactibles.Count > 0)
        {
            IInteractible closest = interactibles[0];
            for (int i = 0; i < interactibles.Count; i++)
            {
                if (Vector3.Distance(closest.transform.position, transform.position) > Vector3.Distance(interactibles[i].transform.position, transform.position))
                {
                    closest = interactibles[i];
                }
            }
            return closest;
        }
        return null;
    }


    // Update is called once per frame
    void Update()
    {
        if (Input.GetButtonDown("Interact"))
        {
            Debug.Log("Interacted");
            if (closestInteractible != null) closestInteractible.Interact();
        }
    }
    IInteractible closestInteractible;
    private void FixedUpdate()
    {
        interactibles = GetInteractibles();
        closestInteractible = GetClosestIInteractible();

    }

}
