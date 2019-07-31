using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class Test : MonoBehaviour
{
    public Camera camera;
    public Transform layer1;
    public Transform layer2;

    void Start()
    {
        camera = GetComponent<Camera>();

        float dis = layer1.position.z - camera.transform.position.z;
        float height = dis * Mathf.Tan(Mathf.Deg2Rad * camera.fieldOfView / 2);
        float w = height * Screen.width / Screen.height * 2;
    }

}
