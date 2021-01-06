using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LiftingBlocks : MonoBehaviour
{
  [SerializeField]  Animator animator;
    public bool lock1 = false;
    public bool lock2 = false;
    public void ToggleLock1()
    {
        lock1 = !lock1;
        if (lock1 && lock2)
        {
            LiftBlocks();
        }

    }
    public void ToggleLock2()
    {
        lock2 = !lock2;
        if (lock1 && lock2)
        {
            LiftBlocks();
        }

    }

    public void LiftBlocks()
    {
        animator.SetBool("Lift", true);
    }

}
