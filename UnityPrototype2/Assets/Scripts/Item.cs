using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Item : Interactible
{
    public Item thisPrefab;
    public override void Interact()
    {
        base.Interact();
        FindObjectOfType<PlayerInventory>().AddItem(thisPrefab.GetComponent<Item>());
        Destroy(gameObject);
    }

}
