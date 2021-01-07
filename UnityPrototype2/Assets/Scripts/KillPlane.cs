using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class KillPlane : MonoBehaviour
{
    public GameObject player;
    
    private void OnTriggerEnter(Collider other)
    {
        if (player)
        {
            player.GetComponent<CharacterController>().enabled = false;
            player.transform.position = Checkpoint.LastCheckpoint.transform.position;
            player.GetComponent<CharacterController>().enabled = true;


        }

    }
}
