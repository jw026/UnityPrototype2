using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Inventory
{

    public List<Item> ItemList
    {
        get => itemList;
    }
    List<Item> itemList;



    public Inventory()
    {
        itemList = new List<Item>();

        
        Debug.Log(itemList.Count);
    }

    public void AddItem(Item item)
    {
        itemList.Add(item);
    }
    public void RemoveItem(Item item)
    {
        itemList.Remove(item);
    }


}
