using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BasicCamera : MonoBehaviour
{
    // Start is called before the first frame update

    [SerializeField] float sensitivity = 10;
    // Update is called once per frame
    void Update()
    {

        if (!UI_Inventory.Paused)
        {
            Debug.Log(Input.GetAxis("Mouse X") + " " + transform.eulerAngles);
            transform.Rotate(0, sensitivity * Input.GetAxis("Mouse X"), 0);
        }
    }
}
