using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Bloom : PostEffectBase
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
    [Range(0, 4)]
    public int iterations = 3;
    [Range(0.2f, 3)]
    public float blurSpread = 0.6f;
    [Range(1,8)]
    public int downSample = 2;
    [Range(0, 4)]
    public float lumThreshold = 0.6f;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //使用降采样提高性能
        int w = source.width/downSample;
        int h = source.height/downSample;
        RenderTexture buffer = RenderTexture.GetTemporary(w, h, 0);
        buffer.filterMode = FilterMode.Bilinear;

        mat.SetFloat("_LumThreshold",lumThreshold);
        Graphics.Blit(source, buffer, mat, 0); //使用第一个pass提取较亮的区域

        //对较亮区域进行高斯模糊处理，存储在buffer中
        for(int i = 0; i<iterations; i++)
        {
            mat.SetFloat("_BlurSize", 1.0f + i * blurSpread);
            
            RenderTexture buffer1 = RenderTexture.GetTemporary(w, h, 0);
            //高斯模糊使用了两个pass
            Graphics.Blit(buffer, buffer1, mat, 1);
            
            RenderTexture.ReleaseTemporary(buffer);
            buffer = buffer1;
            buffer1 = RenderTexture.GetTemporary(w, h, 0);
            
            Graphics.Blit(buffer, buffer1, mat, 2);
            
            RenderTexture.ReleaseTemporary(buffer);
            buffer = buffer1;
        }

        //将源图片和处理后对图片进行混合
        mat.SetTexture("_Bloom", buffer);
        Graphics.Blit(source, destination, mat, 3);

        RenderTexture.ReleaseTemporary(buffer);
    }

}
