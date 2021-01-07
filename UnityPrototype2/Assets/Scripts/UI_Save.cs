using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class UI_Save : MonoBehaviour
{
    [SerializeField] string mainMenuScene = "MainMenu";
    public void SaveGame()
    {
        Savemanager.Instance.SaveGame();
        Savemanager.currentSave = new Save();
        SceneManager.LoadScene(mainMenuScene);
    }
}
