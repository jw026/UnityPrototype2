using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class ItemDisplay : MonoBehaviour
{
    [SerializeField] TMP_Text itemName;
    private Item item;
    public Item Item

    {

        set
        {
            item = value;
            itemName.text = value.displayName;

        }
        get => item;

    }

    public void DropItem()
    {
        PlayerInventory playerInventory = FindObjectOfType<PlayerInventory>();
        playerInventory.DropItem(item);
        FindObjectOfType<UI_Inventory>().RefreshDisplays();

    }

}



