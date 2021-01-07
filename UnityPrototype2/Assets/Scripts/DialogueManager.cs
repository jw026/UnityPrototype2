using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public class DialogueManager : MonoBehaviour
{
    private Queue<string> sentences;
    [SerializeField] TMP_Text text;
    [SerializeField] GameObject canvas;
    void Start()
    {
        sentences = new Queue<string>();
    }
    
    public void StartDialogue (Dialogue dialogue)
    {
        Debug.Log("Starting conversation with" + dialogue.name);

       
        sentences.Clear();

        foreach (string sentence in dialogue.sentences)
        {
            sentences.Enqueue(sentence);
        }

        DisplayNextSentence();
    }

    public void DisplayNextSentence()
    {
        if (sentences.Count == 0)
        {
            EndDialogue();
            return;
        }

        string sentence = sentences.Dequeue();
        text.text = (sentence);
    }

    void EndDialogue()
    {
        canvas.gameObject.SetActive(false);
    }



}
