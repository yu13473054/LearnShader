using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Gaussion : PostEffectBase
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

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        //使用降采样提高性能
        int w = source.width/downSample;
        int h = source.height/downSample;
        RenderTexture buffer = RenderTexture.GetTemporary(w, h, 0);
        buffer.filterMode = FilterMode.Bilinear;

        if(iterations <= 1)
        {
            mat.SetFloat("_BlurSize", blurSpread);
            Graphics.Blit(source, buffer, mat, 0);
            Graphics.Blit(buffer, destination, mat, 1);
        }
        else 
        { 
            //迭代次数
            Graphics.Blit(source, buffer);
            for(int i = 0; i<iterations; i++)
            {
                mat.SetFloat("_BlurSize", 1.0f + i * blurSpread);
                
                RenderTexture buffer1 = RenderTexture.GetTemporary(w, h, 0);
                //高斯模糊使用了两个pass
                Graphics.Blit(buffer, buffer1, mat, 0);
                
                RenderTexture.ReleaseTemporary(buffer);
                buffer = buffer1;
                buffer1 = RenderTexture.GetTemporary(w, h, 0);
                
                Graphics.Blit(buffer, buffer1, mat, 1);
                
                RenderTexture.ReleaseTemporary(buffer);
                buffer = buffer1;
            }
            Graphics.Blit(buffer, destination);
        }

        RenderTexture.ReleaseTemporary(buffer);
    }

}
