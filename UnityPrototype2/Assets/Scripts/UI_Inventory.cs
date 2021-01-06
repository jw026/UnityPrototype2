using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UI_Inventory : MonoBehaviour
{
    private bool open = false;

    [SerializeField] ItemDisplay itemDisplay;
    [SerializeField] ItemDisplay itemDisplay2;
    [SerializeField] GameObject uIInventoryMenu;
    List<ItemDisplay> itemDisplays = new List<ItemDisplay>();


    public void Start()
    {
        RefreshDisplays();
        CloseInventory();
        itemDisplay.gameObject.SetActive(false);
        itemDisplay2.gameObject.SetActive(false);
    }


    public void Update()
    {
        if (Input.GetButtonDown("OpenInventory"))
        {
            if (open) CloseInventory();
            else OpenInventory();
        }

    }
    public void OpenInventory()
    {
        uIInventoryMenu.SetActive(true);
        open = true;
        RefreshDisplays();
        Time.timeScale = 0;
    }
    public void RefreshDisplays()
    {
    //    Debug.Log(($"Destroying {0} items" ,itemDisplays.Count));
        foreach (ItemDisplay display in itemDisplays)
        {
            Destroy(display.gameObject);
        }

        itemDisplays = new List<ItemDisplay>();

        for (int i = 0; i < PlayerInventory.inventory.ItemList.Count; i++)
        {
            ItemDisplay newItemDisplay = Instantiate(itemDisplay, itemDisplay.transform.parent);
            newItemDisplay.transform.position = itemDisplay.transform.position + (itemDisplay2.transform.position - itemDisplay.transform.position) * i;
            newItemDisplay.Item = PlayerInventory.inventory.ItemList[i];
            newItemDisplay.gameObject.SetActive(true);
            itemDisplays.Add(newItemDisplay);
        }
    }

    public void CloseInventory()
    {
        uIInventoryMenu.SetActive(false);
        open = false;
        Time.timeScale = 1;
    }

}
