using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MotionBlur : PostEffectBase
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
    [Range(0.1f, 0.9f)] //区间不能太大，否则会替换掉当前帧渲染的结果
    public float blurAmount = 0.6f;

    private RenderTexture _oldTex;

    private void OnRenderImage(RenderTexture source, RenderTexture destination)
    {
        if(!_oldTex || _oldTex.width != source.width || _oldTex.height != source.height)
        {
            DestroyImmediate(_oldTex);
            _oldTex = RenderTexture.GetTemporary(source.width, source.height);
            _oldTex.hideFlags = HideFlags.HideAndDontSave;
            Graphics.Blit(source, _oldTex);
        }

        //标记需要进行恢复操作(该操作发生在渲染到纹理，并且纹理并没有清空的情况下)
        //猜测：此时，_oldTex不会被清空
        _oldTex.MarkRestoreExpected();

        mat.SetFloat("_BlurAmount",1 - blurAmount);
        Graphics.Blit(source, _oldTex, mat);
        Graphics.Blit(_oldTex, destination);
    }

    void OnDisable()
    {
        DestroyImmediate(_oldTex);
    }

}
