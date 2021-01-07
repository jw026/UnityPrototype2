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
            currentSave.LoadBools();
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
        currentSave.newGame = false;
        foreach (var item in PlayerInventory.inventory.ItemList)
        {
            currentSave.inventoryItemPaths.Add(item.name);
        }
        string jsonData = JsonUtility.ToJson(currentSave, true);
        // currentSave.lastCheckPoint = Checkpoint.LastCheckpoint.name;
        File.WriteAllText(savePath, jsonData);
        
    }

}




[System.Serializable]
public class Save
{
    public bool newGame = true;
    public Vector3 playerPosition = new Vector3();
    public Dictionary<string, bool> savedBools = new Dictionary<string, bool>();
    public List<string> boolKeys = new List<string>();
    public List<bool> boolsToSave = new List<bool>();
    public string scene = "";
    public List<string> inventoryItemPaths = new List<string>();
    public string lastCheckPointName = "";


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
            if (!savedBools.ContainsKey(boolKeys[i]))
                savedBools.Add(boolKeys[i], boolsToSave[i]);
        }
        string debugtext = "";
        foreach (var item in savedBools)
        {
            debugtext += item.Key + item.Value;
        }

    }


}

