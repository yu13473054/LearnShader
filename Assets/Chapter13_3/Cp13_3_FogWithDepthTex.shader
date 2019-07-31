Shader "Hidden/Cp13_3_FogWithDepthTex"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FogDensity("Fog Density", Float) = 0.5
        _FogColor("FogColor", Color) = (1,1,1,1)
        _FogStart("Fog Start", Float) = 0
        _FogEnd("Fog End", Float) = 2
    }
    
    SubShader
    {
        CGINCLUDE
        
        #include "UnityCG.cginc"
        
        sampler2D _MainTex;  
        half4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        float4x4 _ProjectionInverseMatrix;
        float4x4 _FrustumCorners;
        float _FogDensity;
        fixed4 _FogColor;
        float _FogStart;
        float _FogEnd;
    
        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
            half2 uv_depth : TEXCOORD1;
            float4 interpolateRay : TEXCOORD2;
        };
        
        v2f vert(appdata_img v){
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            o.uv_depth = v.texcoord;
            
            int index = 0;
            if(v.texcoord.x < 0.5 && v.texcoord.y < 0.5){ //左下角
                index = 0;
            } else if(v.texcoord.x > 0.5 && v.texcoord.y < 0.5 ){ // 右下角
                index = 1;
            } else if(v.texcoord.x > 0.5 && v.texcoord.y > 0.5 ){ //右上角
                index = 2;
            } else{ //左上角
                index = 3;
            }
            
            #if UNITY_UV_STARTS_AT_TOP //平台差异
            if(_MainTex_TexelSize.y < 0){
                o.uv_depth.y = 1 - o.uv_depth.y;
                index = 3 - index;
            }
            #endif
            
            o.interpolateRay = _FrustumCorners[index];
            return o;
        }
        
        fixed4 frag(v2f i) : SV_Target
        {
            //对深度纹理采样，得到深度值
            float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
            float linearDepth = LinearEyeDepth(d);
            float3 worldPos = _WorldSpaceCameraPos + i.interpolateRay.xyz * linearDepth;
            float f = (_FogEnd - worldPos.y)/(_FogEnd - _FogStart); //雾的线性计算公式
            f = saturate(f * _FogDensity); //限定计算系数范围为0～
            
            fixed4 col = tex2D(_MainTex, i.uv);
            col.rgb = lerp(col.rgb, _FogColor.rgb, f);
            return col;
        }
        
        ENDCG
    
        
        Pass
        {
            ZTest Always Cull Off ZWrite Off
            
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            ENDCG
        }
    }
}
