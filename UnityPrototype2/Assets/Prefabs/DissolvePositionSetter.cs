using System.Collections;
using System.Collections.Generic;
using UnityEngine;


[ExecuteAlways]
public class DissolvePositionSetter : MonoBehaviour
{
   

    // Update is called once per frame
    void Update()
    {
        Shader.SetGlobalVector("PlayerPosition", transform.position);
    }
}
