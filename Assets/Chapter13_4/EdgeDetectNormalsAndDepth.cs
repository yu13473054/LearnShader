using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EdgeDetectNormalsAndDepth : PostEffectBase
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
    [Range(0f, 1f)] 
    public float edgesOnly = 0;
    public Color edgeColor = Color.black;//颜色
    public Color bgColor = Color.white;//颜色

    public float sampleDis = 1f; //控制对深度+法线纹理采样的距离，其值越大，描边越宽
    public float sensitivityDepth = 1;//深度的判断阀值，领域的值相差多少才会有边
    public float sensitivityNormals = 1;//法线的判断阀值，领域的值相差多少才会有边

    private void OnEnable()
    {
        cam.depthTextureMode |= DepthTextureMode.DepthNormals;
    }

    /// <summary>
    /// 以下方法默认在所有的pass执行完毕后调用，添加上标签后，可以指定其在非透明pass调用完毕后，
    /// 透明pass调用前执行。描边效果我们只希望对不透明物体生效
    /// </summary>
    [ImageEffectOpaque]
    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        mat.SetFloat("_EdgesOnly", edgesOnly);
        mat.SetColor("_EdgeColor", edgeColor);
        mat.SetColor("_BgColor", bgColor);
        mat.SetFloat("_SampDis", sampleDis);
        mat.SetVector("_Sensitivity", new Vector4(sensitivityNormals, sensitivityDepth, 0, 0));

        Graphics.Blit(source, destination, mat);
    }
}
