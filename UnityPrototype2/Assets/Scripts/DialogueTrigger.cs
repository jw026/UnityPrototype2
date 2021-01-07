using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DialogueTrigger : MonoBehaviour
{
    public Dialogue dialogue;
    [SerializeField] DialogueManager dialoguemanager;
    [SerializeField] GameObject canvas;

    public void TriggerDialogue ()
    {
        canvas.gameObject.SetActive(true);
        dialoguemanager.StartDialogue(dialogue);
    }

    private void OnTriggerEnter(Collider other)
    {
        Debug.Log("Starting conversation with" + dialogue.name);
        TriggerDialogue();

    }

    private void OnTriggerExit(Collider other)
    {
        Destroy(gameObject);
    }
}
