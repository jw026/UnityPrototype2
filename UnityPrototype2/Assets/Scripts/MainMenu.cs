﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class MainMenu : MonoBehaviour
{

    public string newGameScene = "";

    public void NewGame()
    {
        Savemanager.currentSave.scene = newGameScene;
        Savemanager.currentSave.newGame = true;
        SceneManager.LoadScene(newGameScene);
        
    }

    public void LoadGame()
    {
        Savemanager.Instance.LoadSave();
      //  SceneManager.LoadScene(Savemanager.currentSave.scene);
    }

    public void CloseGame()
    {
        Application.Quit();
    }
}
