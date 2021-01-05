using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pickupable : Interactible
{
    public Pickupable thisObjectsPrefab;
    public override void Interact()
    {
        base.Interact();
        /* add thisobjectsprefab to player inventory */
    }
}
