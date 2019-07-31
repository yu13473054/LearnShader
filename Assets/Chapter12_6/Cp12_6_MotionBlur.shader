﻿Shader "Hidden/Cp12_6_MotionBlur"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurAmount("Blur Size", Float) = 0.5
    }
    
    SubShader
    {
        CGINCLUDE
        
        #include "UnityCG.cginc"
        
        sampler2D _MainTex;  
        fixed _BlurAmount;
    
        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
        };
        
        v2f vert(appdata_img v){
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            return o;
        }
        
        fixed4 fragRGB(v2f i) : SV_Target
        {
            fixed4 col = tex2D(_MainTex, i.uv);
            return fixed4(col.rgb, _BlurAmount);
        }
        
        fixed4 fragA(v2f i) : SV_Target
        {
            return tex2D(_MainTex, i.uv);
        }
        
        ENDCG
    
        ZTest Always Cull Off ZWrite Off
        
        //更新渲染纹理的RGB通道
        Pass
        {
            Blend SrcAlpha OneMinusSrcAlpha
            
            ColorMask RGB
        
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragRGB
            ENDCG
        }
        
        
        //更新渲染纹理的A通道
        Pass
        {
            Blend One Zero
            
            ColorMask A
        
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment fragA
            ENDCG
        }
    }
}
