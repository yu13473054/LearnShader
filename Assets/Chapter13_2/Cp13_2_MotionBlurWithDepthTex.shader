Shader "Hidden/Cp13_2_MotionBlurWithDepthTex"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BlurSize("Blur Size", Float) = 0.5
    }
    
    SubShader
    {
        CGINCLUDE
        
        #include "UnityCG.cginc"
        
        sampler2D _MainTex;  
        half4 _MainTex_TexelSize;
        sampler2D _CameraDepthTexture;
        float4x4 _PreProjectionMatrix;
        float4x4 _CurrProjectionInverseMatrix;
        half _BlurSize;
    
        struct v2f
        {
            float4 pos : SV_POSITION;
            half2 uv : TEXCOORD0;
            half2 uv_depth : TEXCOORD1;
        };
        
        v2f vert(appdata_img v){
            v2f o;
            o.pos = UnityObjectToClipPos(v.vertex);
            o.uv = v.texcoord;
            o.uv_depth = v.texcoord;
            
            #if UNITY_UV_STARTS_AT_TOP //平台差异
            if(_MainTex_TexelSize.y < 0)
                o.uv_depth.y = 1 - o.uv_depth.y;
            #endif
            
            return o;
        }
        
        fixed4 frag(v2f i) : SV_Target
        {
            //对深度纹理采样，得到深度值
            float d = SAMPLE_DEPTH_TEXTURE(_CameraDepthTexture, i.uv_depth);
            //得到当前帧的世界坐标
            float4 H = float4(i.uv.x * 2 -1, i.uv.y *2 -1, d * 2 -1, 1);
            float4 D = mul(_CurrProjectionInverseMatrix, H);
            float4 worldPos = D/D.w;
            float4 currPos = H;
            //得到前一帧的世界坐标
            float4 prePos = mul(_PreProjectionMatrix, worldPos);
            prePos /= prePos.w;
            //两帧坐标之差计算出速度
            float2 velocity = (currPos.xy - prePos.xy)/2.0f;
            //对领域进行采样
            float2 uv = i.uv;
            float4 col = tex2D(_MainTex, uv);
            uv += velocity * _BlurSize; 
            for(int it = 1; it < 3; it++, uv += velocity * _BlurSize){
                float4 currCol = tex2D(_MainTex, uv);
                col += currCol;
            }
            //取均值
            col /= 3;
            
            return fixed4(col.rgb, 1);
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
