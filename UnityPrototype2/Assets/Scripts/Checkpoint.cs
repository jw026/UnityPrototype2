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
        LastCheckpoint = this;
        // Set this as the current checkpoint
    }

}
