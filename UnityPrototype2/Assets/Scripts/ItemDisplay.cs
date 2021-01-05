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
            itemName.text = item.name;

        }
        get => item;

    }
}



