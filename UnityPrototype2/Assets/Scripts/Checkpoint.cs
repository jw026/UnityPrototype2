using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Checkpoint : MonoBehaviour
{
    public static Checkpoint LastCheckpoint;
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.GetComponent<PlayerMovement>())
        {
            SetAsCheckPoint();
        }
    }

    public void SetAsCheckPoint()
    {
        Debug.Log("Setting " + this.name + " as last checkpoint");
        LastCheckpoint = this;
        Savemanager.currentSave.lastCheckPointName = this.name;
        // Set this as the current checkpoint
    }
    private void Awake()
    {
        //I am aware that this will be done for every checkpoint but i am lazy and need the last checkpoint to be found when the scene has been loaded. 
        if (LastCheckpoint == null && Savemanager.currentSave.lastCheckPointName != "" && GameObject.Find(Savemanager.currentSave.lastCheckPointName) != null)
        {
            LastCheckpoint = GameObject.Find(Savemanager.currentSave.lastCheckPointName).GetComponent<Checkpoint>();
            Debug.Log("Successfully loaded last checkpoint");
        }
    }
}
