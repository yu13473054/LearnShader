using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class PostEffectBase : MonoBehaviour
{
    protected void Start()
    {
        CheckRes();
    }

    protected void CheckRes()
    {
        if (!CheckSupport())
        {
            NotSupport();
        }
    }

    //检查是否支持后处理
    protected bool CheckSupport()
    {
        if(SystemInfo.supportsImageEffects)
        {
            return true;
        }

        return false;
    }

    protected void NotSupport()
    {
        enabled = false;
    }

    //检查shade和mat
    protected Material CheckShaderAndCreateMat(Shader shader, Material mat = null)
    {
        if (!shader.isSupported) return null;
        if (mat && mat.shader == shader) return mat;
        //创建一个新的mat
        mat = new Material(shader);
        mat.hideFlags = HideFlags.DontSave;
        return mat;
    }
}
