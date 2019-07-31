using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetection : PostEffectBase
{
    public Shader shader;
    private Material _mat;
    public Material mat
    {
        get
        {
            if (_mat) return _mat;
            _mat = CheckShaderAndCreateMat(shader);
            Debug.Log(_mat);
            return _mat;
        }
    }
    [Range(0, 1)]
    public float edgesOnly = 0f;
    public Color edgeColor;
    public Color backgroundColor;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        mat.SetFloat("_EdgeOnly",edgesOnly);
        mat.SetColor("_EdgeColor", edgeColor);
        mat.SetColor("_BackgroundColor", backgroundColor);
        Graphics.Blit(source, destination, mat);
    }

}
