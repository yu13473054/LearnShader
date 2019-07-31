using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FogWithDepthTex : PostEffectBase
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
    [Range(0f, 3f)] 
    public float fogDensity = 1; //浓度

    public Color fogCol = Color.white;//颜色

    public float fogStart = 0f;
    public float fogEnd = 2f;


    private void OnEnable()
    {
        cam.depthTextureMode |= DepthTextureMode.Depth;
    }


    //基于透视摄像机的雾效计算方式，正交摄像机的计算方式需要重新设计公式
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        float fov = cam.fieldOfView;
        float near = cam.nearClipPlane;
        float far = cam.farClipPlane;
        float aspect = cam.aspect;

        float halfH = near * Mathf.Tan(fov / 2 * Mathf.Deg2Rad); //近切面一半的高度
        Vector3 toTop = cam.transform.up * halfH; //向上的向量
        Vector3 toRight = cam.transform.right * halfH * aspect; //向右的向量

        Vector3 toLT = cam.transform.forward * near + (toTop - toRight); //近切面左上角的向量
        float scale = toLT.magnitude / near;

        //左上角射线
        toLT.Normalize();
        toLT *= scale;
        //左下角射线
        Vector3 toLB = cam.transform.forward * near - (toTop + toRight);
        toLB = toLB.normalized * scale;
        //右上角射线
        Vector3 toRT = cam.transform.forward * near + toTop + toRight;
        toRT = toRT.normalized * scale;
        //右下角射线
        Vector3 toRB = cam.transform.forward * near - (toTop - toRight);
        toRB = toRB.normalized * scale;

        Matrix4x4 frustumCorners = Matrix4x4.identity;
        frustumCorners.SetRow(0, toLB);
        frustumCorners.SetRow(1, toRB);
        frustumCorners.SetRow(2, toRT);
        frustumCorners.SetRow(3, toLT);

        mat.SetMatrix("_FrustumCorners", frustumCorners);
        mat.SetMatrix("_ProjectionInverseMatrix", (cam.projectionMatrix * cam.worldToCameraMatrix).inverse);
        mat.SetFloat("_FogDensity", fogDensity);
        mat.SetColor("_FogColor", fogCol);
        mat.SetFloat("_FogStart", fogStart);
        mat.SetFloat("_FogEnd", fogEnd);

        Graphics.Blit(source, destination, mat);
    }
}
