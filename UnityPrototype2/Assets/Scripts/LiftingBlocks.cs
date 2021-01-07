using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LiftingBlocks : MonoBehaviour
{
    [SerializeField] Animator animator;
    public string saveKey;
    private void Start()
    {
        if (saveKey != null)
        {
            if (Savemanager.currentSave.savedBools.ContainsKey(saveKey+ "lock1"))
            {
                Lock1 = Savemanager.currentSave.savedBools[saveKey + "lock1"];
            }else
            {
                Savemanager.currentSave.savedBools.Add(saveKey + "lock1", lock1);
            }
            if (Savemanager.currentSave.savedBools.ContainsKey(saveKey + "lock2"))
            {
                Lock2 = Savemanager.currentSave.savedBools[saveKey + "lock2"];
                
            }else
            {
                Savemanager.currentSave.savedBools.Add(saveKey + "lock2", lock2);
            }
        }
    }

    [SerializeField] bool lock1 = false;
    [SerializeField] bool lock2 = false;

    public bool Lock1
    {
        get => lock1;
        set
        {
            if (saveKey != null)
            {
                Save save = Savemanager.currentSave;
                save.savedBools[saveKey + "lock1"] = value;

            }
            lock1 = value;
        }
    }
    public bool Lock2
    {
        get => lock2;
        set
        {
            if (saveKey != null)
            {
                Save save = Savemanager.currentSave;
                save.savedBools[saveKey + "lock2"] = value;

            }
            lock2 = value;
        }
    }

    public void ToggleLock1()
    {
        Lock1 = !Lock1;
        if (Lock1 && Lock2)
        {
            LiftBlocks();
        }

    }
    public void SetLock1(bool value) { Lock1 = value; }
    public void SetLock2(bool value) { Lock2 = value; }

    public void ToggleLock2()
    {
        Lock2 = !Lock2;
        if (Lock1 && Lock2)
        {
            LiftBlocks();
        }

    }

    public void LiftBlocks()
    {
        animator.SetBool("Lift", true);
    }

    public void LoadState()
    {
        if (saveKey != "")
        {
            Save save = Savemanager.currentSave;
            if (Savemanager.currentSave.savedBools.ContainsKey(saveKey + Lock1))
            {
                Lock1 = save.savedBools[saveKey + Lock1];
            }
            if (Savemanager.currentSave.savedBools.ContainsKey(saveKey + Lock2))
            {
                Lock2 = save.savedBools[saveKey + Lock2];
            }
            if (Lock1 && Lock2) LiftBlocks();
        }
    }


}
