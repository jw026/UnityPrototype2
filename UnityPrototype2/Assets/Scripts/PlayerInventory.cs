using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PlayerInventory : MonoBehaviour
{

    public static Inventory inventory;
    UI_Inventory uiInventory;
    [SerializeField] Transform dropPoint;

    private void Awake()
    {
        uiInventory = FindObjectOfType<UI_Inventory>();
        if (inventory == null)
        {
            Debug.Log("making new inventory");
            inventory = new Inventory();

        }
    }


    public void AddItem(Item item)
    {
        inventory.AddItem(item);

    }
    public void RemoveItem(Item item)
    {
        inventory.RemoveItem(item);
    }
    public void DropItem(Item item)
    {
        RemoveItem(item);
        Instantiate(item.worldObjectPrefab, dropPoint.position, transform.rotation, null);
    }

}

