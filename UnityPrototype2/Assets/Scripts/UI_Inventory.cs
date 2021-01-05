using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UI_Inventory : MonoBehaviour
{
    private bool open = false;
    private Inventory inventory;
    [SerializeField] ItemDisplay itemDisplay;
    [SerializeField] ItemDisplay itemDisplay2;
    [SerializeField] GameObject uIInventoryMenu;
    List<ItemDisplay> itemDisplays;


    public void Start()
    {
        CloseInventory();
        itemDisplay.gameObject.SetActive(false);
        itemDisplay2.gameObject.SetActive(false);
    }
    public void SetInventory(Inventory inventory)
    {
        this.inventory = inventory;

    }

    public void Update()
    {
        if (
            Input.GetButtonDown("OpenInventory"))
        {
            if (open) CloseInventory();
            else OpenInventory();
        }

    }
    public void OpenInventory()
    {
        uIInventoryMenu.SetActive(true);
        open = true;
        itemDisplays = new List<ItemDisplay>();
        for (int i = 0; i < inventory.itemList.Count; i++)
        {
            ItemDisplay newItemDisplay = Instantiate(itemDisplay);
            newItemDisplay.transform.position = (itemDisplay.transform.position - itemDisplay2.transform.position) * i;
            newItemDisplay.gameObject.SetActive(true);

        }

    }

    public void CloseInventory()
    {
        uIInventoryMenu.SetActive(false);
        open = false;
        foreach (ItemDisplay item in itemDisplays)
        {
            Destroy(item.gameObject);
        }
    }

}
