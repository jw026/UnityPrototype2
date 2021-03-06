﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Events;

public class Interactible : MonoBehaviour
{
    public UnityEvent interactEvent;

    [SerializeField] float interactRadius;
    public float InteractRadius { get => interactRadius; }

    public virtual void Interact()
    {

        interactEvent.Invoke();
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = new Color(0, 1, 0, .5f);
        Gizmos.DrawSphere(transform.position, interactRadius);
    }

}


