using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.IO;
using UnityEngine.SceneManagement;


public class Savemanager : MonoBehaviour
{
    public static Save currentSave = new Save();
    string savePath = "Save.save";

    public static Savemanager Instance
    {
        get => _instance;
    }
    private static Savemanager _instance;

    public void SetSavedScene(string sceneName)
    {
        currentSave.scene = sceneName;
    }

    private void Awake()
    {
        if (_instance == null)
        {
            _instance = this;

            DontDestroyOnLoad(_instance);
        }
        else Destroy(this);
    }


    public void LoadSave()
    {
        if (File.Exists(savePath))
        {
            currentSave = JsonUtility.FromJson<Save>(File.ReadAllText(savePath));
            SceneManager.LoadScene(currentSave.scene);
            PlayerInventory.inventory = new Inventory();
            foreach (var item in currentSave.inventoryItemPaths)
            {
                PlayerInventory.inventory.AddItem(Resources.Load<Item>("Items/" + item));
            }
        }
        else Debug.Log("no save found");
    }
    public void SaveGame()
    {
        currentSave.inventoryItemPaths = new List<string>();
        currentSave.SaveBools();
        foreach (var item in PlayerInventory.inventory.ItemList)
        {
            currentSave.inventoryItemPaths.Add(item.displayName);
        }
        string jsonData = JsonUtility.ToJson(currentSave, true);

        File.WriteAllText(savePath, jsonData);
    }

}




[System.Serializable]
public class Save
{
    public Vector3 playerPosition = new Vector3();
    public Dictionary<string, bool> savedBools = new Dictionary<string, bool>();
    public List<string> boolKeys = new List<string>();
    public List<bool> boolsToSave = new List<bool>();
    public string scene = "";
    public List<string> inventoryItemPaths = new List<string>();

    public void SaveBools()
    {
        foreach (var item in savedBools)
        {
            boolKeys.Add(item.Key);
            boolsToSave.Add(item.Value);
        }
    }
    public void LoadBools()
    {
        savedBools = new Dictionary<string, bool>();
        for (int i = 0; i < boolKeys.Count; i++)
        {
   //         savedBools.Add(boolKeys[i], )
        } 
    }


}
[System.Serializable]
public struct SerializableVector3
{
    public float x;
    public float y;
    public float z;


}
