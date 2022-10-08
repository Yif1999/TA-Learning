Shader "Custom/AD"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "gray" {}
    }
    SubShader
    {
        Tags{ 
            "Queue"="Transparent"
            "RenderType"="Transparent" 
            "ForceNoShadowCasting"="True"
            "IgnoreProjector"="True"
            }
        LOD 100

        Pass
        {
            Name "FORWARD"
            Tags{
                "LightMode"="ForwardBase"
            }
            Blend One One

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"
            #pragma multi_compile_fwdbase_fullshadows
            #pragma target 3.0

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : COLOR
            {
                fixed4 var_MainTex = tex2D(_MainTex, i.uv);
                return var_MainTex;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
