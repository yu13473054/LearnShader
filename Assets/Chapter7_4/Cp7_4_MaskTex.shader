Shader "Hidden/Cp7_4_MaskTex"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap("Normal Map", 2D) = "bump"{} //法线纹理的默认值为bump，它是Unity内置的法线纹理
        _BumpScale("Bump Scale", Float) = 1 //控制凹凸度，=0时，说明法线纹理不会对光照产生任何影响
        _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8, 256)) = 20
        _SpecularMask("Specular Mask", 2d) = "white"{} //遮罩纹理
        _SpecularScale("Specular Scale", Float) = 1 //控制遮罩影响度系数
    }
    SubShader
    {
        Pass
        {
            Tags { "LightMode" = "ForwardBase" }

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"
            #include "Lighting.cginc"

            struct v2f
            {
                float4 pos : SV_POSITION;
                half2 uv : TEXCOORD0;
                float3 viewDir : TEXCOORD1;  
                float3 lightDir : TEXCOORD2;  
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float _BumpScale;
            sampler2D _SpecularMask;
            float _SpecularScale;
            fixed4 _Specular;
            float _Gloss;
            fixed4 _Color;
            
            v2f vert ( appdata_tan v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //转换主纹理和法线纹理的uv。实际上，主纹理和法线纹理会使用同一组纹理坐标
                //出于减少插值寄存器的使用数目的目的，往往只计算和存储一个纹理坐标即可
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                //计算出从模型空间到切线空间到变换矩阵，使用UnityCG中的内置宏
                TANGENT_SPACE_ROTATION;
                //转换视角方向到切线空间中
                o.viewDir = mul(rotation, ObjSpaceViewDir(v.vertex)).xyz;
                //转换光照方向到切线空间中
                o.lightDir = mul(rotation, ObjSpaceLightDir(v.vertex)).xyz;

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 packNormal = tex2D(_BumpMap, i.uv); //对法线纹理进行采样
                //由于纹理中存储的像素值是法线经过转换的，所以反向转换得到真正的法线值，此过程需要将纹理的类型设置为Normal Map
                fixed3 tanNormal = UnpackNormal(packNormal);

                tanNormal.xy *= _BumpScale;
                tanNormal.z = sqrt( 1 - saturate(dot(tanNormal.xy, tanNormal.xy)));

                fixed3 tanLightDir = normalize(i.lightDir);
                fixed3 tanViewDir = normalize(i.viewDir);
                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(tanNormal,tanLightDir));
                fixed3 halfDir = normalize(tanLightDir + tanViewDir);
                fixed specularMask = tex2D(_SpecularMask, i.uv).r * _SpecularScale;//使用纹理中的一个颜色通道，控制高光的反射强度
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(tanNormal, halfDir)), _Gloss) * specularMask;
                return fixed4(ambient+diffuse+specular, 1);
            }
            ENDCG
        }
    }
}
