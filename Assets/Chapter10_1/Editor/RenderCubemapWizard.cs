using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEditor;

public class RenderCubemapWizard : ScriptableWizard
{
    public Transform posTrans;
    public Cubemap cubemap;

    private void OnWizardCreate()
    {
        GameObject go = new GameObject("CubeMapCamera");
        Camera cam = go.AddComponent<Camera>();
        go.transform.position = posTrans.position;
        cam.RenderToCubemap(cubemap);
        DestroyImmediate(go);
    }

    private void OnWizardUpdate()
    {
        helpString = "选择需要渲染的Transform和Cubemap！";
        isValid = posTrans && cubemap;
    }

    [MenuItem("Tools/Render cubemap")]
    static void RenderCubemap()
    {
        ScriptableWizard.DisplayWizard<RenderCubemapWizard>("Render cubemap", "render", "aa");
    }
}
