// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Hidden/Cp7_2_NormalWorldSpace"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _BumpMap("Normal Map", 2D) = "bump"{} //法线纹理的默认值为bump，它是Unity内置的法线纹理
        _BumpScale("Bump Scale", Float) = 1 //控制凹凸度，=0时，说明法线纹理不会对光照产生任何影响
        _Color ("Color", Color) = (1.0, 1.0, 1.0, 1.0)
        _Specular("Specular", Color) = (1,1,1,1)
        _Gloss("Gloss", Range(8, 256)) = 20
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
                half4 uv : TEXCOORD0;
                float4 T2W0:TEXCOORD1; //3x3的转换矩阵，w分量储存顶点的世界坐标
                float4 T2W1:TEXCOORD2;
                float4 T2W2:TEXCOORD3;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _BumpMap;
            float4 _BumpMap_ST;
            float _BumpScale;
            fixed4 _Specular;
            float _Gloss;
            fixed4 _Color;
            
            v2f vert ( appdata_tan v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                //转换主纹理和法线纹理的uv。实际上，主纹理和法线纹理会使用同一组纹理坐标
                //出于减少插值寄存器的使用数目的目的，往往只计算和存储一个纹理坐标即可
                o.uv.xy = TRANSFORM_TEX(v.texcoord, _MainTex);
                o.uv.zw = TRANSFORM_TEX(v.texcoord, _BumpMap);

                float3 worldPos = mul(unity_ObjectToWorld , v.vertex);
                //切线，副切线，法线在世界空间下的表示
                fixed3 worldNormal = UnityObjectToWorldNormal(v.normal);
                fixed3 worldTan = UnityObjectToWorldDir(v.tangent.xyz);
                fixed3 worldBinormal = cross(worldNormal, worldTan) * v.tangent.w;

                o.T2W0 = float4(worldTan.x, worldBinormal.x, worldNormal.x, worldPos.x);
                o.T2W1 = float4(worldTan.y, worldBinormal.y, worldNormal.y, worldPos.y);
                o.T2W2 = float4(worldTan.z, worldBinormal.z, worldNormal.z, worldPos.z);

                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPos = float3(i.T2W0.w, i.T2W1.w, i.T2W2.w);//顶点的世界坐标
                fixed3 lightDir = normalize(UnityWorldSpaceLightDir(worldPos)); // 世界空间下的光照方向
                fixed3 viewDir = normalize(UnityWorldSpaceViewDir(worldPos)); //世界空间下的视角方向

                fixed4 packNormal = tex2D(_BumpMap, i.uv.zw); //对法线纹理进行采样
                //由于纹理中存储的像素值是法线经过转换的，所以反向转换得到真正的法线值，此过程需要将纹理的类型设置为Normal Map
                fixed3 tanNormal = UnpackNormal(packNormal);
                tanNormal.xy *= _BumpScale;
                tanNormal.z = sqrt( 1 - saturate(dot(tanNormal.xy, tanNormal.xy)));

                //得到世界空间下法线
                fixed3 worldNormal = normalize(
                    half3(dot(i.T2W0.xyz, tanNormal), dot(i.T2W1.xyz, tanNormal), dot(i.T2W2.xyz, tanNormal)));

                fixed3 albedo = tex2D(_MainTex, i.uv.xy).rgb * _Color.rgb;
                fixed3 ambient = UNITY_LIGHTMODEL_AMBIENT.xyz * albedo;
                fixed3 diffuse = _LightColor0.rgb * albedo * max(0, dot(worldNormal,lightDir));
                fixed3 halfDir = normalize(lightDir + viewDir);
                fixed3 specular = _LightColor0.rgb * _Specular.rgb * pow(max(0, dot(worldNormal, halfDir)), _Gloss);
                return fixed4(ambient+diffuse+specular, 1);
            }
            ENDCG
        }
    }
}
