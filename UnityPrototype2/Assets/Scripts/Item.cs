using System.Collections;
using System.Collections.Generic;
using UnityEngine;
[CreateAssetMenu(fileName = "New Item", menuName = "Inventory/Item", order = 1)][System.Serializable]
public class Item : ScriptableObject
{
    public string displayName;
    public GameObject worldObjectPrefab;

}
