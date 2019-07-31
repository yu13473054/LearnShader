Shader "Hidden/Cp13_4_EdgeDetectNAD"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EdgesOnly("Edges Only", Float) = 1
        _EdgeColor("Edge Color", Color) = (0,0,0,1)
        _BgColor("Bg Color", Color) = (1,1,1,1)
        _SampDis("Sample Distance", Float) = 1
        _Sensitivity("Sensitivity", Vector) = (1,1,1,1)
    }
    
    SubShader
    {
        CGINCLUDE
        
        #include "UnityCG.cginc"
        
        sampler2D _MainTex;  
        half4 _MainTex_TexelSize;
        fixed _EdgesOnly;
        fixed4 _EdgeColor;
        fixed4 _BgColor;
        float _SampDis;
        float4 _Sensitivity;
    
        sampler2D _CameraDepthNormalsTexture;
        
        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv[5] : TEXCOORD0;
        };
        
        v2f vert(appdata_img v){
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            half2 uv = v.texcoord;
            o.uv[0] = uv;
            #if UNITY_UV_STARTS_AT_TOP //平台差异 
            if(_MainTex_TexelSize.y < 0)
                uv.y = 1 - uv.y;
            #endif
            //使用Roberts算子时需要采样的纹理坐标，同时使用SampDis控制采样距离
            o.uv[1] = uv + _MainTex_TexelSize.xy * half2(1,1)*_SampDis;
            o.uv[2] = uv + _MainTex_TexelSize.xy * half2(-1,-1)*_SampDis;
            o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1,1)*_SampDis;
            o.uv[4] = uv + _MainTex_TexelSize.xy * half2(1,-1)*_SampDis;
            return o;
        }

        //计算对角线上两个纹理值的差值：返回1说明差异不大，返回0说明有差异，需要绘制一条边
        half CheckSame(half4 center, half4 sample){
            //不需要解码得到真正的法线值，只需要比较采样值之间的差异度
            half2 centerNormal = center.xy;
            half2 sampleNormal = sample.xy;
            half2 diffNormal = abs(centerNormal-sampleNormal) * _Sensitivity.x;
            int isSameNormal = (diffNormal.x + diffNormal.y) < 0.1;

            //深度值差异度比较
            float centerDepth = DecodeFloatRG(center.zw);
            float sampleDepth = DecodeFloatRG(sample.zw);
            half2 diffDepth = abs(centerDepth - sampleDepth) * _Sensitivity.y;
            int isSameDepth = diffDepth < 0.1 * centerDepth;

            return isSameNormal * isSameDepth ? 1 : 0;
        }
        
        fixed4 frag(v2f i) : SV_Target
        {
            half4 samp1 = tex2D(_CameraDepthNormalsTexture, i.uv[1]);
            half4 samp2 = tex2D(_CameraDepthNormalsTexture, i.uv[2]);
            half4 samp3 = tex2D(_CameraDepthNormalsTexture, i.uv[3]);
            half4 samp4 = tex2D(_CameraDepthNormalsTexture, i.uv[4]);

            half edge = 1;
            edge *= CheckSame(samp1, samp2);
            edge *= CheckSame(samp3, samp4);

            fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[0]), edge);
            fixed4 onlyEdgeColor = lerp(_EdgeColor, _BgColor, edge);

            return lerp(withEdgeColor, onlyEdgeColor, _EdgesOnly);
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
