Shader "Hidden/Cp12_2_BSC"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Brightness("Brightness", Float) = 1
        _Saturation("Saturation", Float) = 1
        _Contrast("Contrast", Float) = 1
    }
    SubShader
    {
        // 防止挡住在其后渲染的物体。后处理shader的标配
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
            };
            
            //顶点着色器只是进行简单的顶点变换，将正确的纹理坐标传递到片源着色器
            v2f vert (appdata_img v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = v.texcoord;
                return o;
            }

            sampler2D _MainTex;
            half _Brightness;
            half _Saturation;
            half _Contrast;

            fixed4 frag (v2f i) : SV_Target
            {
                //对渲染对图片进行采样
                fixed4 col = tex2D(_MainTex, i.uv);
                //应用亮度
                fixed3 finalCol = col.rgb *_Brightness;
                
                //应用饱和度
                fixed lum = 0.2125 * col.r + 0.7154 * col.g + 0.0721 * col.b ;
                fixed3 lumCol = fixed3(lum, lum, lum);
                finalCol = lerp(lumCol, finalCol, _Saturation);
                
                //应用对比度
                fixed3 avgCol = fixed3(0.5,0.5,0.5);
                finalCol = lerp(avgCol, finalCol, _Contrast);
                
                return fixed4(finalCol, col.a);
            }
            ENDCG
        }
    }
}
