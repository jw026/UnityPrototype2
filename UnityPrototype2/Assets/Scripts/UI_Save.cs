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
        SceneManager.LoadScene(mainMenuScene);
        Savemanager.currentSave = new Save();
    }
}
