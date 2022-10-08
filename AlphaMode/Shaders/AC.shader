Shader "Custom/AC"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "gray" {}
        _Cutoff("offset",range(0.0,1.0))=0.5
    }
    SubShader
    {
        Tags{ 
            "RenderType"="TransparentCutout" 
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
            half _Cutoff;

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
                clip(var_MainTex.a-_Cutoff);
                return var_MainTex;
            }
            ENDCG
        }
    }
    Fallback "Diffuse"
}
