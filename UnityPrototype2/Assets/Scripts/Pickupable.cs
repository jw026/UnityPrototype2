using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Pickupable : Interactible
{
    public Item item;
    public bool SavePosition;
    public override void Interact()
    {
        base.Interact();
        FindObjectOfType<PlayerInventory>().AddItem(item);
        Destroy(gameObject);
    }
}
