using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlurWithDepthTex : PostEffectBase
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
    private Camera _cma;
    public Camera cam
    {
        get
        {
            if (_cma) return _cma;
            _cma = GetComponent<Camera>();
            return _cma;
        }
    }
    [Range(0.1f, 1f)] 
    public float blurAmount = 0.6f;

    private Matrix4x4 _matrix;

    private void OnEnable()
    {
        cam.depthTextureMode |= DepthTextureMode.Depth;
        _matrix = cam.projectionMatrix * cam.worldToCameraMatrix;
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        mat.SetFloat("_BlurSize", blurAmount);
        mat.SetMatrix("_PreProjectionMatrix", _matrix);
        Matrix4x4 currProjectionMatrix = cam.projectionMatrix * cam.worldToCameraMatrix;
        Matrix4x4 currProjectionInverseMatrix = currProjectionMatrix.inverse;
        mat.SetMatrix("_CurrProjectionInverseMatrix", currProjectionInverseMatrix);
        _matrix = currProjectionMatrix;
        Graphics.Blit(source, destination, mat);
    }
}
