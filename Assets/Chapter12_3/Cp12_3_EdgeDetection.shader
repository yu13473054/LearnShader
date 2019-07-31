Shader "Hidden/Cp12_3_EdgeDetection"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _EdgeOnly("Edge Only", Float) = 0
        _EdgeColor("Edge Color", Color) = (0,0,0,1)
        _BackgroundColor("Background Color", Color) = (0,0,0,1)
    }
    SubShader
    {
        // No culling or depth
        Cull Off ZWrite Off ZTest Always

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct v2f
            {
                half2 uv[9] : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };
            
            sampler2D _MainTex;
            half4 _MainTex_TexelSize;
            fixed _EdgeOnly;
            fixed4 _EdgeColor;
            fixed4 _BackgroundColor;
            
            v2f vert (appdata_img v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                half2 uv = v.texcoord;
                
                //预先算出卷积核的9个领域纹理坐标
                o.uv[0] = uv + _MainTex_TexelSize.xy * half2(-1, -1);
                o.uv[1] = uv + _MainTex_TexelSize.xy * half2(0, -1);
                o.uv[2] = uv + _MainTex_TexelSize.xy * half2(1, -1);
                o.uv[3] = uv + _MainTex_TexelSize.xy * half2(-1, 0);
                o.uv[4] = uv + _MainTex_TexelSize.xy * half2(0, 0);
                o.uv[5] = uv + _MainTex_TexelSize.xy * half2(1, 0);
                o.uv[6] = uv + _MainTex_TexelSize.xy * half2(-1, 1);
                o.uv[7] = uv + _MainTex_TexelSize.xy * half2(0, 1);
                o.uv[8] = uv + _MainTex_TexelSize.xy * half2(1, 1);
                return o;
            }
            
            fixed luminance(fixed4 color){
                return 0.2125 * color.r + 0.7154 * color.g + 0.0721 * color.b;
            }
            
            half Sobel(v2f i)
            {
                half Gx[9]={
                    -1,  0,  1,
                    -2,  0,  2,
                    -1,  0,  1
                };
                
                half Gy[9]={
                    -1, -2, -1,
                    0,  0,  0,
                    1,  2,  1
                };
                
                half texCol;
                half edgeX = 0;
                half edgeY = 0;
                
                for(int it =0; it<9; it++){
                    texCol = luminance(tex2D(_MainTex, i.uv[it]));
                    edgeX += texCol * Gx[it];
                    edgeY += texCol * Gy[it];
                }
                return 1 - abs(edgeX) - abs(edgeY);
            }
            
            fixed4 frag (v2f i) : SV_Target
            {
                half edge = Sobel(i);
                
                fixed4 withEdgeColor = lerp(_EdgeColor, tex2D(_MainTex, i.uv[4]), edge);
                fixed4 onlyEdgeColor = lerp(_EdgeColor, _BackgroundColor, edge);
                return lerp(withEdgeColor, onlyEdgeColor, _EdgeOnly);
            }
            
            ENDCG
        }
    }
}
