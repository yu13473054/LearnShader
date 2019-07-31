using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BSC : PostEffectBase
{
    public Shader bscShader;
    private Material _bscMat;
    public Material bscMat
    {
        get
        {
            if (_bscMat) return _bscMat;
            _bscMat = CheckShaderAndCreateMat(bscShader);
            return _bscMat;
        }
    }
    [Range(0,3)]
    public float brightness = 1f;
    [Range(0, 3)]
    public float saturation = 1f;
    [Range(0, 3)]
    public float contrast = 1f;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        bscMat.SetFloat("_Brightness", brightness);
        bscMat.SetFloat("_Saturation", saturation);
        bscMat.SetFloat("_Contrast", contrast);
        Graphics.Blit(source, destination, bscMat);
    }
}
